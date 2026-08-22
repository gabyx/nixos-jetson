{ ... }:
{
  hardware.nvidia-jetpack.enable = true;
  hardware.nvidia-jetpack.som = "thor-agx";
  hardware.nvidia-jetpack.carrierBoard = "devkit";

  # Enable GPU support - needed even for CUDA and containers
  hardware.graphics.enable = true;
}
