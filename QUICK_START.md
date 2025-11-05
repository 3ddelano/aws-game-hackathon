# 🚀 Quick Start Guide - Deploy to Hugging Face

## TL;DR - 5 Steps to Deploy (100% Free!)

### 1️⃣ Export Your Game
```bash
# In Godot 4.3:
# Project → Export → Web → Export Project
# Save to: game/index.html
```

### 2️⃣ Get Your Free Gemini API Key
- Visit: https://makersuite.google.com/app/apikey
- Sign in with Google account
- Click "Create API Key"
- Copy your key

### 3️⃣ Create Hugging Face Space
- Go to: https://huggingface.co/new-space
- Choose SDK: **Gradio**
- Hardware: **CPU basic (free)**
- Clone your new space locally

### 4️⃣ Copy Files & Push
```bash
cd your-space-directory

# Copy files
cp /path/to/your-game/app.py .
cp /path/to/your-game/requirements.txt .
cp /path/to/your-game/.gitattributes .
cp /path/to/your-game/HF_README.md README.md
cp -r /path/to/your-game/game .

# Setup Git LFS
git lfs install
git lfs track "game/*.wasm"
git lfs track "game/*.pck"

# Push to Hugging Face
git add .
git commit -m "Deploy game"
git push origin main
```

### 5️⃣ Add Gemini API Key to Space
1. Go to Space Settings → Secrets
2. Add secret:
   - **Name**: `GEMINI_API_KEY`
   - **Value**: Your Gemini API key

## ✅ That's It!

Your game will be live in 2-5 minutes at:
`https://huggingface.co/spaces/YOUR_USERNAME/your-space-name`

## 💰 Costs

**Total: $0.00** ✨

- ✅ Hugging Face Spaces: Free
- ✅ Google Gemini API: Free
- ✅ No Docker needed: Free
- ✅ No credit card required: Free

## 📚 Detailed Guides

For more details, see:
- **Full deployment guide**: [HUGGINGFACE_DEPLOYMENT.md](HUGGINGFACE_DEPLOYMENT.md)
- **Hugging Face README**: [HF_README.md](HF_README.md)

## 🐛 Troubleshooting

### Game doesn't load?
- Check browser console (F12)
- Verify all game files are in `game/` folder
- Make sure `.wasm`, `.pck`, and `.js` files are committed

### AI not working?
- Check Space logs for errors
- Verify `GEMINI_API_KEY` is set in Space secrets
- Mock responses appear when API key is missing (this is normal for testing!)

## 🆘 Need Help?

- [Hugging Face Community](https://discuss.huggingface.co/)
- [GitHub Issues](https://github.com/Reubencfernandes/aws-game-hackathon/issues)

---

**Happy deploying! 🎮**
