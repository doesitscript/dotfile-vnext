#!/usr/bin/env node

import { main } from "../../../../ai-resource-library/scripts/ai-library-entry/shared/mcp_tool_client.mjs";

await main(process.argv.slice(2));
