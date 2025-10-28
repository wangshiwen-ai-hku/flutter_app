# Backend Cloud Functions

This directory contains the backend logic for the application, implemented as Firebase Cloud Functions written in TypeScript.

## Quick Start & Deployment

### 1. Prerequisites

- You must have a Firebase project created. [Go to Firebase Console](https://console.firebase.google.com/)
- You must have Node.js (version 18 or higher) installed.
- You must have Python 3.7+ installed (for testing scripts).
- Install the Firebase CLI globally: `npm install -g firebase-tools`

### 2. Installation

Navigate to this directory and install the dependencies:

```bash
npm install
```

### 3. Configuration: Setting the Gemini API Key

To protect your API key, we use Firebase's environment configuration. **Do not hardcode your key in the source code.**

Run the following command in your terminal, replacing `YOUR_API_KEY` with your actual Google AI Gemini API key:

```bash
firebase functions:config:set gemini.key="YOUR_API_KEY"
```

This command securely stores your key in your Firebase project's environment.

### 4. Testing LLM Integration

Before deploying, test your Gemini API key with our test scripts:

#### Using uv (Fastest - Recommended)
```bash
# Quick setup (recommended)
./setup-uv.sh

# Or manually:
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Sync dependencies (automatically creates virtual environment)
uv sync

# Set your API key
export GEMINI_API_KEY="your_api_key_here"

# Run the test
uv run python test-llm.py
```

The setup script will:
- Install uv if not present
- Create a Python virtual environment
- Install all required dependencies


#### Using pip (Alternative)
```bash
# Install the Python SDK
pip install -r requirements.txt
# or manually: pip install google-generativeai

# Set your API key
export GEMINI_API_KEY="your_api_key_here"

# Run the test
python test-llm.py
```

#### Using Node.js
```bash
# Install dotenv for environment variables
npm install dotenv

# Set your API key
export GEMINI_API_KEY="your_api_key_here"

# Run the test
npm run test-llm
```

### 5. Deployment

To deploy the functions to your Firebase project, run:

```bash
firebase deploy --only functions
```

## How to View Logs for Debugging

All prompts and responses to the LLM service are logged to Google Cloud Logging. You can view them in two ways:

1.  **Via Firebase Console (Recommended for UI)**:
    - Go to your Firebase project in the console.
    - Navigate to the "Functions" section from the left menu.
    - Click on the "Logs" tab.
    - You can filter logs by function name (e.g., `getMatches`).

2.  **Via Firebase CLI (For real-time logging)**:
    - To see logs as they happen, run the following command in your terminal:

    ```bash
    firebase functions:log
    ```

    - To view logs for a specific function, you can add the `--only` flag:

    ```bash
    firebase functions:log --only getMatches
    ```
