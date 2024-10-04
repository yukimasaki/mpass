# クラスのインポート
. ./libs/Placeholders.ps1
$Placeholders = [Placeholders]::new()

######################################################################################
# pwsh & Multipass インストール処理
######################################################################################

# pwsh コマンドの利用確認
function Test-Pwsh {
  try {
    pwsh --version > $null 2>&1
    Write-Host "pwsh は既にインストールされています。"
    return $true
  } catch {
    Write-Host "pwsh が見つかりません。"
    return $false
  }
}

# pwsh のインストール処理
function Install-Pwsh {
  Write-Host "pwsh のインストールを開始します..."
  winget install --id Microsoft.Powershell --source winget

  # インストールが成功したか確認
  if (Test-Pwsh) {
    Write-Host "pwsh が正常にインストールされました。"
  } else {
    Write-Error "pwsh のインストールに失敗しました。処理を中断します。"
    exit 1
  }
}

# Multipass コマンドの利用確認
function Test-Multipass {
  try {
    multipass --version > $null 2>&1
    Write-Host "Multipass は既にインストールされています。"
    return $true
  } catch {
    Write-Host "Multipass が見つかりません。"
    return $false
  }
}

# Multipass のインストール処理
function Install-Multipass {
  Write-Host "Multipass をインストールします..."
  winget install -e --id Canonical.Multipass

  # インストールが成功したか再度確認
  if (Test-Multipass) {
    Write-Host "Multipass が正常にインストールされました。"
  } else {
    Write-Error "Multipass のインストールに失敗しました。処理を中断します。"
    exit 1
  }
}

# Multipass のアップデート
function Update-Multipass {
  Write-Host "Multipass のアップデートを実行します..."
  winget upgrade -e --id Canonical.Multipass
  Write-Host "Multipass のアップデートが完了しました。"
}

######################################################################################
# pwsh & Multipass アンインストール処理
######################################################################################

# pwsh のアンインストール処理
function Uninstall-Pwsh {
  Write-Host "pwsh のアンインストールを開始します..."
  winget uninstall Microsoft.Powershell

  # アンインストールウィザードがGUIで起動するだけなので、アンインストールの成否を追跡できなさそう
}

# Multipass のインストール処理
function Uninstall-Multipass {
  Write-Host "Multipass のアンインストールを開始します..."
  winget uninstall multipass
  
  # アンインストールウィザードがGUIで起動するだけなので、アンインストールの成否を追跡できなさそう
}

######################################################################################
# SSH 関連
######################################################################################

# キーペアを作成
function New-Key-Pair {
  # キーペアを作成するディレクトリ
  $sshDir = "$HOME/.ssh"

  # ディレクトリが存在しない場合は作成する
  if (-not (Test-Path -Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force
  }
  
  # Multipass 仮想環境へSSH接続するためのキーペアをホストマシン上に作成
  $hostName = $Placeholders.GetHostName()
  ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/$hostName"
}

# config ファイルへ接続設定を追記
function Add-Ssh-Config {
  # config ファイルのパス
  $sshDir = "$HOME/.ssh"
  $sshConfig = "$sshDir/config"
  $hostName = $Placeholders.GetHostName()
  $userName = $Placeholders.GetUserName()

  # 追記または作成するSSH接続設定
  $sshConfigEntry = @"
Host $hostName
  HostName $hostName.local
  User $userName
  Port 22
  IdentityFile ~/.ssh/$hostName
"@

  if (-not (Test-Path $sshConfig)) {
    # ファイルを新規作成し、SSH設定を追加
    Set-Content -Path $sshConfig -Value $sshConfigEntry
    Write-Host "SSH 接続設定ファイルを作成しました。"
  } else {
    # 2行の改行を追加してSSH設定を追記
    Add-Content -Path $sshConfig -Value "`r`n`r`n$sshConfigEntry"
    Write-Host "SSH 接続設定を追記しました。"
  }
}

######################################################################################
# Multipass 関連
######################################################################################

# cloud-init 設定ファイルのプレースホルダーを一括置換
function Set-Replacements {
  # 生成したキーペアのうち、公開鍵のパスを指定
  $hostName = $Placeholders.GetHostName()
  $userName = $Placeholders.GetUserName()
  $password = $Placeholders.GetPassword()
  
  $pubKeyPath = "$HOME/.ssh/$hostName.pub"
  $pubKey = Get-Content -Path $pubKeyPath -Raw

  $replacements = @{
    "__HOSTNAME__" = $hostName
    "__USERNAME__" = $userName
    "__PASSWORD__" = $password
    "__PUBKEY__" = $pubKey
  }
  
  $Placeholders.ReplaceVariables($replacements)
}

# マウント機能を有効化
function Enable-Mount {
  multipass set local.privileged-mounts=true
  Restart-Service -Name multipass # 管理者として実行すること
}

# Multipass インスタンスを起動
function Start-Instance {
  $cpus = $Placeholders.GetCpus()
  $disk = $Placeholders.GetDisk()
  $memory = $Placeholders.GetMemory()
  $instanceName = $Placeholders.GetInstanceName()
  $image = $Placeholders.GetImage()

  try {
    # multipass コマンドを実行
    multipass launch `
        --cpus $cpus `
        --disk $disk `
        --memory $memory `
        --cloud-init "config-modified.yml" `
        --name $instanceName `
        --timeout 1800 `
        $image
  }
  catch {
    Write-Host "Multipass インスタンスの起動に失敗しました。"
  }
}

# ローカルディレクトリをインスタンスにマウント (インスタンス起動後でないと実行できない)
function Mount-Directory { 
  $instanceName = $Placeholders.GetInstanceName()
  $userName = $Placeholders.GetUserName()

  # ローカルの mount ディレクトリをインスタンス側にマウント
  multipass mount ./mount ${instanceName}:/home/${userName}/repositories/mount
}