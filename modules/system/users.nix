{ config, pkgs, ... }:

{
  # 定義使用者帳戶 
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    group = "users";
    extraGroups = [
      "wheel"          # sudo
      "networkmanager"
      "video"
      "i2c"
      "input"
      "ydotool"        # 模擬打字
      "audio"
    ];
  };
}