#requires -Version 5.1
#requires -PSEdition Desktop
<#
.SYNOPSIS
  Collect diagnostic screenshots of a Windows game build. Pixel changes do
  not verify gameplay or measure input latency.
.DESCRIPTION
  Launches a visible game window, confirms its identity and focus, then captures
  observations. Synthetic gameplay input is opt-in. Use only with authorized
  local test builds and computer-control methods permitted by your environment.
  Exit 0 means observations collected; 1 means collection failed; 2 means invalid
  input observations. No exit code certifies gameplay quality.
.EXAMPLE
  powershell -File native-probe.ps1 -Exe dist\Game.exe -InputMode key -Key SPACE -Out probe-out
#>
param(
  [Parameter(Mandatory = $true)][string]$Exe,
  [Alias("Args")][string]$ArgumentLine = "",
  [ValidateRange(0, 30)][double]$Settle = 6,
  [ValidateSet("none", "key", "pointer", "both")][string]$InputMode = "none",
  [string]$Key = "SPACE",
  [ValidateRange(1, 10000)][int]$HoldMs = 900,
  [switch]$Drag,
  [string]$Out = "native-probe-out",
  [switch]$KeepOpen
)

$ErrorActionPreference = "Stop"

function Get-NativeProbeSummary {
  param([hashtable]$Trials, [bool]$Focused = $true, [bool]$WindowMoved = $false)
  $invalid = @()
  if (-not $Focused) { $invalid += "Game window focus was not confirmed." }
  if ($WindowMoved) { $invalid += "The window rectangle changed during observation." }
  $attempted = @($Trials.Values | Where-Object { $null -ne $_ })
  $observed = $false
  foreach ($trial in $attempted) {
    if ($null -eq $trial.samples -or $trial.samples -lt 1) { $invalid += "An attempted input has no screenshot samples." }
    if ($null -ne $trial.firstChangeSampleAtMs) {
      if ($trial.firstChangeSampleAtMs -lt 0 -or [double]::IsNaN($trial.firstChangeSampleAtMs) -or [double]::IsInfinity($trial.firstChangeSampleAtMs)) { $invalid += "Invalid observation timestamp." }
      $observed = $true
    }
  }
  $status = if ($invalid.Count) { "INVALID" } elseif (-not $attempted.Count) { "NOT_TESTED" } elseif ($observed) { "CHANGE_OBSERVED" } else { "NO_CHANGE_OBSERVED" }
  return @{
    status = $status; invalidReasons = $invalid; gameplayVerified = $null; inputLatencyMs = $null
    interpretation = "Pixels may change because of idle animation, hover, or unrelated state. No change may mean the wrong input or a still/discrete game. Verify the intended state transition separately."
  }
}

