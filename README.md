
# Shadows of Tomorrow
![Game Icon](icon.svg)

## Overview
This game was created using Godot 4 and is an RPG-based game where the player, as the main character, searches for plants in the forest and creates medicine from these plants.

## Repository Structure
```markdown
.
├── server.py
├── components/
├── entities/
├── scenes/
├── scripts/
└── ui/
```

## Game Background
In the year 2200, a catastrophic nuclear disaster ravages the world, wiping out 80% of the global population. The surviving remnants of humanity take refuge in the Magnus Province, led by the Nova Force. This is the backdrop for our game, a thrilling adventure set in a world where survival is a daily struggle.

## Development Journey
[Development](/gameclips/0.png)
As newcomers to Godot, we faced a steep learning curve, especially with our semester exams looming in December. Despite the time constraints, we leveraged AI tools to maximize our productivity. We utilized:

* FLUX-dev for image generation
* Elevenlabs for audio generation
* Notebook LM to quickly grasp concepts, even using an 8-hour YouTube video as input
* Suno AI for creating background music

## Gameplay Images
![Interior](/gameclips/1.png)
![NPC Interaction](/gameclips/2.png)
![NPC sick Dialogue](/gameclips/3.png)
![Inventory](/gameclips/5.png)
![NPC Medicine](/gameclips/6.png)
![Hospital](/gameclips/7.png)
![Farm](/gameclips/8.png)
## Medicine Creation
We also incorporated AWS tools, specifically Amazon Q and Amazon Bedrock, to streamline our development process. Amazon Q proved invaluable in generating Godot 4 scripts, as most LLMs referenced outdated code. Amazon Q, however, produced the latest version of the code, saving us significant time and effort.

## AI-Powered Features
Amazon Lambda was used to create a serverless API that leverages the Bedrock Runtime model to generate human-like text responses to user input prompts, allowing for scalable and cost-effective deployment of AI-powered text generation capabilities.

Amazon Bedrock was used to create engaging NPC conversations using the Mistral.mistral-large-2402-v1:0 model. What sets our NPC conversations apart is that they're not just generic, repetitive phrases. Instead, they:

* Discuss real-world issues: Our NPCs talk about the consequences of war, the importance of renewable energy, and environmental concerns, adding a layer of depth and realism to the game world.
* Reflect the game's storyline: NPCs share stories and insights about the world's history, the Nova Force, and the struggles of the surviving population, making the game's narrative more immersive and engaging.
* Provide contextual information: NPCs offer hints and clues about the game's world, mechanics, and quests, helping players navigate the game and uncover its secrets.
* Exhibit emotional intelligence: Our NPCs display emotions and empathy, making their interactions feel more natural and human-like, which enhances the overall gaming experience.

## Additional Features (Planned but Not Implemented)
Due to time constraints, we were unable to implement the following features, which we had planned to include:

* Communication system: enabling players to interact with NPCs across towns, despite monster disruptions
* Player cooking and hunger system: adding a survival mechanic to the game
* Trading system: allowing players and NPCs to exchange goods between towns
* NPC hospital visits: introducing a new layer of realism to the game world
* More interiors: expanding the game's environments and exploration opportunities

