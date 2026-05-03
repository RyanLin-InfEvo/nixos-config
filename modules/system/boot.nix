{ config, pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;  # 防止在開機選單中編輯 kernel 參數
        configurationLimit = 10;  # 限制保留的開機世代數
      };
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "quiet" "splash" ];
    # blacklistedKernelModules = [ "spd5118" ];
    # Use the latest kernel for best hardware support (i5-14500 / Raptor Lake)
    kernelPackages = pkgs.linuxPackages_zen;
    # Swap file
    kernel.sysctl = {
      "vm.swappiness" = 120;  # Due to zramSwap, pretend to zipRamSwap rather than Drop page cache
      "vm.vfs_cache_pressure" = 50; # Dirs and Files will stay in Ram for longer time
      "vm.dirty_background_ratio" = 20;
      "vm.dirty_ratio" = 60;
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "32G";
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100; # Ensure priority higher than disk swap
  };
}