import os
import gradio as gr
import boto3
import json
from dotenv import load_dotenv
import time

load_dotenv()

# Configuration
MOCK_RESPONSE = False
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_REGION = 'us-east-1'
MODEL_ID = "mistral.mistral-large-2402-v1:0"

# Initialize AWS Bedrock client if credentials are available
brt = None
if AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY:
    try:
        brt = boto3.client(
            "bedrock-runtime",
            aws_access_key_id=AWS_ACCESS_KEY_ID,
            aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
            region_name=AWS_REGION
        )
    except Exception as e:
        print(f"Warning: Could not initialize AWS Bedrock client: {e}")

def get_ai_response(prompt):
    """Generate AI response using AWS Bedrock"""
    try:
        if not prompt:
            return {"error": "Missing prompt"}

        full_prompt = prompt + ". Strictly respond in plain text, limited to 4 sentences."

        native_request = {
            "prompt": full_prompt,
            "temperature": 0.6,
            "top_p": 0.9
        }

        if MOCK_RESPONSE or not brt:
            time.sleep(1)
            return {
                "output": "Mocked response. Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                         "Mauris lorem ligula, convallis a massa nec, lacinia commodo lectus."
            }

        print(f"Calling AWS Bedrock: model={MODEL_ID}")
        start_time = time.time()
        brt_response = brt.invoke_model(
            modelId=MODEL_ID,
            body=json.dumps(native_request).encode()
        )

        response_body = json.loads(brt_response['body'].read())
        print(f"Took={time.time() - start_time}s")
        output_value = response_body['outputs'][0]['text']

        return {"output": output_value}

    except Exception as e:
        return {"error": str(e)}

# Create the Gradio interface
with gr.Blocks(title="Shadows of Tomorrow - AWS Game Hackathon") as demo:
    gr.Markdown("""
    # 🎮 Shadows of Tomorrow
    ### An RPG Adventure Set in Post-Nuclear 2200

    Welcome to Magnus Province! This game was created with Godot 4.3 and features AI-powered NPC dialogues using AWS Bedrock.

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
        ### Test the AWS Bedrock NPC Dialogue System
        This is the same AI system used for NPC conversations in the game.
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
        - **AWS Bedrock** - AI-powered NPC dialogue (Mistral Large model)
        - **AWS Lambda** - Serverless API hosting
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
