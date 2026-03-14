What Cursor is asking for

In the field you showed:

Deployment Name

Cursor expects one deployment that already exists in Azure.

Example valid entry:

coder-main

Example invalid entry:

researcher-main planner-fast coder-main reviewer-strict

because those are four deployments and they likely don't exist yet.

Where you create the deployment

In Azure AI Foundry:

Open your project

Go to Models

Pick a model (for example gpt-4o-mini)

Click Deploy

It will ask for:

Deployment name

You type something like:

researcher-main

Then Azure creates an endpoint behind the scenes.

Now Cursor can use that name.

Simple example setup for you

Create one deployment first just to connect Cursor:

Model:

gpt-4o-mini

Deployment name:

coder-main

Then put in Cursor:

Base URL

https://<your-resource>.openai.azure.com

Deployment Name

coder-main

API key

<your azure key>
One honest piece of advice

Don’t build four agents yet.

First just get one deployment working with Cursor.

Once that connection works, we can layer in:

researcher agent

planner agent

coder agent

reviewer agent

Much easier to debug that way.