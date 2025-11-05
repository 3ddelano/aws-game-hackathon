import os
import gradio as gr
import google.generativeai as genai
from dotenv import load_dotenv
import time

load_dotenv()

# Configuration
MOCK_RESPONSE = False
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

# Model options:
# - "gemini-1.5-flash" (fast and free, recommended)
# - "gemini-1.5-pro" (more capable, also free with limits)
# - "gemini-1.0-pro" (older but stable)
MODEL_ID = "gemini-1.5-flash"

# Configure Gemini API
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

def get_ai_response(prompt):
    """Generate AI response using Google Gemini API"""
    try:
        if not prompt:
            return {"error": "Missing prompt"}

        full_prompt = prompt + ". Strictly respond in plain text, limited to 4 sentences."

        if MOCK_RESPONSE or not GEMINI_API_KEY:
            time.sleep(1)
            return {
                "output": "Mocked response. Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                         "Mauris lorem ligula, convallis a massa nec, lacinia commodo lectus. "
                         "(Note: Set GEMINI_API_KEY to enable real AI responses. Get your free API key at https://makersuite.google.com/app/apikey)"
            }

        print(f"Calling Google Gemini API: model={MODEL_ID}")
        start_time = time.time()

        # Create the model
        model = genai.GenerativeModel(MODEL_ID)

        # Configure generation parameters
        generation_config = {
            "temperature": 0.6,
            "top_p": 0.9,
            "max_output_tokens": 200,
        }

        # Generate response
        response = model.generate_content(
            full_prompt,
            generation_config=generation_config
        )

        print(f"Took={time.time() - start_time:.2f}s")

        if response.text:
            return {"output": response.text}
        else:
            return {"error": "No response from AI model"}

    except Exception as e:
        return {"error": f"Gemini API error: {str(e)}"}

# Create the Gradio interface
with gr.Blocks(title="Shadows of Tomorrow - AWS Game Hackathon") as demo:
    gr.Markdown("""
    # 🎮 Shadows of Tomorrow
    ### An RPG Adventure Set in Post-Nuclear 2200

    Welcome to Magnus Province! This game was created with Godot 4.3 and features AI-powered NPC dialogues using Google Gemini.

    **Game Controls:**
    - WASD / Arrow Keys: Move
    - E: Interact
    - Left Mouse Click: Shoot
    - Tab: Toggle Inventory

    **About the Game:**
    In the year 2200, a catastrophic nuclear disaster ravages the world. As a survivor in Magnus Province,
    you'll search for plants, create medicine, and help cure NPCs from various diseases.
    """)

    with gr.Tab("🎮 Play Game"):
        gr.HTML("""
        <div style="display: flex; justify-content: center; align-items: center; padding: 20px;">
            <iframe
                src="file=game/index.html"
                width="1920"
                height="1080"
                style="border: 2px solid #333; border-radius: 8px; background: #000;"
                allow="autoplay; fullscreen"
                allowfullscreen>
            </iframe>
        </div>
        <style>
            iframe {
                max-width: 100%;
                max-height: 80vh;
            }
        </style>
        """)

        gr.Markdown("""
        ### 📝 Note
        If the game doesn't load immediately, please refresh the page. Make sure to click inside the game area to capture keyboard inputs.
        """)

    with gr.Tab("🤖 AI Dialogue Tester"):
        gr.Markdown("""
        ### Test the Google Gemini NPC Dialogue System
        This is the same AI system used for NPC conversations in the game.
        Uses Gemini 1.5 Flash - completely FREE with Google AI Studio!
        Get your API key: https://makersuite.google.com/app/apikey
        """)

        with gr.Row():
            with gr.Column():
                prompt_input = gr.Textbox(
                    label="Enter NPC Prompt",
                    placeholder="Example: You are a farmer in Magnus Province. Discuss renewable energy...",
                    lines=5
                )
                submit_btn = gr.Button("Generate Response", variant="primary")

            with gr.Column():
                response_output = gr.JSON(label="AI Response")

        submit_btn.click(
            fn=get_ai_response,
            inputs=[prompt_input],
            outputs=[response_output]
        )

        gr.Examples(
            examples=[
                ["You are Delano, a farmer. Discuss innovative farming methods in a post-nuclear world."],
                ["You are a Nova Force officer. Explain how food security is maintained in Magnus Province."],
                ["You are a scientist. Discuss methods to combat contaminated soil after the nuclear disaster."]
            ],
            inputs=[prompt_input]
        )

    with gr.Tab("📖 About"):
        gr.Markdown("""
        ## Development Tools & Technologies

        This game was created using:
        - **Godot 4.3** - Game Engine
        - **Google Gemini 1.5 Flash** - AI-powered NPC dialogue (100% FREE!)
        - **Hugging Face Spaces** - Free hosting
        - **AWS Q Developer** - GDScript code assistance
        - **FLUX-dev** - Image generation
        - **ElevenLabs** - Audio generation
        - **Suno AI** - Background music

        ## Game Features
        - Explore the post-nuclear world of Magnus Province
        - Search for medicinal plants in forests
        - Craft medicine from collected ingredients
        - Interact with AI-powered NPCs with dynamic dialogue
        - Help cure diseases and rebuild civilization

        ## Technical Highlights
        - **Dynamic NPC Conversations**: NPCs discuss real-world issues like renewable energy,
          consequences of war, and environmental concerns
        - **Contextual Dialogue**: AI responses are tailored to the game's storyline and world
        - **Emotional Intelligence**: NPCs display emotions and empathy in their interactions
        - **100% Free**: Uses Google Gemini's free tier - no API costs!

        ## Credits
        Created for the AWS Game Hackathon

        [GitHub Repository](https://github.com/Reubencfernandes/aws-game-hackathon)
        """)

# Launch the app
if __name__ == "__main__":
    demo.launch(
        server_name="0.0.0.0",
        server_port=7860,
        share=False
    )
