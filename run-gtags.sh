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
echo "gtags -f ${directory}/gtags.files &"
gtags -f ${directory}/gtags.files

# 创建ctags索引
echo "ctags -R &" 
ctags -R &
