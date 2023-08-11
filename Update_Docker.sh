#!/bin/bash

# 获取所有运行中的Docker容器的ID
container_ids=$(docker ps -q)

# 循环遍历每个容器ID
for container_id in $container_ids
do
  echo "正在更新容器 $container_id ..."
  
  # 更新容器内的包列表
  docker exec -it $container_id apt-get update
  
  # 升级容器内的所有包
  docker exec -it $container_id apt-get upgrade -y
  
  echo "容器 $container_id 更新完成！"
done

echo "所有容器已成功更新！"
