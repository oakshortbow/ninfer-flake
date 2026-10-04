# ninfer-flake

[NInfer](https://github.com/Neroued/ninfer) packaged for Nix — the from-scratch
C++/CUDA inference engine for Qwen3.5/3.6/3.8 Dense/MoE checkpoints on
**a single RTX 5090** (`sm_120a` only; the upstream CMake rejects any other
architecture).

> **Personal use.** This flake is for my own machine and is generated and
> maintained with an AI coding agent. It is provided as-is and may break
> without notice when inputs move.

Requires x86_64-linux, a GeForce RTX 5090, and a driver supporting `sm_120a`.

## Outputs

| Output | Purpose |
|---|---|
| `packages.x86_64-linux.ninfer` (`.default`) | the three product binaries: `ninfer`, `ninfer-serve`, `ninfer-perplexity` |
| `apps.x86_64-linux.serve` (`.default`) | `nix run .#serve -- <args>` — OpenAI/Anthropic-compatible HTTP server |
| `apps.x86_64-linux.cli` | `nix run .#cli -- <args>` — one-shot CLI generation |
| `apps.x86_64-linux.perplexity` | `nix run .#perplexity -- <args>` — offline perplexity scoring |
| `devShells.x86_64-linux.default` | build shell (the package's build deps + `hf`). **Untested** — see below |

## Usage

```sh
nix build .#ninfer          # or just use the apps directly
```

Fetch a model artifact first (one Hugging Face repo per checkpoint; the
[upstream README](https://github.com/Neroued/ninfer#quick-start) lists them).
`hf` is available in the devshell, or:

```sh
nix run nixpkgs#python3Packages."huggingface-hub" -- \
  download neroued/Qwen3.8-27B-nvfp4-NInfer \
  qwen3_8_27b_nvfp4.ninfer --local-dir ~/models
```

One-shot generation:

```sh
nix run .#cli -- ~/models/qwen3_8_27b_nvfp4.ninfer \
  --prompt "Explain prefill and decode." \
  --max-context 32768 --max-new 8192 --kv-dtype fp8 \
  --spec mtp --draft-tokens 3 --lm-head-draft
```

Long-running OpenAI/Anthropic-compatible server:

```sh
nix run .#serve -- ~/models/qwen3_8_27b_nvfp4.ninfer \
  --host 127.0.0.1 --port 8080 \
  --max-context 240000 --kv-capacity 240000 --max-concurrency 2 \
  --kv-dtype fp8 --device-state-slots 2 \
  --spec mtp --draft-tokens 3 --lm-head-draft --preserve-thinking

curl http://127.0.0.1:8080/health   # -> {"status":"ok"} when ready
```

See the [upstream README](https://github.com/Neroued/ninfer) for the full
flag reference and per-model examples.

## Devshell

```sh
nix develop
```

Supposed to provide the package's build dependencies (CUDA 12.9 toolkit,
ffmpeg, curl, ninja, …, inherited via `inputsFrom`) plus the `hf` CLI for
fetching artifacts. **Untested** beyond a PATH/pkg-config smoke check —
treat it as best-effort.
