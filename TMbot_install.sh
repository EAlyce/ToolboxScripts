a#!/bin/bash

# 验证API_ID
validate_api_id() {
  local api_id="$1"
  [[ "$api_id" =~ ^[0-9]{8,10}$ ]]
}

# 验证API_HASH
validate_api_hash() {
  local api_hash="$1"
  [[ "$api_hash" =~ ^[a-fA-F0-9]{32}$ ]]
}

read -p "请输入容器名称（只能包含字母、数字、下划线、点和短横线）: " container_name

while true; do
  read -p "请输入API_ID: " api_id
  if validate_api_id "$api_id"; then
    break
  else
    echo "API_ID格式不正确，请输入8到10位数字。"
  fi
done

while true; do
  read -p "请输入API_HASH: " api_hash
  if validate_api_hash "$api_hash"; then
    break
  else
    echo "API_HASH格式不正确，请输入32位的十六进制数。"
  fi
done

data_path="${HOME}/TMBdata/${container_name}"

mkdir -p "$data_path"

docker run -it --restart=always --name=${container_name} \
  -e TZ=Asia/Shanghai \
  -e API_ID=${api_id} \
  -e API_HASH=${api_hash} \
  -v ${data_path}:/TMBot/data \
  noreph/tmbot
