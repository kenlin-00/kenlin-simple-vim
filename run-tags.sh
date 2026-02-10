#!/bin/bash

current_path=$(pwd)
cd "${current_path}"

clean_tags_files() {
    if [[ $1 == "clean" ]]; then
        echo "clean GRTAGS GTAGS GPATH tags..."
        rm -f GPATH GRTAGS GTAGS tags tags_files.txt
    fi
}

if [[ $1 == "clean" ]]; then
    clean_tags_files $1
    exit 0
fi

echo "run $0 $@"

if [ "$#" -eq 0 ]; then
    echo "Please input at least one parameter (dir)"
    exit 1
fi

# 将所有参数传给 find
find "$@" -type f \
    ! -iname "*.mod.c" \
    ! -iname "*.o" \
    ! -iname "*.xml" \
    ! -iname "*.json" \
    ! -iname "*.html" \
    -print > tags_files.txt

function run_gtags() {
    echo "Generating gtags..."
    if [ -f tags_files.txt ]; then
        gtags -f tags_files.txt
    fi
}

function run_ctags() {
    echo "Generating ctags for $@"
    cmd="ctags -R --fields=+iaS --extra=+q --exclude=build --languages=c,c++ $@"
    echo "Executing: $cmd"

    eval "$cmd" && {
        echo "Filtering EXPORT_SYMBOL..."
        tags_file="tags"
        if [ -f "$tags_file" ]; then
            tmp_file=$(mktemp)
            fgrep -v "EXPORT_SYMBOL" "$tags_file" > "$tmp_file"
            mv "$tmp_file" "$tags_file"
        fi
    }
}

run_ctags "$@"
run_gtags

if [ -f tags_files.txt ]; then
    rm tags_files.txt
fi

echo "gtags and ctags files generated successfully!"
