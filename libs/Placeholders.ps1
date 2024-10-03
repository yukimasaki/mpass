class Placeholders {
  # プロパティの定義
  [string]$EnvFilePath
  [string]$ConfigTemplate
  [string]$ConfigModified
  [string]$HostName
  [string]$UserName
  [string]$Password

  [int]$Cpus
  [string]$Disk
  [string]$Memory
  [string]$InstanceName
  [string]$Image
  
  # コンストラクタ
  Placeholders() {
    # 環境変数を取得
    $this.EnvFilePath = ".env"
    $envData = $this.LoadEnvFile()

    # 設定ファイルをコピー
    $this.ConfigTemplate = "config-template.yml"
    $this.ConfigModified = "config-modified.yml"
    $this.CopyConfig()

    $this.HostName = $envData.HOSTNAME
    $this.UserName = $envData.USERNAME
    $this.Password = $envData.PASSWORD

    $this.Cpus = $envData.CPUS
    $this.Disk = $envData.DISK
    $this.Memory = $envData.MEMORY
    $this.InstanceName = $envData.INSTANCE_NAME
    $this.Image = $envData.IMAGE
  }
  
  # クラスの初期化時に環境変数を取得するためのメソッド
  [hashtable] LoadEnvFile() {
    # ハッシュテーブルの初期化
    $envHashTable = @{}

    # 指定されたファイルパスが存在するか確認
    if (Test-Path $this.EnvFilePath) {
        # .envファイルを読み込んでキーと値をハッシュテーブルに格納
        Get-Content $this.EnvFilePath |
        ForEach-Object {
            # '='で分割してキーと値を取得
            $key, $value = $_.split('=', 2)
            # ハッシュテーブルに格納
            $envHashTable[$key.Trim()] = $value.Trim()
        }
    } else {
        throw "指定された.envファイルが見つかりません"
    }

    # ハッシュテーブルを返す
    return $envHashTable
  }

  # クラスの初期化時に追跡対象外の設定ファイルを生成するためのメソッド
  [void] CopyConfig() {
    Copy-Item -Path $this.ConfigTemplate -Destination $this.ConfigModified
  }
  
  # 設定ファイル内のプレースホルダーを一括置換するためのメソッド
  [void] ReplaceVariables(
    [hashtable]$replacements
  ) {
    # ファイルの内容を取得
    $content = Get-Content -Path $this.ConfigModified

    # ハッシュテーブル内のキーと値を使用して一括置換
    foreach ($key in $replacements.Keys) {
        $content = $content -replace $key, $replacements[$key]
    }

    # 置換後の内容をファイルに書き込み
    Set-Content -Path $this.ConfigModified -Value $content
  }
  
  [string] GetHostName() {
    return $this.HostName
  }

  [string] GetUserName() {
    return $this.UserName
  }
  
  [string] GetPassword() {
    return $this.Password
  }

  [string] GetCpus() {
    return $this.Cpus
  }

  [string] GetDisk() {
    return $this.Disk
  }

  [string] GetMemory() {
    return $this.Memory
  }

  [string] GetInstanceName() {
    return $this.InstanceName
  }

  [string] GetImage() {
    return $this.Image
  }
}