curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent" \
  -H 'Content-Type: application/json' \
  -H 'X-goog-api-key: AIzaSyB-937F5kOrpXAdr8CkP_URrH3avAYNa1c' \
  -X POST \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works in a few words"
          }
        ]
      }
    ]
  }'



Provider was unable to process your request
Request failed with status code 400: {"error":{"type":"client","reason":"invalid_input","message":"model is required","retryable":false}}
