Runtime	“Natural” model format	Quantized support	Where it feels most native
LM Studio / llama.cpp	GGUF	Excellent	Consumer/local desktop inference
vLLM	Hugging Face-style checkpoints / safetensors	Excellent for AWQ, GPTQ, FP8, BnB, etc.	GPU server / API inference
vLLM + GGUF	GGUF	Yes, but currently experimental	Possible, but not my first choice
GGUF is actually supported by vLLM now, including Q4_K_M-style models, but vLLM's own documentation explicitly calls GGUF support “highly experimental and under-optimized” and says it may be incompatible with other features. It now uses the vllm-gguf-plugin.
So for your infrastructure, I would not think of quantization as synonymous with GGUF.
For vLLM, I'd favor something like:
FP8 > AWQ/GPTQ > BitsAndBytes > GGUF
