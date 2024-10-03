# 関数をインポート
. ./libs/Functions.ps1

# メイン処理
function Start-Uninstall {
  Uninstall-Pwsh
  Uninstall-Multipass
}

# メイン処理を実行
Start-Uninstall