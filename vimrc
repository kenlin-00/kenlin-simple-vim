" kendall-simple-vim
" https://github.com/kendall-cpp/kendall-simple-vim
" config for vim

" 解决 无法删除问题
set backspace=indent,eol,start

" Vim 在与屏幕/键盘交互时使用的编码(取决于实际的终端的设定)
set encoding=utf-8
set langmenu=zh_CN.UTF-8

" 括号匹配
set showmatch

"set cursorcolumn    "列
set cursorline     " 行
set nu   " 显示行号

syntax on "自动语法高亮
set hlsearch " 搜索高亮
set incsearch

"vim自动打开跳到上次的光标位置
if has("autocmd")
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" 设置是否进入当前打开文件的目录(set autochdir), 快捷键按 \ 然后按 cd
nnoremap <leader>cd :call ToggleAutochdir()<CR>
" 全局变量用于存储原始工作目
let g:original_cwd = getcwd()
function! ToggleAutochdir()
	if &acd
		set noacd
		execute 'cd ' . g:original_cwd
		echo "禁用自动切换工作目录"
	else
		set acd
		echo "启用自动切换工作目录"
	endif
endfunction


" 其他的默认为4
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab  " 不转成空格
" kernel 建议增加下面几行配置  "expandtab 转成空格
" autocmd FIletype json,xml,c,cpp,h,vim,conf,bind,gitcommit setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
autocmd FIletype dtsi,dts,gitcommit setlocal tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab
autocmd FIletype sh,mk,make setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab  " for google project
autocmd FIletype c,h setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
autocmd FIletype json,xml,cc,cpp setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" 设置更改当前文件的 Tab 键宽度的快捷键
nnoremap <leader>ct :call SetTabWidth()<CR>
function! SetTabWidth()
	let tab_width_no = input("请输入新的 Tab 键宽度(1-8)：")
	let tab_width = matchstr(tab_width_no, '^[1-8]')
	let expand = tab_width_no =~ '^[1-8] no' ? 0 : 1

	if empty(tab_width)
		echo "\t无效的输入，Tab 键宽度未更改"
		return
	endif

	execute 'set tabstop=' . tab_width
	execute 'set softtabstop=' . tab_width
	execute 'set shiftwidth=' . tab_width

	if expand
		execute 'set expandtab'
		echo "\t已将 Tab 键宽度设置为 " . tab_width . "，expandtab"
	else
		execute 'set noexpandtab'
		echo "\t已将 Tab 键宽度设置为 " . tab_width . "，noexpandtab"
	endif
endfunction

set nocompatible              " 去除VI一致性,必须要添加
filetype off                  " 必须要添加

" Vundle 插件管理器设置
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 在此处添加您需要安装的插件
Plugin 'VundleVim/Vundle.vim'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'mhinz/vim-startify'   " 输入 vim 显示图案好看
Plugin 'flazz/vim-colorschemes'
Plugin 'neoclide/coc.nvim'
Plugin 'Yggdroot/LeaderF' "LeaderF模糊查找插件
call vundle#end()
filetype plugin indent on

" 忽视插件改变缩进,可以使用以下替代
" filetype plugin on

" 不使用任何插件管理的插件
set runtimepath^=~/.vim/bundle/ag

" ag
nmap ag :Ag -w <C-R>=expand("<cword>")<CR><CR>   "Ag 查找当成层级

" tagbar 显示函数名和变量
let g:tagbar_ctags_bin='/usr/bin/ctags'          "ctags程序的路径
let g:tagbar_position = 'left'
let g:tagbar_width=30                  "窗口宽度的设置

" 1 开启自动预览(随着光标在标签上的移动，顶部会出现一个实时的预览窗口)
let g:tagbar_autopreview = 0
let g:tagbar_autofocus = 0  " 光标在文件内
map <C-n> :Tagbar<CR>
"autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx call tagbar#autoopen() "如果是c语言的程序的话，tagbar自动开启

" nerdtree 目录树
map <C-b> :NERDTreeToggle<CR>
let NERDTreeWinPos='right'
" autocmd vimenter * NERDTree  "自动开启Nerdtree  文件列表
" wincmd w   " 自动打开后光标在代码区
" autocmd VimEnter * wincmd w
let g:NERDTreeWinSize=28  " 目录栏宽度
"打开vim时如果没有文件自动打开NERDTree
""autocmd vimenter * if !argc()|NERDTree|endi
"当NERDTree为剩下的唯一窗口时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeIgnore = ['\.pyc$','\.o', '\.ko', '\.bin']  " 过滤所有.pyc文件不显示
let g:NERDTreeHidden=0     "不显示隐藏文件
" 图标
let g:NERDTreeIndicatorMapCustom = {
	\ "Modified"  : "✹",
	\ "Staged"    : "✚",
	\ "Untracked" : "✭",
	\ "Renamed"   : "➜",
	\ "Unmerged"  : "═",
	\ "Deleted"   : "✖",
	\ "Dirty"     : "✗",
	\ "Clean"     : "✔︎",
	\ 'Ignored'   : '☒',
	\ "Unknown"   : "?"
	\ }

"vim-airline 状态栏
"let g:airline_powerline_fonts=1  " 我的服务器没有 powerline
" powerline 字体： https://github.com/powerline/fonts
let g:airline#extensions#tabline#enabled = 1      "tabline中当前buffer两端的分隔字符
let g:airline_section_b = '%-0.10{getcwd()}'
" let g:airline_section_c = '%t'  " 只显示文件名
let g:airline_section_c = "%{expand('%:p')}"  " 显示全路径
let g:airline#extensions#tagbar#enabled = 1
let g:airline_section_y = ''
let g:airline_theme='google_dark'

