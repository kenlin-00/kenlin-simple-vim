import sys
import re

def mask_comments_and_strings(text):
    """
    将源码中的注释和字符串替换为空格或占位符，保持长度不变。
    用于定位关键字结构，而不破坏原始索引。
    """
    out_list = list(text)

    # 1. 替换字符串 "..." 和 '...'
    # 使用简单的状态机，因为正则处理嵌套有时较慢且易错，
    # 但为了脚本简洁，这里使用精心设计的正则迭代
    pattern_str = re.compile(r'(".*?"|\'.*?\')')
    for match in pattern_str.finditer(text):
        for i in range(match.start(), match.end()):
            out_list[i] = ' ' # 替换为空格

    # 2. 替换块注释 /* ... */
    pattern_block = re.compile(r'/\*.*?\*/', re.DOTALL)
    for match in pattern_block.finditer(text):
        # 保持换行符，以保留行号对应关系，其他变空格
        for i in range(match.start(), match.end()):
            if out_list[i] != '\n':
                out_list[i] = ' '

    # 3. 替换行注释 // ...
    pattern_line = re.compile(r'//.*')
    for match in pattern_line.finditer(text):
        for i in range(match.start(), match.end()):
             out_list[i] = ' '

    return "".join(out_list)

def count_statements(text):
    """
    计算一段纯代码（去除了大括号外壳后）的语句数量。
    逻辑：计算分号数量。
    注意：输入进来的 text 包含注释，所以需要先过滤注释再计算。
    """
    # 移除注释和字符串内容以便计数
    clean = re.sub(r'(".*?"|\'.*?\')', '', text) # 删掉字符串内容
    clean = re.sub(r'/\*.*?\*/', '', clean, flags=re.DOTALL) # 删掉块注释
    clean = re.sub(r'//.*', '', clean) # 删掉行注释

    # 只有空白或注释视为 0 条（不处理空块，防止删掉空循环）
    if not clean.strip():
        return 999 # 返回大数，保护空块不被去括号

    count = clean.count(';')

    # 特殊情况：宏调用可能没有分号，但在单行块中通常视为1条
    if count == 0 and clean.strip():
        return 1
    return count

def find_matching_brace(masked_text, start_idx):
    """
    在 masked_text 中寻找匹配的右大括号
    """
    depth = 0
    for i in range(start_idx, len(masked_text)):
        if masked_text[i] == '{':
            depth += 1
        elif masked_text[i] == '}':
            depth -= 1
            if depth == 0:
                return i
    return -1

def get_block_info(masked_text, start_search_idx):
    """
    从 start_search_idx 开始寻找下一个 '{' 并确定其范围
    返回 (open_idx, close_idx)
    """
    open_idx = masked_text.find('{', start_search_idx)
    if open_idx == -1:
        return None, None

    # 简单的安全性检查：在找到 { 之前如果不小心遇到了 ; 意味着没有大括号
    # 例如 if (a) return;
    semicolon_check = masked_text.find(';', start_search_idx)
    if semicolon_check != -1 and semicolon_check < open_idx:
        return None, None

    close_idx = find_matching_brace(masked_text, open_idx)
    return open_idx, close_idx

