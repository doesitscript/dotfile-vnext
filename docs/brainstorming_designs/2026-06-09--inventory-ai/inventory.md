"deepreinforce-ai/Ornith-1.0-35B-GGUF"
"experiment"
"code-review"
"default"

{
  "id": "deepreinforce-ai/Ornith-1.0-35B-GGUF",
  "object": "model",
  "created": 1677610602,
  "owned_by": "openai"
}

curl -s -o /dev/null -w '%{http_code}\n' -H 'Authorization: Bearer sk-Pass@w0rd1' -H 'Content-Type: application/json' http://litellm.hom.lab/v1/chat/completions -d '{"model":"deepreinforce-ai/Ornith-1.0-35B-GGUF","messages":[{"role":"user","content":"Reply with only the word READY."}],"max_tokens":8}
curl -s -H 'Authorization: Bearer sk-Pass@w0rd1' http://litellm.hom.lab/v1/models | jq '.data[]?.


curl -s -H 'Authorization: Bearer sk-Pass@w0rd1' -H 'Content-Type: application/json' http://litellm.hom.lab/v1/chat/completions -d '{"model":"deepreinforce-ai/Ornith-1.0-35B-GGUF","messages":[{"role":"user","content":"Reply with only the word READY."}],"max_tokens":8}

{"error":{"message":"litellm.InternalServerError: InternalServerError: Hosted_vllmException - Cannot connect to host vllm-primary.vllm-runtime.svc.cluster.local:8000 ssl:<ssl.SSLContext object at 0x7151196bf250> [Connect call failed ('10.43.128.30', 8000)]. Received Model Group=deepreinforce-ai/Ornith-1.0-35B-GGUF\nAvailable Model Group Fallbacks=None","type":null,"param":null,"code":"500"}}
