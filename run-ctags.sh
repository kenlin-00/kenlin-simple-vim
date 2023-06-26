#!/bin/bash

kernel=./kernel/aml-5.4/
wifi_w1=./hardware/aml-5.4/wifi/amlogic/w1/project_w1/

function ctags_all() {
  cmd="ctags --fields=+iaS --extra=+q * --languages=c,c++ -R"
  for arg in "$@"
  do
    cmd="$cmd $arg"
  done

  eval "$cmd" && {
    # 删除查找多余的 EXPORT_SYMBOL
      # 指定tags文件路径
      tags_file="tags"
      # 创建临时文件
      tmp_file=$(mktemp)
      # 使用grep过滤包含"EXPORT_SYMBOL"的行，并将结果写入临时文件
      grep -v "EXPORT_SYMBOL" "$tags_file" > "$tmp_file"
      # 将临时文件替换原始的tags文件
      mv "$tmp_file" "$tags_file"
    }
}
ctags_all $kernel $wifi_w1