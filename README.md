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

## 安装说明

-  需要安装

```sh
sudo apt-get install silversearcher-ag

sudo apt-get install cmake

sudo apt-get install ctags
sudo apt install cscope
# 手动编译： https://blog.csdn.net/Czouxiaojun/article/details/124443684

添加到 ~/.bashrc
alias ctags='ctags --fields=+iaS --extra=+q * --languages=c,c++'

# 打开 vim 如果报错，The ycmd server SHUT DOWN (restart with ':YcmRestartServer'). YCM cor...le YCM before using it. Follow the instructions in the documentation，
# 解决方法
/usr/bin/python3 /home/kendall/.vim/bundle/youcompleteme/third_party/ycmd/build.py --verbose


# 安装插件命令
:PluginInstall 
```

- 如果 YcmRestartServer 还报错 

分别执行下面命令升级 cmake

```sh
sudo apt remove --purge cmake
sudo apt-get install cmake
```

- 然后

```sh
# 修改： /usr/share/cmake-3.16/Modules/FindPythonLibs.cmake 
set(_PYTHON3_VERSIONS 3.8 3.7 3.6 3.5 3.4 3.3 3.2 3.1 3.0)  # 3.8 是 python 的版本

sudo ln -s /usr/bin/g++-8  /usr/bin/g++

cmake -G "Unix Makefiles" -DPYTHON_INCLUDE_DIRS=/usr/include/python3 DEXTERNAL_LIBCLANG_PATH=/usr/lib/python3.8/config-3.8-x86_64-linux-gnu/libpython3.8.so  . ~/.vim/bundle/youcompleteme/third_party/ycmd/cpp


/usr/bin/python3 /home/kendall/.vim/bundle/youcompleteme/third_party/ycmd/build.py --clang-completer --racer-completer --verbose
```

### 模糊查找插件

- 两都要下载

```sh
https://github.com/junegunn/fzf
https://github.com/junegunn/fzf.vim

~/simple-vim/vim/bundle$ ls
 fzf  fzf.vim
```

- fzf安装与部署



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

[vimrc配置文件](https://github.com/kendall-cpp/kendall-simple-vim/blob/master/vimrc)

> **以上配置说明仅仅是参考，vimrc 配置会不定期更新，具体见 vimrc**

## 快捷键汇总

建议在项目最顶层目录使用 vim 打开文件， 否则 cscope 会失效。

### cscope + ctags 跳转

先执行 run-gtags

然后可以使用 cscope 快捷键

- cs : 查看函数调用关系，**一般使用这个最多**
- cg : 搜索字符
- ctrl + ] 跳转到函数定义出
- ctrl + t 返回 `ctrl + ]`
- ctrl + o 返回上一处

### 是否自动切换到当前文件目录

按 `'\'` 然后按 cd

### 设置 tab 的空格数

按 '\' 然后按 ct

- 例如输入： 4 no
	- 表示 tab 设置为 4 ,且设置 noexpandtab（不转成空格）
- 例如输入： 8
	- 表示 tab 设置为 8 ,且设置 expandtab（转成空格）

### 语法补全

默认是不开启 YouCompleteMe

可以自行修改 vimrc 文件

```
"Plugin 'ycm-core/YouCompleteMe'    将这行的注释去掉掉即可
```

### 使用 Ag 搜索

直接输入 ag , 在当前文件夹下搜索 光标所在处的字符。

最后结合 `\ + cd` 快捷键使用，这样可以设置搜索的是当前文件的目录，还是整个项目。

- 按 q 可以退出

### 打开文件目录列表窗口

ctrl + b

使用 ctrl + w + 方向键 切换窗口（这是 vim 的快捷键，具体自己网络搜索）

### 打开函数和变量目录列表窗口

ctrl + n
