{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  cudaPackages,
  ffmpeg,
  curl,
  autoAddDriverRunpath,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "ninfer";
  version = "git-${builtins.substring 0 8 src.rev}";

  cuda = cudaPackages.cudatoolkit;

  src = fetchFromGitHub {
    owner = "Neroued";
    repo = "ninfer";
    rev = "68c54356fd490ab329bd1475d48957f886bb7dd1";
    hash = "sha256-51aQAUsSqav3HgWGb3zMoDHpg2Grf6miHZERpnNXjvk=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    cudaPackages.cudatoolkit
    autoAddDriverRunpath
  ];

  buildInputs = [
    ffmpeg
    curl
  ];

  cmakeFlags = [
    "-DCMAKE_CUDA_ARCHITECTURES=120a"
    "-DCUDAToolkit_ROOT=${cuda}"
    "-DCMAKE_CUDA_COMPILER=${cuda}/bin/nvcc"
    "-DCMAKE_BUILD_TYPE=Release"
    (lib.cmakeBool "NINFER_BUILD_APPS" true)
    (lib.cmakeBool "BUILD_TESTING" false)
    (lib.cmakeBool "NINFER_BUILD_BENCHMARKS" false)
  ];

  defaultInstallPhase = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 apps/ninfer $out/bin/ninfer
    install -Dm755 apps/ninfer-serve $out/bin/ninfer-serve
    install -Dm755 apps/ninfer-perplexity $out/bin/ninfer-perplexity
    runHook postInstall
  '';

  meta = with lib; {
    description = "From-scratch C++/CUDA inference engine for Qwen3.5/3.6/3.8 Dense/MoE on a single RTX 5090 (sm_120a)";
    homepage = "https://github.com/Neroued/ninfer";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainPrograms = [
      "ninfer"
      "ninfer-serve"
      "ninfer-perplexity"
    ];
  };
})
