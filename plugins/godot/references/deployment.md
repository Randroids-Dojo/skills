# Godot Deployment Guide

Export and deploy Godot games to various platforms.

## Web Export (HTML5/WebAssembly)

### Prerequisites

1. **Export Templates** - Install via Editor → Manage Export Templates
2. **Export Preset** - Configure in Project → Export → Add → Web

### Export Preset Configuration

Create `export_presets.cfg` in your project root:

```ini
[preset.0]
name="Web"
platform="Web"
runnable=true
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/index.html"

[preset.0.options]
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/experimental_virtual_keyboard=false
html/focus_canvas_on_start=true
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
```

### Command Line Export

```bash
# Release build
godot --headless --export-release "Web" ./build/index.html

# Debug build (larger, includes debugger)
godot --headless --export-debug "Web" ./build/index.html

# Using helper script
python scripts/export_build.py --project . --preset Web --output ./build/index.html
```

### Output Files

Web export creates:
```
build/
├── index.html          # Main HTML file
├── index.js            # JavaScript loader
├── index.wasm          # WebAssembly binary
├── index.pck           # Game resources
├── index.png           # Icon
└── index.audio.worklet.js
```

## Deployment Platforms

### Vercel

Best for: Fast global CDN, preview deployments, GitHub integration.

#### Initial Setup

1. **Create Vercel Account**
   - Go to [vercel.com](https://vercel.com) and sign up
   - Connect your GitHub account for easy project imports

2. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

3. **Link Your Project**
   ```bash
   # Navigate to your build output directory
   cd example-project/build

   # Link to Vercel (creates .vercel/project.json)
   vercel link
   ```

   Follow the prompts to:
   - Log in to Vercel
   - Select your scope (personal or team)
   - Link to existing project or create new one

4. **Get Project IDs**
   After linking, check `.vercel/project.json`:
   ```json
   {
     "orgId": "your-org-id",
     "projectId": "your-project-id"
   }
   ```

5. **Create API Token**
   - Go to [vercel.com/account/tokens](https://vercel.com/account/tokens)
   - Click "Create Token"
   - Name it (e.g., "GitHub Actions")
   - Copy the token (shown only once)

#### Manual Deploy

```bash
# Build the game
godot --headless --export-release "Web" ./build/index.html

# Deploy to Vercel
vercel deploy ./build --prod
```

#### GitHub Actions

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: 4.3.0
          include-templates: true

      - name: Import Project
        run: godot --headless --import --path . --quit || true

      - name: Build Web Export
        run: |
          mkdir -p build
          godot --headless --export-release "Web" ./build/index.html

      - name: Deploy to Vercel
        run: |
          npm i -g vercel
          vercel deploy ./build --prod --token=${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

#### GitHub Repository Setup

To enable automatic Vercel deployments from GitHub Actions:

1. **Add Secrets** (Settings → Secrets and variables → Actions → New repository secret):
   - `VERCEL_TOKEN` - Your Vercel API token
   - `VERCEL_ORG_ID` - From `.vercel/project.json` after `vercel link`
   - `VERCEL_PROJECT_ID` - From `.vercel/project.json` after `vercel link`

2. **Add Variables** (Settings → Secrets and variables → Actions → Variables tab):
   - `ENABLE_VERCEL_DEPLOY` = `true`

#### Preview Deployments (PRs)

```yaml
      - name: Deploy Preview
        if: github.event_name == 'pull_request'
        id: deploy
        run: |
          npm i -g vercel
          url=$(vercel deploy ./build --token=${{ secrets.VERCEL_TOKEN }})
          echo "url=$url" >> $GITHUB_OUTPUT

      - name: Comment PR with Preview URL
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: '🎮 **Preview:** ${{ steps.deploy.outputs.url }}'
            })
```

### GitHub Pages

Best for: Free hosting, simple setup, no external accounts.

#### Setup

1. Enable Pages in repo Settings → Pages
2. Set source to GitHub Actions

#### GitHub Actions

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: 4.3.0
          include-templates: true

      - name: Import Project
        run: godot --headless --import --path . --quit || true

      - name: Build Web Export
        run: |
          mkdir -p build
          godot --headless --export-release "Web" ./build/index.html

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload Artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./build

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### itch.io

Best for: Game distribution, community, optional payments.

#### Setup

1. Create account at [itch.io](https://itch.io)
2. Create a new project
3. Install butler CLI: `curl -L https://itch.io/butler | sh`
4. Login: `butler login`

#### Manual Deploy

```bash
# Build
godot --headless --export-release "Web" ./build/index.html

# Push to itch.io
butler push ./build username/game-name:html5
```

#### GitHub Actions

```yaml
      - name: Deploy to itch.io
        run: |
          curl -L https://itch.io/butler | sh
          ~/.butler/butler push ./build ${{ secrets.ITCH_USER }}/${{ secrets.ITCH_GAME }}:html5
        env:
          BUTLER_API_KEY: ${{ secrets.BUTLER_API_KEY }}
```

### Netlify

Best for: Simple deploys, form handling, serverless functions.

```yaml
      - name: Deploy to Netlify
        run: |
          npm i -g netlify-cli
          netlify deploy --dir=./build --prod
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

## Cross-Origin Headers

Web builds require specific headers for SharedArrayBuffer (threading):

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

### Vercel Configuration

Create `vercel.json` in build output:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cross-Origin-Opener-Policy", "value": "same-origin" },
        { "key": "Cross-Origin-Embedder-Policy", "value": "require-corp" }
      ]
    }
  ]
}
```

### GitHub Pages

GitHub Pages doesn't support custom headers. Options:
1. Disable threading in export settings
2. Use Cloudflare Workers for headers
3. Use a different host

## Other Platforms

### Desktop Exports

```bash
# Windows
godot --headless --export-release "Windows Desktop" ./dist/game.exe

# Linux
godot --headless --export-release "Linux" ./dist/game.x86_64

# macOS
godot --headless --export-release "macOS" ./dist/game.app
```

### Mobile Exports

Require additional setup (SDKs, signing):

```bash
# Android (requires Android SDK)
godot --headless --export-release "Android" ./dist/game.apk

# iOS (requires Xcode, macOS only)
godot --headless --export-release "iOS" ./dist/game.ipa
```

## Troubleshooting

### Export Templates Not Found

```bash
# Check Godot version
godot --version

# Install templates via Editor
# Editor → Manage Export Templates → Download and Install
```

### Web Build Shows Black Screen

1. Check browser console for errors
2. Ensure SharedArrayBuffer headers are set
3. Try disabling threading in export settings

### Large Build Size

1. Enable "Compress Textures" in export settings
2. Exclude unused resources
3. Use PCK compression