if ((Test-Path -LiteralPath $Out) -and @(Get-ChildItem -LiteralPath $Out -Force).Count -gt 0) { throw "Choose an empty output directory to preserve earlier evidence." }
$exePath = (Resolve-Path -LiteralPath $Exe).Path
$workDir = Split-Path -Parent $exePath
$vkMap = @{ SPACE = 0x20; ENTER = 0x0D; ESC = 0x1B; LEFT = 0x25; UP = 0x26; RIGHT = 0x27; DOWN = 0x28; TAB = 0x09; SHIFT = 0x10 }
$keyName = $Key.ToUpperInvariant()
if ($vkMap.ContainsKey($keyName)) { $vk = [byte]$vkMap[$keyName] }
elseif ($keyName -match '^[A-Z0-9]$') { $vk = [byte][char]$keyName }
else { throw "Unsupported key. Use a letter, digit, SPACE, ENTER, ESC, arrows, TAB, or SHIFT." }
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class NativeProbe {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
  [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT rect);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT pt);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
  [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int cmd);
  public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr lParam);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern uint MapVirtualKey(uint code, uint mapType);
  public const uint KEYEVENTF_KEYUP = 0x0002;
  public const uint KEYEVENTF_SCANCODE = 0x0008;

  // Engines such as Godot read the physical scan code from the key message, so
  // a zero scan code can be ignored even when the virtual key is right.
  public static void KeyDown(byte vk) { keybd_event(vk, (byte)MapVirtualKey(vk, 0), 0, UIntPtr.Zero); }
  public static void KeyUp(byte vk) { keybd_event(vk, (byte)MapVirtualKey(vk, 0), KEYEVENTF_KEYUP, UIntPtr.Zero); }

  // Foreground activation from a background process: attach our input queue
  // to the current foreground thread, activate, detach. No ALT presses (an
  // ALT tap puts the target window into menu mode, and the next SPACE opens
  // its system menu instead of reaching the game).
  public static bool Activate(IntPtr hwnd) {
    if (GetForegroundWindow() == hwnd) return true;
    IntPtr fg = GetForegroundWindow();
    uint fgThread = 0, dummy;
    if (fg != IntPtr.Zero) fgThread = GetWindowThreadProcessId(fg, out dummy);
    uint me = GetCurrentThreadId();
    bool attached = fgThread != 0 && fgThread != me && AttachThreadInput(me, fgThread, true);
    try { BringWindowToTop(hwnd); SetForegroundWindow(hwnd); }
    finally { if (attached) AttachThreadInput(me, fgThread, false); }
    System.Threading.Thread.Sleep(150);
    return GetForegroundWindow() == hwnd;
  }

  // Largest visible top-level window owned by the process (Godot, Unreal and
  // Unity may create a splash or console window before the real one).
  public static IntPtr LargestWindow(int pid) {
    IntPtr best = IntPtr.Zero; long bestArea = 0;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if ((int)p == pid && IsWindowVisible(h)) {
        Rectangle r = ClientArea(h); long a = (long)r.Width * r.Height;
        if (a > bestArea) { bestArea = a; best = h; }
      }
      return true;
    }, IntPtr.Zero);
    return best;
  }
  public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
  public const uint MOUSEEVENTF_LEFTUP = 0x0004;

  public static Rectangle ClientArea(IntPtr hwnd) {
    RECT r; GetClientRect(hwnd, out r);
    POINT p = new POINT { X = 0, Y = 0 }; ClientToScreen(hwnd, ref p);
    return new Rectangle(p.X, p.Y, r.Right - r.Left, r.Bottom - r.Top);
  }
  public static Bitmap Capture(Rectangle area) {
    Bitmap bmp = new Bitmap(area.Width, area.Height, PixelFormat.Format24bppRgb);
    using (Graphics g = Graphics.FromImage(bmp)) { g.CopyFromScreen(area.X, area.Y, 0, 0, bmp.Size); }
    return bmp;
  }
  static byte[] Small(Bitmap src, int w, int h) {
    using (Bitmap s = new Bitmap(w, h, PixelFormat.Format24bppRgb)) {
      using (Graphics g = Graphics.FromImage(s))
      using (ImageAttributes attributes = new ImageAttributes()) {
        // Extend edge pixels while resampling; do not blend an implicit black border.
        attributes.SetWrapMode(System.Drawing.Drawing2D.WrapMode.TileFlipXY);
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.Bilinear;
        g.DrawImage(src, new Rectangle(0, 0, w, h), 0, 0, src.Width, src.Height, GraphicsUnit.Pixel, attributes);
      }
      BitmapData d = s.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
      byte[] buf = new byte[d.Stride * h];
      Marshal.Copy(d.Scan0, buf, 0, buf.Length);
      s.UnlockBits(d);
      return buf;
    }
  }
  // Fraction of downscaled pixels whose color moved by more than 24 on any channel.
  public static double Diff(Bitmap a, Bitmap b) {
    int w = 320, h = 180;
    byte[] da = Small(a, w, h), db = Small(b, w, h);
    int stride = da.Length / h; int changed = 0;
    for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
      int i = y * stride + x * 3;
      if (Math.Abs(da[i] - db[i]) > 24 || Math.Abs(da[i+1] - db[i+1]) > 24 || Math.Abs(da[i+2] - db[i+2]) > 24) changed++;
    }
    return (double)changed / (w * h);
  }
}
"@ -ReferencedAssemblies System.Drawing


