#!/bin/bash

#use:  run-gtags.sh
# 如果需要 ctags 多个路径，需要将 run-ctags.sh 拷贝到你的项目根目录下(一般是外设单独驱动程序目录)。
# 然后执行 run-gtags.sh [kernel-patch] [driver-path]

current_path=$(pwd)
cd ${current_path}

# 查找文件并将结果输出到 gtags.files
directory="${HOME}/temp"
if [ ! -d "$directory" ]; then
	mkdir "$directory"
fi
#find ./ -name "*.h" -o -name "*.c" -o -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" > ${directory}/gtags.files

# 创建gtags索引
#echo "gtags -f ${directory}/gtags.files"
#gtags -f ${directory}/gtags.files &
gtags  &

kernel=$1
driver_patch=$2

# 判断是否存在 run-ctags.sh， 如果存在，就可能需要添加多个 ctag 路径
if [[ -e "run-ctags.sh" ]]; then
  echo "run-ctags.sh ${kernel} ${driver_patch} &"
  ./run-ctags.sh ${kernel} ${driver_patch} &
else
  # 创建ctags索引
  echo "ctags -R --fields=+iaS --extras=+q * --languages=c,c++"
  ctags -R --fields=+iaS --languages=c,c++;

  # 删除查找多余的 EXPORT_SYMBOL
  # 指定tags文件路径
  tags_file="tags"
  # 创建临时文件
  tmp_file=$(mktemp)
  # 使用 fgrep 过滤包含"EXPORT_SYMBOL"的行，并将结果写入临时文件
  fgrep -v "EXPORT_SYMBOL" "./$tags_file" > "$tmp_file";
  fgrep -v ".css" "$tmp_file" > "${tmp_file}_1";
  fgrep -v ".html" "${tmp_file}_1" > "$tmp_file";
  # 将临时文件替换原始的tags文件
  mv "$tmp_file" "./$tags_file";

  rm "${tmp_file}_1"
fi
cd -

