---
title: Shadows of Tomorrow
emoji: 🎮
colorFrom: purple
colorTo: blue
sdk: gradio
sdk_version: "4.0.0"
app_file: app.py
pinned: false
license: mit
---

# Shadows of Tomorrow 🎮

![Game Icon](icon.svg)

## 🌟 Play the Game

An immersive RPG adventure set in post-nuclear 2200, built with Godot 4.3 and powered by Google Gemini AI (100% FREE!).

### Game Controls
- **WASD / Arrow Keys**: Move
- **E**: Interact
- **Left Mouse Click**: Shoot
- **Tab**: Toggle Inventory

## 📖 Story

In the year 2200, a catastrophic nuclear disaster ravages the world, wiping out 80% of the global population. The surviving remnants of humanity take refuge in the Magnus Province, led by the Nova Force. As a survivor, you must:

- Search for medicinal plants in the forest
- Create medicine from collected ingredients
- Interact with AI-powered NPCs
- Help cure diseases and rebuild civilization

## 🤖 AI-Powered Features

This game features dynamic NPC dialogues powered by **Google Gemini 1.5 Flash** - completely FREE! NPCs engage in meaningful conversations about:

- Real-world issues: consequences of war, renewable energy, environmental concerns
- Game world lore: history, Nova Force, and surviving populations
- Contextual information: hints, clues, and world-building
- Emotional intelligence: empathy and natural interactions

## 🛠️ Technology Stack

### Game Development
- **Godot 4.3** - Game engine
- **GDScript** - Game logic

### AI & Cloud Services
- **Google Gemini 1.5 Flash** - NPC dialogue generation (100% FREE!)
- **Hugging Face Spaces** - Free hosting platform
- **AWS Q Developer** - Code assistance

### Content Generation
- **FLUX-dev** - Image generation
- **ElevenLabs** - Audio generation
- **Suno AI** - Background music
- **Notebook LM** - Learning and documentation

## 🎮 Gameplay Features

- Explore the post-nuclear world of Magnus Province
- Collect plants and craft medicine
- Dynamic inventory system
- AI-powered NPC interactions
- Multiple locations: hospitals, farms, forests
- Story-driven gameplay

## 🚀 Deployment

This Space hosts the Godot game as an HTML5 export and provides an AI dialogue testing interface.

### Configuration

To enable Google Gemini AI features, set the following secret in your Hugging Face Space settings:

1. Get your free API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Go to Space Settings → Repository secrets
3. Add this secret:
   - **Name**: `GEMINI_API_KEY`
   - **Value**: Your Gemini API key from Google AI Studio

Without this API key, the game will use mock responses for NPC dialogues.

**Note**: Google Gemini has a generous free tier - no credit card required!

## 📂 Repository Structure

```
.
├── app.py                  # Gradio interface
├── requirements.txt        # Python dependencies
├── game/                   # Exported Godot game (HTML5)
│   ├── index.html
│   ├── *.js
│   ├── *.wasm
│   └── *.pck
├── project.godot          # Godot project file
├── scenes/                # Game scenes
├── scripts/               # GDScript files
├── audio/                 # Audio assets
├── characters/            # Character sprites
└── tilesets/              # Map tiles
```

## 🎯 Future Features

Planned features that weren't implemented due to time constraints:

- Radio communication system between NPCs across towns
- Player cooking and hunger mechanics
- Trading system between players and NPCs
- More interior locations to explore

## 📝 Credits

Created for the AWS Game Hackathon by the development team.

## 💡 Why This Stack?

- **100% Free**: Google Gemini API + Hugging Face Spaces = No costs!
- **No Docker needed**: Gradio SDK handles everything automatically
- **No credit card required**: Both services offer generous free tiers
- **Easy setup**: Just add your Gemini API key and deploy!

## 🔗 Links

- [GitHub Repository](https://github.com/Reubencfernandes/aws-game-hackathon)
- [Google AI Studio](https://makersuite.google.com/app/apikey) - Get your free API key
- [Hugging Face Spaces](https://huggingface.co/spaces) - Free hosting

## 📄 License

MIT License - See LICENSE file for details
