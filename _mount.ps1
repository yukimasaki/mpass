# 関数をインポート
. ./libs/Functions.ps1

function Start-Mount {
  # ローカルのディレクトリをインスタンス側にマウント
  Mount-Directory
}

Start-Mount