| Option / SDK          | Purpose / Use Case                                      | API Key Location                     | Navigation to API Key in Azure Portal                                                   |
|-----------------------|----------------------------------------------------------|---------------------------------------|------------------------------------------------------------------------------------------|
| Foundry SDK           | Build apps with agents, evaluations, Foundry features    | Foundry resource keys                 | Azure Portal → Your Foundry Resource → Resource Management → Keys & Endpoint            |
| OpenAI SDK            | Use latest OpenAI API features, Chat Completions         | Azure OpenAI resource keys            | Azure Portal → Your Azure OpenAI Resource → Keys & Endpoint                             |
| Foundry Tools SDKs    | Use specific AI services (Vision, Speech, etc.)          | Service‑specific keys                 | Azure Portal → Specific AI service resource → Keys & Endpoint                           |
| Agent Framework       | Multi‑agent orchestration in code (local)                | Foundry SDK project endpoint keys     | Azure Portal → Your Foundry Resource → Resource Management → Keys & Endpoint            |


How to get your API key in Azure Portal (condensed navigation tree):
Sign in to Azure Portal 
Go to Resource groups or use the search bar to find your AI resource:
For Foundry: Search your Foundry resource name
For Azure OpenAI: Search your Azure OpenAI resource name
Select your resource
In the left menu, select Resource Management or directly Keys & Endpoint
Copy either KEY1 or KEY2 under the Keys section
Use this key as your API key for authentication in your code or agent configuration
Notes:
You can use either key (KEY1 or KEY2) and rotate them as needed.
The endpoint URL is also found in the same section and is required for API calls.
Authentication can also be done via Microsoft Entra ID (managed identity) if preferred.
For agents, use the project endpoint with Foundry SDK and authenticate with the API key or token.

1:1 setup azure ai to cursor: https://www.youtube.com/watch?v=aVfH9KjWRqU
Yes, you can absolutely "wire up" your student tokens from Azure to use in Cursor. This is a great way to save money and use up those credits before they expire.

To do this, you’ll use Cursor's "Bring Your Own Key" (BYOK) feature. Instead of using Cursor's built-in subscription (where they handle the billing), you tell Cursor to send requests directly to your Azure OpenAI endpoint.

1. Prerequisites (Azure Side)
Before heading to Cursor settings, make sure you have the following ready from your Azure Portal or Azure AI Foundry (formerly AI Studio):

Azure OpenAI API Key: Found under "Keys and Endpoint" in your resource.

Azure Endpoint URL: It usually looks like https://your-resource-name.openai.azure.com/.

Deployment Name: The specific name you gave your model (e.g., if you deployed GPT-4o and named it my-gpt4-deployment, you need that exact string).

2. How to Configure Cursor
Open Cursor Settings (the gear icon in the top right, or Cmd + Shift + J / Ctrl + Shift + J).

Go to the Models tab.

Scroll down to the Azure Integration section (you may need to expand it).

Enter your details:

API Key: Paste your Azure key.

Base URL: Paste your Azure Endpoint (e.g., https://example.openai.azure.com/).

Deployment Name: Enter the name of the model you deployed.

Important: Click Verify. If it works, the status will turn green.

Key Things to Watch Out For
Model Compatibility: If you are using the student credits, you are likely limited to specific models like GPT-4o or GPT-3.5-Turbo. Ensure you have actually "Deployed" these in the Azure portal first.

Pricing/Usage: Once you enable your own key, Cursor will stop using your "Pro" or "Free" monthly messages and start billing your Azure account directly. Since you have student credits, it will simply deduct from that "1 million token" (or $100 credit) balance.

Cursor Tab vs. Chat: Using your own API key works perfectly for Chat (Cmd/Ctrl + L) and Edit (Cmd/Ctrl + K). However, some specialized features like "Cursor Tab" (copilot-style autocomplete) might still require a Cursor subscription as they use specialized small models that aren't available via standard Azure endpoints.

Why you might see "Errored, Not Charged"
If you check your Cursor dashboard and see "Errored, Not Charged" while using your Azure key, don't panic! This actually means the setup is working—it's Cursor's way of saying they didn't bill you because the request went through your provider instead.

Azure OpenAI with Cursor setup

This video provides a step-by-step visual guide on how to navigate the Cursor settings menu specifically to input your Azure API credentials.

Would you like me to help you find the specific Azure Portal pages where your API keys and Deployment names are located?