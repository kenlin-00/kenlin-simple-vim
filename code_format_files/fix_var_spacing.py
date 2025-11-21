#!/usr/bin/env python3

# python3 fix_var_spacing.py < file.c > tmp && mv tmp file.c

# for f in *.c; do
#     python3 fix_var_spacing.py < "$f" > tmp && mv tmp "$f"
# done

#!/usr/bin/env python3
import sys
import re

# 内核允许的变量声明形式（非常宽松）
var_decl = re.compile(
    r'^\s*(?:const\s+)?'
    r'(?:struct\s+\w+|[A-Za-z_]\w*)' 
    r'(?:\s+[*\w\[\]]+)+'
    r'\s*(?:=.*)?;'
)

def fix_spacing(code):
    lines = code.split("\n")
    out = []
    inside_func = False
    in_var_block = False

    for line in lines:
        stripped = line.strip()

        # 检查函数开始
        if stripped.endswith("{"):
            inside_func = True
            in_var_block = True
            out.append(line)
            continue

        # 正在函数开头处理变量声明区
        if inside_func and in_var_block:

            # 空行直接输出但不结束变量区
            if stripped == "":
                out.append(line)
                continue

            # 匹配变量声明
            if var_decl.match(stripped):
                out.append(line)
                continue

            # 不是变量声明 → 需要在前插入空行（如果没有）
            if out and out[-1].strip() != "":
                out.append("")

            in_var_block = False

        # 检查函数结束
        if stripped == "}":
            inside_func = False

        out.append(line)

    return "\n".join(out)


if __name__ == "__main__":
    print(fix_spacing(sys.stdin.read()))



