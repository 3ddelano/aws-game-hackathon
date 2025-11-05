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

An immersive RPG adventure set in post-nuclear 2200, built with Godot 4.3 and powered by AWS Bedrock AI.

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

This game features dynamic NPC dialogues powered by **AWS Bedrock** using the Mistral Large model. NPCs engage in meaningful conversations about:

- Real-world issues: consequences of war, renewable energy, environmental concerns
- Game world lore: history, Nova Force, and surviving populations
- Contextual information: hints, clues, and world-building
- Emotional intelligence: empathy and natural interactions

## 🛠️ Technology Stack

### Game Development
- **Godot 4.3** - Game engine
- **GDScript** - Game logic

### AI & Cloud Services
- **AWS Bedrock** - NPC dialogue generation (Mistral Large 2402 model)
- **AWS Lambda** - Serverless API hosting
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

To enable AWS Bedrock features, set the following secrets in your Hugging Face Space settings:

1. Go to Space Settings → Repository secrets
2. Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

Without these credentials, the game will use mock responses for NPC dialogues.

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

## 🔗 Links

- [GitHub Repository](https://github.com/Reubencfernandes/aws-game-hackathon)
- [AWS Bedrock Documentation](https://aws.amazon.com/bedrock/)

## 📄 License

MIT License - See LICENSE file for details
