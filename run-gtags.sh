#!/bin/bash

current_path=$(pwd)
cd ${current_path}

# 查找文件并将结果输出到 gtags.files
directory="${HOME}/temp"
if [ ! -d "$directory" ]; then
	mkdir "$directory"
fi
find ./ -name "*.h" -o -name "*.c" -o -name "*.cpp" > ${directory}/gtags.files

# 创建gtags索引
echo "gtags -f ${directory}/gtags.files"
gtags -f ${directory}/gtags.files &

# 创建ctags索引
echo "ctags -R --fields=+iaS --extra=+q * --languages=c,c++"
ctags -R --fields=+iaS --extra=+q * --languages=c,c++ && {
  # 删除查找多余的 EXPORT_SYMBOL
  # 指定tags文件路径
  tags_file="tags"
  # 创建临时文件
  tmp_file=$(mktemp)
  # 使用grep过滤包含"EXPORT_SYMBOL"的行，并将结果写入临时文件
  grep -v "EXPORT_SYMBOL" "$tags_file" > "$tmp_file"
  # 将临时文件替换原始的tags文件
  mv "$tmp_file" "$tags_file"
} &
