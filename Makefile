# 定義主機名稱變數，對應你 flake.nix 中的 nixosConfigurations."ryan-Desktop"
FLAKE = .#ryan-Desktop
FLAKE_HOME = .#ryan

# 預設執行的指令：當你在終端機只輸入 `make` 時，預設執行 `switch`
default: switch

# 僅套用系統更新 (需要 sudo)
switch-sys:
	git add .
	sudo nixos-rebuild switch --flake $(FLAKE)

# 僅套用個人設定 (不需 sudo，改 MPV 用這個)
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

# 清理系統空間：刪除舊的系統世代與未使用的快取
gc:
	sudo nix-collect-garbage -d
	sudo nixos-rebuild switch --flake $(FLAKE)
