Help me create a NEW app in OpenAI's apps portal for "ThunderPhone Calls" and record its demo. Use my signed-in Chrome. Stop and ask me before any attestation checkbox, any "Submit for review", any OAuth consent screen, and anything that deletes, replaces or edits the existing "ThunderPhone" plugin (asdk_app_6ac538f379848191b06f48cdf910de4b). That one is a separate app; don't touch it. Don't enter passwords; I type those myself.

0. Check the server is live:
   curl -s -X POST https://api.thunderphone.com/v1/consumer-mcp -H 'content-type: application/json' -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | python3 -m json.tool | grep '"name"'
   Expect find_business, call_business, get_call_result. If you get 404 or fewer tools, stop and tell me.
   Then get the materials:
   rm -rf /tmp/tp && git clone --depth 20 https://github.com/autophonix/thunderphone /tmp/tp
   Everything below comes from /tmp/tp/agent-skills/calls-app/submission-materials.json (call it "the materials").

1. Create the app. Open https://platform.openai.com/plugins (or wherever the portal lists apps) and create a new app/plugin as the verified ThunderPhone business identity (org-y9gN8mOgBJD4i4ehn8Ar9YH5). Name "ThunderPhone Calls". If it asks for a package ZIP, this app has no skills: choose the MCP-only option. If MCP-only isn't possible, stop and tell me.

2. MCP server: URL https://api.thunderphone.com/v1/consumer-mcp. Authentication: the option that allows both no auth and OAuth ("mixed"/"optional"); if only one can be chosen, pick "No authentication" and tell me. If it asks for domain verification, copy the challenge token, stop, and give it to me exactly; I'll have it published, then you click Verify.
   Scan the tools. Expect 3. For each, paste the justification from the materials (mcp.toolAnnotationJustifications). Report any flag word for word.

3. Listing: fill name, short and long description, category, website, support email, privacy and terms URLs, logo, starter prompts, availability (US) from the materials. Logo: /tmp/tp/landing/public/brand/ thunderbolt mark on white; if the portal needs a specific size, make a 512x512 PNG with sips. Before saving, open both legal URLs and confirm they load (not 404). If either is 404, stop and tell me.

4. Testing tab: add the 3 positive and 3 negative test cases from the materials, and paste reviewerNotes where it asks for reviewer instructions. No test credentials are needed (no account). Release notes: "First release."

5. Demo video. In ChatGPT (chatgpt.com, my account), Settings → Apps → Advanced → Developer mode ON; Create app: name "ThunderPhone Calls (dev)", URL https://api.thunderphone.com/v1/consumer-mcp, auth "No authentication" (or mixed). Then, in a new chat with the app enabled, run each test prompt from the materials in order. Approve tool calls when ChatGPT asks. Wait for each call result. Record the whole thing as a screen recording of the Chrome tab (the same way the ThunderPhone plugin demo was made in September: Chrome-extension capture segments stitched with ffmpeg into one MP4, at most ~5 minutes). Real-business test: skip it; use only ThunderPhone Demo Bistro for calls.
   Save as ~/Desktop/thunderphone-calls-demo.mp4. Host it the way the September plugin demo was hosted (az CLI, storage account stthunderphoneprod, container '$web', an unlisted path review/<random 24 chars>/thunderphone-calls-demo.mp4, content type video/mp4; it's served at https://cdn.thunderphone.com/review/<same path>). Check the URL plays, then paste it as the demo recording URL on the Info tab. If az isn't signed in, stop and tell me.

6. Stop before submitting. Leave the attestations and "Submit for review" to me, and show me the page.

At the end, give me a short report to paste into my VM session: the new app's id, the auth option chosen, the domain verification token if one was shown, the tool scan count and any flags, which fields you couldn't fill, the video length and path, and any test case that didn't behave as the materials say (word for word).
