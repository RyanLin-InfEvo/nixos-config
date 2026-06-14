{ config, pkgs, inputs, unstable, ... }:
{

  services.syncthing = {
    enable = true;
    user = "ryan";
    dataDir = "/home/ryan/.local/share/syncthing";
    configDir = "/home/ryan/.config/syncthing";

    guiAddress = "127.0.0.1:8384";
  };

  services.ollama = {
    enable = false;
    package = unstable.ollama; #.override { acceleration = "cuda" }
    environmentVariables = {
      OLLAMA_NUM_CTX = "32768";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
    };
  };
}