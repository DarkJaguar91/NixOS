# Ollama LLM server + Open WebUI.
{
  flake.modules.nixos.server =
    { pkgs, ... }:
    {
      services.ollama = {
        enable = true;
        # hydra doesn't cache CUDA builds, so the first rebuild compiles this
        #
        # nixpkgs' setupCudaHook auto-populates CUDAToolkit_ROOT from
        # buildInputs/nativeBuildInputs that carry an
        # `include-in-cudatoolkit-root` marker — cuda_nvcc's own output
        # doesn't carry that marker, so nvcc never ends up in the list even
        # though it's a nativeBuildInput. llama.cpp's CMake check requires
        # nvcc to be found under one of the CUDAToolkit_ROOT entries (unlike
        # stock FindCUDAToolkit, it won't fall back to PATH), so the build
        # fails with "Could not find nvcc". Prepend nvcc's own path so it's
        # in the list; setupCudaHook appends the rest after it.
        package = pkgs.ollama-cuda.overrideAttrs (old: {
          env = old.env // {
            CUDAToolkit_ROOT = "${pkgs.lib.getBin pkgs.cudaPackages.cuda_nvcc}";
          };
        });
        host = "0.0.0.0";
        openFirewall = true; # 11434 — speaks the Anthropic Messages API too,
        # so claude-code on the laptop can point ANTHROPIC_BASE_URL at it

        # a static user instead of the module's DynamicUser default, so state
        # can live on /fast (systemd won't chown mounts over /var/lib/private —
        # same trap that keeps prowlarr on the root disk)
        user = "ollama";
        group = "ollama";
        home = "/fast/appdata/ollama";
        modelsDir = "/fast/appdata/ollama/models";

        loadModels = [
          "gpt-oss:20b" # ~13GB MoE — primary; fully fits in VRAM
          "qwen3:14b" # ~9GB — dense all-rounder
          "qwen3.6:35b-a3b" # MoE; 35B total / 3.6B active — fits in VRAM
          "qwen3-coder:30b" # ~19GB MoE — spills to CPU, testing only
          "qwen2.5-coder:14b" # ~9GB — testing only
          "qwen3-embedding:0.6b" # ~639MB — embeddings for RAG/search
        ];

        environmentVariables = {
          # claude-code needs >=32K context to be usable; flash attention with a
          # q8 KV cache halves the cache so 32K fits next to gpt-oss's weights
          # in the RTX 2000 Ada's 16GB
          OLLAMA_CONTEXT_LENGTH = "32768";
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KV_CACHE_TYPE = "q8_0";
        };
      };

      systemd.tmpfiles.rules = [ "d /fast/appdata/ollama 0755 ollama ollama -" ];

      services.open-webui = {
        enable = true;
        host = "0.0.0.0";
        port = 8083; # 8080 is SABnzbd
        openFirewall = true;
        environment = {
          OLLAMA_BASE_URL = "http://127.0.0.1:11434";
          # setting this option replaces its defaults, so restate the
          # telemetry opt-outs
          SCARF_NO_ANALYTICS = "True";
          DO_NOT_TRACK = "True";
          ANONYMIZED_TELEMETRY = "False";
        };
      };
    };
}
