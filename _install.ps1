# 関数をインポート
. ./libs/Functions.ps1

# メイン処理
function Start-Install {
  # pwsh をインストール
  if (-not (Test-Pwsh)) {
    Install-Pwsh
  } else {
    Write-Host "pwsh の状態は良好です。"
  }

  # Multipass をインストール
  if (-not (Test-Multipass)) {
    Install-Multipass
  } else {
    Write-Host "Multipass の状態は良好です。アップデートを実行します。"
    Update-Multipass
  }

  # SSH 関連の設定
  New-Key-Pair
  Add-Ssh-Config
  
  # プレースホルダーを一括置換
  Set-Replacements

  # マウント機能を有効化
  Enable-Mount
  
  # インスタンスを起動
  Start-Instance 
}

# メイン処理を実行
Start-Install