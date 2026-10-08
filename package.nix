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
    rev = "81c8ce093b2c1646a87566a8e59d807fcf0ec95c";
    hash = "sha256-D+rrNhQ5+cvQu1Ylhlzu36WJZgGLmKydeGLGz8KZ/c8=";
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
    "-DCMAKE_EXE_LINKER_FLAGS=-L${stdenv.cc.cc.lib}/lib"
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
