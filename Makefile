# 定義主機名稱變數，對應你 flake.nix 中的 nixosConfigurations."ryan-Desktop"
FLAKE = .#ryan-Desktop

# 預設執行的指令：當你在終端機只輸入 `make` 時，預設執行 `switch`
default: switch

# 套用設定：自動將變更加入 Git 索引，並執行重建
# 客觀依據：Nix Flake 只能讀取已被 Git 追蹤的檔案，先執行 git add 可避免報錯
switch:
	git add .
	sudo nixos-rebuild switch --flake $(FLAKE)

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
