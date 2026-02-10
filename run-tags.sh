#!/bin/bash

current_path=$(pwd)
cd ${current_path}

clean_tags_files() {
  if [[ $1 == "clean" ]]; then
    echo "clean GRTAGS GTAGS GPATH tags..."
    if [[ -f GPATH ]]; then
      rm GPATH
    fi
    if [[ -f GRTAGS ]]; then
      rm GRTAGS
    fi
    if [[ -f GTAGS ]]; then
      rm GTAGS
    fi

    if [[ -f tags ]]; then
      rm tags
    fi
  fi
}

if [[ $1 == "clean" ]]; then
  clean_tags_files $1
  exit 0
fi

echo "run $0 $1 $2 $3"
# 检查输入参数
if [ "$#" -eq 3 ]; then
 	path1="$1"
 	path2="$2"
 	path3="$3"
  # 使用 find 查找文件并排除不需要的文件
  find "$path1" "$path2" "$path3" -type f \
    ! -iname "*.mod.c" \
    ! -iname "*.o" \
    ! -iname "*.xml" \
    ! -iname "*.json" \
    ! -iname "*.html" \
    -print > tags_files.txt

elif [ "$#" -eq 2 ]; then
 	path1="$1"
 	path2="$2"
  # 使用 find 查找文件并排除不需要的文件
  find "$path1" "$path2" -type f \
    ! -iname "*.mod.c" \
    ! -iname "*.o" \
    ! -iname "*.xml" \
    ! -iname "*.json" \
    ! -iname "*.html" \
    -print > tags_files.txt
  echo "run gtags and ctags in current dir"
elif [ "$#" -eq 1 ]; then
	path1="$1"
  # 使用 find 查找文件并排除不需要的文件
  find "$path1" -type f \
    ! -iname "*.mod.c" \
    ! -iname "*.o" \
    ! -iname "*.xml" \
    ! -iname "*.json" \
    ! -iname "*.html" \
    -print > tags_files.txt
else
  echo "pease input parameter (dir)"
  exit 0
fi

# 定义排除的文件模式
exclude_patterns="*.mod.c|*.o|*.xml|*.json|*.html"

function run_gtags() {
	# 生成 gtags 文件
	echo "Generating gtags for $path1 and $path2..."

	# 生成 gtags
	gtags -f tags_files.txt

  # 清理临时文件
  rm tags_files.txt
}

function run_ctags() {
  # 生成 ctags 文件
  echo "Generating ctags for $path1 and $path2 $path3 ..."

  cmd="ctags -R --fields=+iaS --extra=+q --exclude=build * --languages=c,c++"
  for arg in "$@"
  do
    cmd="$cmd $arg"
  done

  echo "$cmd"

  eval "$cmd" && {
    # 删除查找多余的 EXPORT_SYMBOL
      # 指定tags文件路径
      tags_file="tags"
      # 创建临时文件
      tmp_file=$(mktemp)
      # 使用 fgrep 过滤包含"EXPORT_SYMBOL"的行，并将结果写入临时文件
      fgrep -v "EXPORT_SYMBOL" "$tags_file" > "$tmp_file"
      # 将临时文件替换原始的tags文件
      mv "$tmp_file" "$tags_file"
    }
}

run_gtags &

run_ctags ${path1} ${path2} ${path3}&

#echo "gtags and ctags files generated successfully!"

