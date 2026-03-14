Summary Table
Task	Best Cursor Model	Model ID (as shown in Cursor)
Planner/Implementer	GPT-4o (or GPT-4-Turbo)	gpt-4o / gpt-4-turbo
Researcher	Gemini 2.0 Flash	gemini-2.0-flash
Summarizer/Cleanup passes	GPT-3.5 Turbo or GPT-4o	gpt-3.5-turbo / gpt-4o

#
APIKEY=OPENAI_API_KEY_REDACTED
curl https://api.openai.com/v1/models -H "Authorization: Bearer $APIKEY"