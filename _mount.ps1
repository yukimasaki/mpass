# 関数をインポート
. ./libs/Functions.ps1

function Start-Mount {
  # ローカルのディレクトリをインスタンス側にマウント
  Mount-Directory # 管理者として実行すること
}

Start-Mount