"molokai 主题
"colorscheme molokai "设置颜色主题"
set t_Co=256 "设置256色彩
set background=dark
"let g:molokai_original=1
let g:rehash256 = 1
" colorschemes
" 默认主题
colorscheme gruvbox
" 解决 git commit 注释信息看不清问题
autocmd BufRead COMMIT_EDITMSG,HEAD,FETCH_HEAD,config colorscheme evening

"gtags.vim 设置项
let GtagsCscope_Auto_Load = 1
let CtagsCscope_Auto_Map = 1
let GtagsCscope_Quiet = 1

if filereadable("tags")
	execute 'set tags=tags'
endif

if filereadable(".tags")
	execute 'set tags=.tags'
endif

if filereadable("cscope.out")
	cs add cscope.out
endif

if has("cscope")
	set csprg="gtags-cscope"
	"set csprg="/usr/bin/cscope"
	set csto=1  " csto的值决定了 cstag 执行查找的顺序。假如csto被设置为0，那么 cscope 数据将会被优先查找
	set cst "始终同时查找cscope数据库和tags文件
endif

set cscopetag " 使用 cscope 作为 tags 命令,  Enable 'CTRL-]' shortcuts

set cscopeprg=gtags-cscope
cs add GTAGS

" cscope
" Find symbol       :cs find 0 or s
nmap ccs :cs find s <C-R>=expand("<cword>")<CR><CR>
" Find definition   :cs find 1 or g
nmap ccg :cs find g <C-R>=expand("<cword>")<CR><CR>
" Find functions called by this function  (gtags not implemented)
nmap ccd :cs find d <C-R>=expand("<cword>")<CR><CR>
" Find reference    :cs find 3 or c
nmap ccc :cs find c <C-R>=expand("<cword>")<CR><CR>

"" YouCompleteMe
let g:loaded_youcompleteme = 1
"" 增加一些补全的机制
"" 参考： https://zhuanlan.zhihu.com/p/33046090
"let g:ycm_semantic_triggers =  {
"			\ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
"			\ 'cs,lua,javascript': ['re!\w{2}'],
"			\ }
"
"" 添加白名单，只有这些文件才会去分析
"let g:ycm_filetype_whitelist = {
"			\ "c":1,
"			\ "cpp":1,
"			\ "objc":1,
"			\ "py":1,
"			\ "sh":0,
"			\ "zsh":0,
"			\ "zimbu":0,
"			\ }
"
"" 临时关闭 YouCompleteMe
""let g:ycm_global_ycm_extra_conf = 1
"" 关闭悬浮提示窗口
"let g:ycm_hover_disable_while_typing = 1
"
"" 输入两个字符就开始提示补全
"let g:ycm_min_num_identifier_candidate_chars = 2
"
"" 设置为 0 时，函数或变量的预览窗口不会包含在自动补全菜单中，只显示补全项的名称
"let g:ycm_add_preview_to_completeopt = 0
"
"" 关闭显示诊断信息，语言标注出来你代码问题
""let g:ycm_show_diagnostics_ui = 1
""let g:ycm_autoclose_preview_window_after_insertion = 1
"
"" 补全后自动关闭预览窗口
"let g:ycm_autoclose_preview_window_after_completion = 1
"let g:ycm_min_num_of_chars_for_completion=2  " set autocompletion - min-word
"
""注释和字符串中的文字也会被收入补全
"let g:ycm_collect_identifiers_from_comments_and_strings = 1
"
"" 语法高亮
""let g:ycm_enable_semantic_highlighting=1"
"
"" menu 表示在自动补全时显示菜单，方便您选择补全项
"" menuone 表示当只有一个补全项时，也显示菜单，以便查看补全项的详情
"set completeopt=menu,menuone

" coc
let g:coc_disable_startup_warning = 0
" For coc-nvim, it can't use pumvisible, and it will cause some side effect.
"  More details: please visit
"  https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources
"  "" wiki: https://github.com/neoclide/coc.nvim/wiki
"
"" <Enter>         : final select
" <Tab>           : select next
"  <"Shift> + <Tab> : Select prev
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

set pumheight=12  " 补全菜单太长

"LeaderF 模糊文件查找配置
let g:Lf_UseVersionControlTool=1 "这个是默认选项, 可以不写
let g:Lf_DefaultExternalTool='rg'  " 设置用第三方工具查找 这个选项可以是'rg', 'pt', 'ag', 'find'之一, 顺序代表优先级
" 件快速搜索 快捷键
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
" 设置项目根目录
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', '.project', '.root', 'tags', 'GTAGS']
" 设置查找规则
let g:Lf_WorkingDirectoryMode = 'AF'
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 1
let g:Lf_HideHelp = 1
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}
" 不显示隐藏文件
let g:Lf_ShowHidden = 0
let g:Lf_PreviewInPopup = 1  " 预览弹出窗口显示而不是在原来的窗口
let g:Lf_PreviewHorizontalPosition = 'right'

" 窗口弹出
let g:Lf_WindowPosition = 'popup'
let g:Lf_WindowHeight = 0.30
let g:Lf_IgnoreCase = 0 " 不忽略大小写

" 控制 LeaderF 记住的搜索历史的数量, 上下键可以查看
let g:Lf_HistoryNumber = 5

" 正则表达式查找 当前光标所在位置的字符串
noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>

" Files you don't want LeaderF to record
let g:Lf_MruFileExclude = ['*.so', '*.o', "*.ko", "*.out"]


""""""""""""""""
" 搜索忽略大小写
"set ignorecase
" 搜索时不忽略大小写
set noic

" 防止上面的 autocmd 切换工作目录
execute 'cd ' . g:original_cwd

"行尾空格高亮
highlight extraSpace ctermbg=red guibg=red  "定义高亮组extraSpace
match extraSpace /\v\s+$/ " 匹配行尾空格
