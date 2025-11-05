# Hugging Face Gradio Space Deployment Guide

## 📋 Prerequisites

1. **Hugging Face Account**: Create an account at [huggingface.co](https://huggingface.co/)
2. **Godot 4.3**: Install from [godotengine.org](https://godotengine.org/)
3. **Git LFS**: Install Git Large File Storage
   ```bash
   # Ubuntu/Debian
   sudo apt-get install git-lfs

   # macOS
   brew install git-lfs

   # Windows (via Git for Windows)
   # Included in Git for Windows installer
   ```
4. **AWS Credentials** (optional): For AI-powered NPC dialogues

## 🎮 Step 1: Export Godot Game to HTML5

### 1.1 Open the Project in Godot

1. Launch Godot 4.3
2. Open the project by selecting `/home/user/aws-game-hackathon/project.godot`

### 1.2 Configure Web Export

The export preset is already configured in `export_presets.cfg`, but you need to:

1. Go to **Project → Export**
2. Select the **Web** preset
3. Click **Export Project**
4. Choose export location: Create a folder named `game` in your project root
5. Save as `index.html` inside the `game` folder
6. Ensure these files are exported:
   - `index.html`
   - `*.js` files
   - `*.wasm` files
   - `*.pck` files
   - Any audio/asset files

### 1.3 Verify Export

Your project structure should look like:
```
aws-game-hackathon/
├── app.py
├── requirements.txt
├── HF_README.md
├── .gitattributes
├── game/
│   ├── index.html
│   ├── index.js
│   ├── index.wasm
│   ├── index.pck
│   └── index.audio.worklet.js
└── ... (other project files)
```

## 🚀 Step 2: Create Hugging Face Space

### 2.1 Create a New Space

1. Go to [huggingface.co/new-space](https://huggingface.co/new-space)
2. Fill in the details:
   - **Space name**: `shadows-of-tomorrow` (or your preferred name)
   - **License**: MIT
   - **Select SDK**: Gradio
   - **Space hardware**: CPU basic (free tier)
   - **Visibility**: Public or Private

### 2.2 Clone the Space Repository

After creating the space, clone it locally:

```bash
# Clone your new space
git clone https://huggingface.co/spaces/YOUR_USERNAME/shadows-of-tomorrow
cd shadows-of-tomorrow

# Initialize Git LFS
git lfs install
```

## 📦 Step 3: Prepare Files for Upload

### 3.1 Copy Files to Space Repository

Copy the following files from your Godot project to the cloned Space directory:

```bash
# Navigate to your space directory
cd /path/to/shadows-of-tomorrow

# Copy essential files
cp /home/user/aws-game-hackathon/app.py .
cp /home/user/aws-game-hackathon/requirements.txt .
cp /home/user/aws-game-hackathon/.gitattributes .

# Rename HF_README.md to README.md for the space
cp /home/user/aws-game-hackathon/HF_README.md README.md

# Copy the exported game folder
cp -r /home/user/aws-game-hackathon/game .

# Optional: Copy game assets for reference
cp /home/user/aws-game-hackathon/icon.svg .
cp -r /home/user/aws-game-hackathon/gameclips .
```

### 3.2 Update app.py (Important!)

The `app.py` needs a small modification for the iframe to work correctly in Hugging Face Spaces.

Replace the iframe line in `app.py`:

**OLD:**
```python
src="file=game/index.html"
```

**NEW:**
```python
src="game/index.html"
```

Or use this complete HTML block:
```python
gr.HTML("""
<div style="display: flex; justify-content: center; align-items: center; padding: 20px;">
    <iframe
        src="game/index.html"
        width="1920"
        height="1080"
        style="border: 2px solid #333; border-radius: 8px; background: #000;"
        allow="autoplay; fullscreen; cross-origin-isolated"
        allowfullscreen>
    </iframe>
</div>
""")
```

## 🔐 Step 4: Configure AWS Credentials (Optional)

If you want AI-powered NPC dialogues to work:

### 4.1 Add Secrets to Hugging Face Space

1. Go to your Space settings: `https://huggingface.co/spaces/YOUR_USERNAME/shadows-of-tomorrow/settings`
2. Navigate to **Repository secrets**
3. Add the following secrets:
   - **Name**: `AWS_ACCESS_KEY_ID`
     **Value**: Your AWS access key
   - **Name**: `AWS_SECRET_ACCESS_KEY`
     **Value**: Your AWS secret access key

### 4.2 Update app.py to Use Hugging Face Secrets

Hugging Face Spaces automatically loads secrets as environment variables, so the current `app.py` should work as-is. The code already uses:

```python
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
```

## 📤 Step 5: Push to Hugging Face

### 5.1 Track Large Files with Git LFS

```bash
# Make sure Git LFS is tracking the right files
git lfs track "game/*.wasm"
git lfs track "game/*.pck"
git lfs track "game/*.data"
git lfs track "*.js"
```

### 5.2 Commit and Push

```bash
# Add all files
git add .

# Commit
git commit -m "Initial deployment of Shadows of Tomorrow game"

# Push to Hugging Face
git push origin main
```

## ✅ Step 6: Verify Deployment

1. Wait for the Space to build (usually 2-5 minutes)
2. Visit your Space: `https://huggingface.co/spaces/YOUR_USERNAME/shadows-of-tomorrow`
3. Test the game by clicking inside the game iframe
4. Test the AI Dialogue Tester tab if you configured AWS credentials

## 🐛 Troubleshooting

### Game Doesn't Load

1. **Check browser console** for errors (F12 → Console)
2. **Verify all files exported**: Make sure `.wasm`, `.pck`, and `.js` files are present
3. **CORS issues**: Ensure the iframe src path is correct
4. **File size limits**: Hugging Face free tier has storage limits (check file sizes)

### AI Dialogue Not Working

1. **Check secrets**: Verify AWS credentials are set correctly in Space settings
2. **Check AWS permissions**: Ensure your AWS account has Bedrock access
3. **Region availability**: AWS Bedrock may not be available in all regions
4. **Check logs**: Go to Space settings → Logs to see error messages

### Game Performance Issues

1. **Upgrade Space hardware**: Consider using CPU Basic or better
2. **Optimize game export**: Reduce texture sizes, compress audio
3. **Use Godot export optimization**: Enable compression in export settings

## 🔄 Updating Your Game

When you make changes to your game:

1. Re-export from Godot to the `game` folder
2. Commit and push changes:
   ```bash
   git add game/
   git commit -m "Update game build"
   git push origin main
   ```
3. The Space will automatically rebuild

## 📊 Optional: Enable Space Analytics

1. Go to Space settings
2. Enable **Analytics** to track visitors and usage

## 🎨 Customization

### Change Space Appearance

Edit the YAML frontmatter in `README.md`:

```yaml
---
title: Your Game Title
emoji: 🎮
colorFrom: purple
colorTo: blue
---
```

### Add Custom Styling

Modify the Gradio interface in `app.py`:

```python
with gr.Blocks(title="Your Title", theme=gr.themes.Soft()) as demo:
    # Your interface code
```

## 📚 Additional Resources

- [Hugging Face Spaces Documentation](https://huggingface.co/docs/hub/spaces)
- [Gradio Documentation](https://gradio.app/docs/)
- [Godot HTML5 Export Guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Git LFS Documentation](https://git-lfs.github.com/)

## 🆘 Getting Help

- **Hugging Face Community**: [discuss.huggingface.co](https://discuss.huggingface.co/)
- **Godot Community**: [godotengine.org/community](https://godotengine.org/community)
- **GitHub Issues**: [Your repository issues page]

## 📝 Notes

- **Free tier limitations**: Hugging Face free Spaces may have CPU/memory limits
- **Persistent storage**: Data in Spaces is temporary; game saves won't persist between sessions
- **Build time**: Initial build may take longer due to large game files
- **Browser compatibility**: Test on Chrome, Firefox, and Safari

---

Good luck with your deployment! 🚀
