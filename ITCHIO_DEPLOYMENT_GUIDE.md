# 🎮 Deploy Your AI Race Bike Game to itch.io

## Why itch.io?
✅ **100% FREE** - No costs, no limits  
✅ **No file size limits** - Handles your 38MB WASM perfectly  
✅ **No compression hacks needed** - itch.io handles everything  
✅ **Built for games** - Designed specifically for game developers  
✅ **Instant playable** - Games run directly in browser  

---

## 📦 Your Game is Ready!

**File:** `ai-race-bike-game-itchio.zip` (9.13 MB)  
**Location:** `C:\Users\VASU\Desktop\build\`

---

## 🚀 Step-by-Step Deployment

### Step 1: Create an itch.io Account (if you don't have one)
1. Go to: https://itch.io/register
2. Sign up with your email
3. Confirm your email address

### Step 2: Create a New Project
1. Go to your Creator Dashboard: https://itch.io/dashboard
2. Scroll down and click **"Create new project"**
3. Fill in the project details:

   **Required Fields:**
   - **Title:** `AI Race Bike Game` (or your preferred name)
   - **Project URL:** `yourname.itch.io/ai-race-bike-game`
   - **Short description:** `2D side-scrolling bike racing game with physics-based gameplay`
   - **Kind of project:** ⚠️ **IMPORTANT: Select "HTML"** (not Downloadable)

   **Recommended Fields:**
   - **Classification:** Game
   - **Genre:** Racing, Action
   - **Tags:** racing, bike, 2d, side-scrolling, physics, arcade
   - **Release status:** Released or In development
   - **Pricing:** $0 or donate (free)

### Step 3: Upload Your Game
1. Scroll down to the **"Uploads"** section
2. Click **"Upload files"**
3. Select `ai-race-bike-game-itchio.zip` from your Desktop/build folder
4. Wait for upload to complete
5. Once uploaded, check the box that says **"This file will be played in the browser"**

### Step 4: Configure Embed Settings
1. After checking "played in the browser", new options will appear
2. Set the viewport dimensions:
   - **Width:** `1024` (or leave default)
   - **Height:** `600` (or leave default)
   - **Orientation:** Landscape
   - **Fullscreen button:** ✅ Enable
   - **Mobile friendly:** ✅ Enable

### Step 5: Add Details (Optional but Recommended)
1. **Cover Image:** Upload a screenshot or logo (at least 630x500px)
2. **Screenshots:** Add 3-5 gameplay screenshots
3. **Description:** Write a detailed description of your game:
   ```
   Race through challenging tracks in this 2D side-scrolling bike racing game!
   
   🏍️ Features:
   - Realistic bike physics
   - Smooth controls
   - Dynamic camera following
   - Speed and stamina system
   
   🎮 Controls:
   - Right Arrow: Accelerate
   - Left Arrow: Brake
   - Space: Jump
   
   Built with Godot 4.5.1
   ```

### Step 6: Set Visibility
1. Scroll to **"Visibility & access"**
2. Choose one:
   - **Public:** Anyone can find and play
   - **Restricted:** Only people with link
   - **Private:** Only you (for testing)

### Step 7: Save and Publish!
1. Scroll to the bottom
2. Click **"Save & view page"** or **"Save"**
3. Your game is now live! 🎉

---

## 🌐 Your Game URL
After publishing, your game will be available at:
```
https://yourname.itch.io/ai-race-bike-game
```

---

## 🎯 Testing Your Game
1. Visit your game's URL
2. Click the "Run game" button
3. Your game should load and run perfectly in the browser!

---

## 💡 Pro Tips

### If the game doesn't load:
1. Make sure **"This file will be played in the browser"** is checked
2. Verify the zip contains `index.html` at the root
3. Try uploading again or clearing browser cache

### To update your game:
1. Export new build with Godot
2. Create new zip file
3. Go to your itch.io project dashboard
4. Delete old upload
5. Upload new zip file
6. Click "Save"

### Promote your game:
- Share the link on social media
- Post on Reddit r/godot
- Submit to game jams on itch.io
- Ask friends to rate/review

---

## 🛠️ Quick Re-Deploy Script

### Easy Way (Recommended)
Just **double-click** `redeploy-itchio.ps1` - it will:
- ✅ Re-export your game
- ✅ Create new zip file
- ✅ Show you next steps
- ✅ Optional: Open folder for easy upload

### Manual Way
If you prefer, run this in PowerShell:

```powershell
# From your project folder:
cd C:\Users\VASU\Desktop\build

# Re-export
& "C:\Users\VASU\Downloads\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe" --headless --export-release "Web" "web-build/index.html"

# Create new zip
Remove-Item "ai-race-bike-game-itchio.zip" -Force
Compress-Archive -Path "web-build\*" -DestinationPath "ai-race-bike-game-itchio.zip" -Force

Write-Host "✓ New build ready for itch.io upload!" -ForegroundColor Green
```

Then manually upload the new zip to itch.io.

---

## 🎊 Success!

Your game is now:
- ✅ Hosted on a **professional game platform**
- ✅ **100% FREE** forever
- ✅ **Playable instantly** in any browser
- ✅ **No technical barriers** for players
- ✅ **Shareable** with a simple URL

**Enjoy sharing your game with the world!** 🚀🎮
