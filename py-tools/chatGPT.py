import os
import sys
from openai import OpenAI

# add this into ~/.bashrc or ~/.zshrc file
# export OPENAI_API_KEY='your-key'


def main():
    # Check if a command-line argument is provided
    if len(sys.argv) < 2:
        print("Usage: python3 chat.py '<message>'")
        return

    # Retrieve the message from command-line arguments
    message = sys.argv[1]

    # Create a client instance with the OpenAI API key
    client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

    # Create a chat completion request
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": message,
            }
        ],
        model="gpt-3.5-turbo",
    )

    # Print the response from the model
    response = chat_completion.choices[0].message.content
    print(response)


if __name__ == "__main__":
    main()