$proc = $null
$script:probeKeyHeld = $false
$script:probeMouseHeld = $false
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
  $launch = @{ FilePath = $exePath; WorkingDirectory = $workDir; PassThru = $true; WindowStyle = "Normal" }
  if (-not [string]::IsNullOrWhiteSpace($ArgumentLine)) { $launch.ArgumentList = $ArgumentLine }
  # A visible window is the explicit subject of this diagnostic.
  $proc = Start-Process @launch
  $hwnd = [IntPtr]::Zero
  $deadline = (Get-Date).AddSeconds(45)
  while ((Get-Date) -lt $deadline) {
    $proc.Refresh()
    if ($proc.HasExited) { throw "Game exited before a usable window appeared." }
    $candidate = [NativeProbe]::LargestWindow($proc.Id)
    if ($candidate -ne [IntPtr]::Zero) {
      $r = [NativeProbe]::ClientArea($candidate)
      if ($r.Width -ge 200 -and $r.Height -ge 200) { $hwnd = $candidate; break }
    }
    Start-Sleep -Milliseconds 250
  }
  if ($hwnd -eq [IntPtr]::Zero) { throw "No usable game window appeared within 45 seconds." }
  $windowAtMs = [int]$sw.ElapsedMilliseconds
  Start-Sleep -Milliseconds ([int]($Settle * 1000))
  $hwnd = [NativeProbe]::LargestWindow($proc.Id)
  if ($hwnd -eq [IntPtr]::Zero -or -not [NativeProbe]::Activate($hwnd)) { throw "Cannot confirm the game window and focus. No gameplay input was sent." }
  $area = [NativeProbe]::ClientArea($hwnd)
  if ($area.Width -lt 200 -or $area.Height -lt 200) { throw "Game client area became too small." }
  $cx = $area.X + [int]($area.Width / 2)
  $cy = $area.Y + [int]($area.Height / 2)
  $sweepWidth = [Math]::Min(200, [int]($area.Width / 3))

  function Assert-Target {
    $proc.Refresh()
    if ($proc.HasExited -or [NativeProbe]::GetForegroundWindow() -ne $hwnd) { throw "Game exited or focus changed; observation is invalid." }
    $now = [NativeProbe]::ClientArea($hwnd)
    if ($now -ne $area) { throw "Game window moved or resized; observation is invalid." }
  }
  function Save-Frame($bitmap, $name) { $bitmap.Save((Join-Path $Out "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png) }
  function Capture-Saved($name) {
    Assert-Target
    $bitmap = [NativeProbe]::Capture($area)
    try { Save-Frame $bitmap $name } finally { $bitmap.Dispose() }
  }
  Capture-Saved "boot"
  $bootCapturedAtMs = [int]$sw.ElapsedMilliseconds
  $idleA = [NativeProbe]::Capture($area)
  $idleB = $null
  try {
    Start-Sleep -Milliseconds 500
    Assert-Target
    $idleB = [NativeProbe]::Capture($area)
    $idleDiff = [NativeProbe]::Diff($idleA, $idleB)
    Save-Frame $idleB "idle"
  } finally {
    $idleA.Dispose()
    if ($null -ne $idleB) { $idleB.Dispose() }
  }
  $threshold = 0.003

  function Watch-Input($label, [scriptblock]$act, [scriptblock]$release) {
    Assert-Target
    $baseline = [NativeProbe]::Capture($area)
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    $first = $null; $samples = 0; $peak = 0.0
    try {
      Save-Frame $baseline "before-$label"
      & $act
      do {
        Assert-Target
        $frame = [NativeProbe]::Capture($area)
        try {
          $difference = [NativeProbe]::Diff($baseline, $frame)
          $samples++
          $peak = [Math]::Max($peak, $difference)
          if ($difference -gt $threshold -and $null -eq $first) {
            $first = [int]$watch.ElapsedMilliseconds
            Save-Frame $frame "change-$label"
          }
        } finally { $frame.Dispose() }
      } while ($watch.ElapsedMilliseconds -lt $HoldMs)
    } finally {
      & $release
      $baseline.Dispose()
    }
    Capture-Saved "after-$label"
    return @{ label = $label; firstChangeSampleAtMs = $first; samples = $samples; peakDiff = [Math]::Round($peak, 4); elapsedMs = [int]$watch.ElapsedMilliseconds }
  }

  $trials = @{ key = $null; pointer = $null; drag = $null }
  if ($InputMode -in @("key", "both")) {
    $trials.key = Watch-Input "key" {
      $script:probeKeyHeld = $true
      [NativeProbe]::KeyDown($vk)
    } {
      [NativeProbe]::KeyUp($vk)
      $script:probeKeyHeld = $false
    }
  }
  $sweep = {
    for ($i = 0; $i -le 8; $i++) {
      Assert-Target
      [NativeProbe]::SetCursorPos($cx - $sweepWidth + [int]($i * $sweepWidth / 4), $cy) | Out-Null
      Start-Sleep -Milliseconds 15
    }
  }
  if ($InputMode -in @("pointer", "both")) { $trials.pointer = Watch-Input "pointer" $sweep {} }
  if ($Drag) {
    [NativeProbe]::SetCursorPos($cx - $sweepWidth, $cy) | Out-Null
    $trials.drag = Watch-Input "drag" {
      $script:probeMouseHeld = $true
      [NativeProbe]::mouse_event([NativeProbe]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, [UIntPtr]::Zero)
      & $sweep
    } {
      [NativeProbe]::mouse_event([NativeProbe]::MOUSEEVENTF_LEFTUP, 0, 0, 0, [UIntPtr]::Zero)
      $script:probeMouseHeld = $false
    }
  }
  Capture-Saved "final"
  $summary = Get-NativeProbeSummary -Trials $trials
  $report = [ordered]@{
    schemaVersion = 2; collectionStatus = "complete"; capturedAt = (Get-Date).ToUniversalTime().ToString("o")
    exe = $exePath; processId = $proc.Id; inputMode = $InputMode; key = $keyName; holdMs = $HoldMs; drag = [bool]$Drag
    windowAppearedMs = $windowAtMs; bootCapturedAtMs = $bootCapturedAtMs
    clientArea = @{ x = $area.X; y = $area.Y; w = $area.Width; h = $area.Height }
    inputObservation = $summary; input = $trials
    idleMotionFraction = [Math]::Round($idleDiff, 4); pixelChangeThreshold = $threshold
    limitations = @(
      "Pixels do not isolate input causality or measure input latency.",
      "The boot capture follows settling and is not the first displayed frame or time to control.",
      "The native probe cannot inspect the UI tree or authoritative gameplay state.",
      "Verify the intended action, consequence, feedback, and recovery separately."
    )
  }
  $report | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 (Join-Path $Out "report.json")
  Write-Output "Collected diagnostic observations: $($summary.status). Gameplay and latency remain unverified."
  Write-Output "Artifacts: $((Resolve-Path -LiteralPath $Out).Path)"
} catch {
  @{ schemaVersion = 2; collectionStatus = "error"; gameplayVerified = $null; error = $_.Exception.Message } |
    ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $Out "report.json")
  throw
} finally {
  if ($script:probeKeyHeld) { [NativeProbe]::KeyUp($vk) }
  if ($script:probeMouseHeld) { [NativeProbe]::mouse_event([NativeProbe]::MOUSEEVENTF_LEFTUP, 0, 0, 0, [UIntPtr]::Zero) }
  if ($null -ne $proc -and -not $KeepOpen) {
    $proc.Refresh()
    if (-not $proc.HasExited) {
      $proc.CloseMainWindow() | Out-Null
      if (-not $proc.WaitForExit(3000)) { Write-Warning "The launched game did not close gracefully; it remains open." }
    }
  }
}
