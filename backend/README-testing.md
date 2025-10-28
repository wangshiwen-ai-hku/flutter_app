# Backend Testing Guide

## Quick Start

### 1. Set up environment
```bash
cd backend/functions
export GEMINI_API_KEY="your_api_key_here"
# or create a .env file
```

### 2. Test LLM service
```bash
node test-llm.js
```

### 3. Test full backend pipeline
```bash
node test-backend.js
```

### 4. Deploy to Firebase
```bash
firebase deploy --only functions
```

## Test Scripts

### `test-llm.js`
- Tests basic LLM connectivity
- Validates response format
- Quick verification that API key works

### `test-llm.py`
- Python version of LLM test
- Alternative for Python developers
- More detailed error handling

## Debugging Tips

### LLM Issues
- Check API key is set: `echo $GEMINI_API_KEY`
- Verify quota: Check Google AI Studio dashboard
- Test with simple prompt in AI Studio first

### Firebase Issues
- Check Firebase project: `firebase use`
- Verify functions config: `firebase functions:config:get`
- Check logs: `firebase functions:log`

### Flutter Issues
- Clean build: `flutter clean && flutter pub get`
- Run with verbose: `flutter run -v`
- Check device: `flutter devices`

## Development Workflow

1. **Local Testing**: Use `test-backend.js` for quick iteration
2. **LLM Testing**: Use `test-llm.js` when changing prompts
3. **Integration**: Deploy functions and test with Flutter app
4. **Production**: Monitor Firebase logs and error rates

## Mock Data

The test scripts use predefined mock users for consistent testing:
- TestUser: storyteller, night owl
- BookLover: listener, dreamer
- NightWalker: night owl, observer
- StoryWeaver: storyteller, writer

## Environment Variables

Required:
- `GEMINI_API_KEY`: Google Gemini API key

Optional:
- `FIREBASE_PROJECT_ID`: For Firebase testing
- `NODE_ENV`: Set to 'development' for verbose logging
