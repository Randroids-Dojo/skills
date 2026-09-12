$ErrorActionPreference = "Stop"
$source = Join-Path $PSScriptRoot '..\plugins\randroid\skills\randroid-game-feel\scripts\native-probe.ps1'
$tokens = $null; $errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($source, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
# Load only the pure report function; never launch or interact with a desktop.
$definition = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-NativeProbeSummary' }, $true)
if ($null -eq $definition) { throw 'Report function missing.' }
Invoke-Expression $definition.Extent.Text
$cases = @(
  @{ trials = @{ key = $null }; expected = 'NOT_TESTED'; focused = $true; moved = $false },
  @{ trials = @{ key = @{ samples = 4; firstChangeSampleAtMs = $null } }; expected = 'NO_CHANGE_OBSERVED'; focused = $true; moved = $false },
  @{ trials = @{ key = @{ samples = 4; firstChangeSampleAtMs = 10 } }; expected = 'CHANGE_OBSERVED'; focused = $true; moved = $false },
  @{ trials = @{ key = @{ samples = 4; firstChangeSampleAtMs = 10 } }; expected = 'INVALID'; focused = $false; moved = $false },
  @{ trials = @{ key = @{ samples = 4; firstChangeSampleAtMs = 10 } }; expected = 'INVALID'; focused = $true; moved = $true },
  @{ trials = @{ key = @{ samples = 0; firstChangeSampleAtMs = $null } }; expected = 'INVALID'; focused = $true; moved = $false },
  @{ trials = @{ key = @{ samples = 1; firstChangeSampleAtMs = -1 } }; expected = 'INVALID'; focused = $true; moved = $false }
)
foreach ($case in $cases) {
  $result = Get-NativeProbeSummary -Trials $case.trials -Focused $case.focused -WindowMoved $case.moved
  if ($result.status -ne $case.expected) { throw "Expected $($case.expected), got $($result.status)" }
  if ($null -ne $result.gameplayVerified -or $null -ne $result.inputLatencyMs) { throw 'Pixel samples must not certify gameplay or latency.' }
}
# Compile the actual embedded helper and test bitmap diff without screen capture.
Add-Type -AssemblyName System.Drawing
$compile = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Add-Type' -and $node.Extent.Text.Contains('-TypeDefinition') }, $true)
if ($null -eq $compile) { throw 'Native helper missing.' }
Invoke-Expression $compile.Extent.Text
$a = New-Object System.Drawing.Bitmap 64, 64
$b = New-Object System.Drawing.Bitmap 64, 64
$ga = [System.Drawing.Graphics]::FromImage($a)
$g = [System.Drawing.Graphics]::FromImage($b)
try {
  $ga.Clear([System.Drawing.Color]::Black)
  if ([NativeProbe]::Diff($a, $a) -ne 0) { throw 'Identical bitmap must have zero change.' }
  $g.Clear([System.Drawing.Color]::White)
  $difference = [NativeProbe]::Diff($a, $b)
  if ($difference -ne 1) { throw "Black-to-white bitmap must change every sampled pixel; actual fraction $difference." }
} finally { $ga.Dispose(); $g.Dispose(); $a.Dispose(); $b.Dispose() }
Write-Output 'Native probe: 7 report scenarios, C# compilation, and 2 bitmap comparisons passed. No desktop interaction performed.'
