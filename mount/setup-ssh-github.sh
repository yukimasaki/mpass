#!/bin/bash

# 変数定義
KEY_NAME="github-yukimasaki"
KEY_PATH="$HOME/.ssh/$KEY_NAME"
CONFIG_FILE="$HOME/.ssh/config"
HOST_NAME="github.com"
SSH_USER="git"
SSH_PORT="22"

# SSH鍵の生成（存在しない場合のみ）
if [ ! -f "$KEY_PATH" ]; then
  echo "キーペアを $KEY_PATH に作成します。"
  ssh-keygen -t ed25519 -N "" -f "$KEY_PATH"
  echo "キーペアを作成しました。"
  cat "$KEY_PATH.pub"
  rm "$KEY_PATH.pub"
else
  echo "すでにキーペアは $KEY_PATH に存在します。"
fi

# ~/.ssh/configの設定（存在しない場合のみ）
if [ ! -e "$CONFIG_FILE" ]; then
  echo "SSH 設定ファイルを $CONFIG_FILE に作成します。"
  touch "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"  # セキュリティのためにパーミッションを設定
fi

# SSH接続設定を追記（既存の設定を上書きしないようにチェック）
if ! grep -q "$KEY_NAME" "$CONFIG_FILE"; then
  echo -e "\nHost $KEY_NAME\n  HostName $HOST_NAME\n  User $SSH_USER\n  Port $SSH_PORT\n  IdentityFile $KEY_PATH" >> "$CONFIG_FILE"
  echo "$KEY_NAME 用のSSH 設定を追加しました。"
else
  echo "$KEY_NAME 用のSSH 設定はすでに $CONFIG_FILE に存在します。"
fi