def process_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
    except UnicodeDecodeError:
        with open(file_path, 'r', encoding='latin-1') as f:
            original_content = f.read()

    # 生成遮罩文本（用于定位语法结构）
    masked_content = mask_comments_and_strings(original_content)

    # 记录需要删除的大括号的位置列表 [(index, is_open_brace), ...]
    # 我们收集所有要删除的括号，最后一次性倒序删除
    braces_to_remove = []

    # 查找关键字：if, while, switch, for
    # 必须匹配完整单词
    keyword_pattern = re.compile(r'\b(if|while|for|switch)\b')

    # 找到所有匹配项
    matches = [m for m in keyword_pattern.finditer(masked_content)]

    # 已处理过的 else 区域（避免 if 处理了 else 后，主循环再次处理 else）
    # 其实我们只搜索 if/while/for，不搜索 else，所以不用担心重复，
    # 但要注意 else if 的情况，else if 的 if 会被单独搜到。

    for match in matches:
        kw = match.group(1)
        kw_end = match.end()

        # 1. 获取主块 (if/while/...) 的大括号范围
        # 跳过条件括号 (...) 寻找 {
        # 注意：这里需要跳过 ()，避免 while ((c=getchar()) != '{') 这种干扰
        # 简单处理：从 kw_end 开始找第一个 {，前提是中间没有 ;

        main_open, main_close = get_block_info(masked_content, kw_end)

        if main_open is None or main_close == -1:
            continue

        # 提取主块内容并计数
        main_body_text = original_content[main_open+1 : main_close]
        main_stmts = count_statements(main_body_text)

        # 准备数据结构
        # block_list = [ (start, end, statement_count) ]
        blocks = []
        blocks.append({
            'open': main_open,
            'close': main_close,
            'stmts': main_stmts,
            'type': kw
        })

        # 2. 如果是 if，检查是否存在关联的 else
        if kw == 'if':
            # 从 main_close 后面开始看是否有 else
            # 跳过空白
            idx = main_close + 1
            while idx < len(masked_content) and masked_content[idx].isspace():
                idx += 1

            # 检查是否以 else 开头
            if masked_content.startswith('else', idx):
                # 找到了 else，寻找 else 的大括号
                else_kw_end = idx + 4
                else_open, else_close = get_block_info(masked_content, else_kw_end)

                if else_open is not None and else_close != -1:
                    else_body_text = original_content[else_open+1 : else_close]
                    else_stmts = count_statements(else_body_text)

                    blocks.append({
                        'open': else_open,
                        'close': else_close,
                        'stmts': else_stmts,
                        'type': 'else'
                    })

        # 3. 核心逻辑判断
        # 规则：如果关联的块中，有任何一个块 stmts > 1，则所有块都不处理。
        any_complex = any(b['stmts'] > 1 for b in blocks)

        if not any_complex:
            # 安全：都是单行语句，可以删除大括号
            for b in blocks:
                braces_to_remove.append((b['open'], True))  # True = 左括号
                braces_to_remove.append((b['close'], False)) # False = 右括号

    # 4. 执行删除
    # 必须倒序处理，防止索引偏移
    braces_to_remove.sort(key=lambda x: x[0], reverse=True)

    # 过滤重复（以防万一，虽然逻辑上不应该有重叠）
    unique_removals = []
    last_idx = -1
    for item in braces_to_remove:
        if item[0] != last_idx:
            unique_removals.append(item)
            last_idx = item[0]

    current_content = original_content

    for idx, is_open in unique_removals:
        # 再次确认该位置是括号（双重保险）
        if current_content[idx] not in ('{', '}'):
            continue

        if is_open:
            # 删除左括号 '{'
            # 通常变成删除 "{ " 或者 " {"
            # 策略：删除 '{' 字符。
            # 如果 '{' 前面紧挨着一个空格，也删除那个空格（保持 if (...) return 对齐）
            start_del = idx
            end_del = idx + 1
            if start_del > 0 and current_content[start_del-1] == ' ':
                start_del -= 1

            current_content = current_content[:start_del] + current_content[end_del:]

        else:
            # 删除右括号 '}'
            # 策略比较复杂，需要处理缩进和换行

            # 获取上下文
            # 找到行首和行尾
            line_end = current_content.find('\n', idx)
            if line_end == -1: line_end = len(current_content)
            line_start = current_content.rfind('\n', 0, idx) + 1

            line_str = current_content[line_start:line_end]

            # 分割部分
            # pre_brace: 行首到 }
            # post_brace: } 到行尾
            pre_brace = current_content[line_start:idx]
            post_brace = current_content[idx+1:line_end]

            is_empty_prefix = (pre_brace.strip() == '')

            # 检查后面是否跟着 else (在同一行)
            # 例如: } else {
            is_else_following = post_brace.strip().startswith('else')

            if is_else_following:
                # 情况 1: `} else` -> `else`
                # 只删除 `}`，保留原本的空格结构
                current_content = current_content[:idx] + current_content[idx+1:]

            elif is_empty_prefix and post_brace.strip() == '':
                # 情况 2: 独占一行的 `}` -> 删除整行
                # 删除从 line_start 到 line_end + 1 (换行符)
                current_content = current_content[:line_start] + current_content[line_end+1:]

            else:
                # 情况 3: 代码尾部的 `}` (比如 `return; }`) -> 只删 `}`
                current_content = current_content[:idx] + current_content[idx+1:]

    # 写回文件
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(current_content)
    print(f"Processed: {file_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 format_c_code.py <path_to_c_file>")
        sys.exit(1)

    process_file(sys.argv[1])
