# 自動偵測主機名稱，預設為 ryan-Desktop，若為 ryan-dynabook 則切換
HOSTNAME := $(shell hostname)
ifeq ($(HOSTNAME), ryan-dynabook)
  FLAKE = .\#ryan-dynabook
else
  FLAKE = .\#ryan-Desktop
endif

FLAKE_HOME = .\#ryan

# 預設執行的指令：當你在終端機只輸入 `make` 時，預設執行 `switch`
default: switch

# 僅套用系統更新 (需要 sudo)
switch-sys:
	git add .
	sudo nixos-rebuild switch --flake $(FLAKE)

# 僅套用個人設定 (不需 sudo)
switch-home:
	git add .
	home-manager switch --flake $(FLAKE_HOME) -b backup

# 一鍵全更新
switch-all: switch-sys switch-home

# 測試設定：立即生效，但不會寫入開機選單（重開機後還原）
# 適用場景：測試有風險的設定（例如顯示卡驅動、網路設定）
test:
	git add .
	sudo nixos-rebuild test --flake $(FLAKE)

# 開機套用：寫入開機選單，但當下不生效（需重開機才生效）
# 適用場景：更新 Kernel 核心時
boot:
	git add .
	sudo nixos-rebuild boot --flake $(FLAKE)

# 更新套件庫：更新 flake.lock 中的所有輸入來源（如 nixpkgs 版本）
update:
	nix flake update

# 自動偵測最新版 google-antigravity 與 antigravity-cli 並套用更新
update-agy:
	python3 modules/home/custom-pkgs/google-antigravity/update.py
	python3 modules/home/custom-pkgs/antigravity-cli/update.py
	python3 modules/home/custom-pkgs/google-antigravity-ide/update.py
	$(MAKE) switch-home

# 更新 Master 分支：僅更新 nixpkgs-master 並套用個人設定
update-master:
	nix flake update nixpkgs-master
	$(MAKE) switch-home

# 更新 Unstable 分支：僅更新 nixpkgs-unstable 並套用個人設定（用於更新 vscode 等）
update-unstable:
	nix flake update nixpkgs-unstable
	$(MAKE) switch-home

# 清理系統空間：刪除舊的系統世代與未使用的快取
gc:
	sudo nix-collect-garbage -d
	sudo nixos-rebuild switch --flake $(FLAKE)
