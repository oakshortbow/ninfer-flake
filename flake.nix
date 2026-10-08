{
  description = "NInfer — C++/CUDA single-GPU (RTX 5090, sm_120a) inference engine, packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      ninfer = pkgs.callPackage ./package.nix { };
    in
    {
      packages.${system} = {
        default = ninfer;
        inherit ninfer;
      };

      apps.${system} = {
        default = {
          type = "app";
          program = "${ninfer}/bin/ninfer-serve";
          meta.description = "NInfer OpenAI/Anthropic-compatible HTTP server (RTX 5090)";
        };
        serve = {
          type = "app";
          program = "${ninfer}/bin/ninfer-serve";
          meta.description = "NInfer OpenAI/Anthropic-compatible HTTP server (RTX 5090)";
        };
        cli = {
          type = "app";
          program = "${ninfer}/bin/ninfer";
          meta.description = "NInfer one-shot CLI generation (RTX 5090)";
        };
        perplexity = {
          type = "app";
          program = "${ninfer}/bin/ninfer-perplexity";
          meta.description = "NInfer offline causal-perplexity scoring (RTX 5090)";
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ ninfer ];
        packages = [
          pkgs.nix-update
          pkgs.python3Packages."huggingface-hub"
        ];
        shellHook = ''
          export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
          if [ -d /run/opengl-driver/lib ]; then
            export LD_LIBRARY_PATH=/run/opengl-driver/lib:$''${LD_LIBRARY_PATH:-}
          fi
          echo "NInfer development shell (CUDA 12.9, sm_120a / RTX 5090)"
          echo "Models: hf download neroued/Qwen3.8-27B-nvfp4-NInfer qwen3_8_27b_nvfp4.ninfer --local-dir ~/models"
          echo "Update source to master HEAD: nix-update -f . --flake packages.x86_64-linux.ninfer --version branch=master"
        '';
      };
    };
}
