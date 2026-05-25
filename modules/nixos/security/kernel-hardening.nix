{ config, lib, ... }:

{
  security.protectKernelImage = true;
  security.lockKernelModules = true;
}
