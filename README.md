# README

## All Plug include

> **总结一款 simple-vim 插件配置，满足日常工作**，已经删除其他不常用的插件，配置文件中基本都有中文注释。

```sh
Plugin 'VundleVim/Vundle.vim'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'mhinz/vim-startify'   " 输入 vim 显示图案好看
Plugin 'tomasr/molokai'
Plugin 'flazz/vim-colorschemes'
Plugin 'rking/ag'
```

## 使用方法

- 备份和新增 vimrc 配置

> vimrc 配置见文末 

```sh
mv ~/.vim ~/vim-bak
mv ~/.vimrc ~/vimrc-bak

mkdir ${HOME}/simple-vim/
# 下载和并存 vimrc 和 vim 在 ${HOME}/simple-vim/

ln -s ~/simple-vim/vim ~/.vim
ln -s ~/simple-vim/vimrc ~/.vimrc 
```

- 通过 Vundle 下载插件

建议翻墙再下载，或者直接从我这拷贝已经下载好的插件 (`shegnken.lin@amlogic.com`)

```sh
vim
:PluginInstall  # 下载
:PluginList  # 列出所有插件
```

![](https://cdn.staticaly.com/gh/kendall-cpp/blogPic@main/blog-01/image.3r29mtbsf8a0.webp)

- 一切准备就绪后可以使用 run-gtags.sh 在 your-project-source-core 下生成索引文件

## run-gtags.sh

```sh
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
```

## vimrc 

```sh

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

" kernel 建议增加下面几行配置
autocmd FIletype json,xml,c,cpp,h,vim,conf,bind,gitcommit setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab 
autocmd FIletype make,tags,kconfig,txt,mk,def setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab "expandtab 转成空格
autocmd FIletype sh setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FIletype dtsi,dts setlocal tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab
" 其他的默认为4
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab  " 不转成空格

set nocompatible
filetype off

" Vundle 插件管理器设置
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 在此处添加您需要安装的插件
" Plugin '插件名称'
Plugin 'VundleVim/Vundle.vim'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'mhinz/vim-startify'   " 输入 vim 显示图案好看
Plugin 'tomasr/molokai'
Plugin 'flazz/vim-colorschemes'
call vundle#end()
filetype plugin indent on

" 不使用任何插件管理的插件
set runtimepath^=~/.vim/bundle/ag

" ag
nmap ag :Ag -w <C-R>=expand("<cword>")<CR><CR>   "Ag 查找当成层级
nmap af :Ag -w <C-R>=expand("<cword>")<CR> ../<CR> "Ag 查找上一级匹配

" tagbar 显示函数名和变量
let g:tagbar_ctags_bin='/usr/bin/ctags'          "ctags程序的路径
let g:tagbar_left=1 "显示在左边
let g:tagbar_width=30                  "窗口宽度的设置
map <C-n> :Tagbar<CR>
"autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx call tagbar#autoopen() "如果是c语言的程序的话，tagbar自动开启

" nerdtree 目录树
map <C-b> :NERDTreeToggle<CR>
let NERDTreeWinPos='right'
"autocmd vimenter * NERDTree  "自动开启Nerdtree  文件列表
wincmd w   " 自动打开后光标在代码区
autocmd VimEnter * wincmd w
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

"molokai 主题
"colorscheme molokai "设置颜色主题"
set t_Co=256 "设置256色彩"
set background=dark
let g:molokai_original=1
let g:rehash256 = 1
" colorschemes
colorscheme gruvbox
  
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
```
