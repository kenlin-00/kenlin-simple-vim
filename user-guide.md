

## 下载 simple-vim 和安装

### git clone simple-vim

```sh
git clone https://github.com/kenlin-00/kenlin-simple-vim.git -b master $HOME/simple-vim
```

###  配置 simple-vim

```sh
cd ~/simple-vim
./update.sh
```

- 安装 vim

```sh
sudo apt install vim-nox
```

- **编译安装 vim-8.2**


```sh
udo apt-get install python3-dev
udo apt install libncurses5-dev
udo apt-get install vim-nox
sudo apt-get install libcurl4-openssl-dev


cd ~/simple-vim/tools
wget https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2
# 或者直接使用 cp all-pkg/vim-8.2.tar.bz2 .
tar -xf vim-8.2.tar.bz2
rm vim-8.2.tar.bz2
cd vim82
./configure --with-features=huge --prefix=$HOME/simple-vim/tools/vim82/output/ --enable-gui=gtk3 --with-tlib=ncursesw --enable-pythoninterp=yes  --enable-python3interp=yes
make -j4
make install
# 最后将 ~/simple-vim/tools/vim82/output/bin 加入环境变量
```

- **安装 nodejs**

```sh
cd ~/simple-vim/tools
cp ./all-pkg/node-v20.10.0-linux-x64.tar.xz .
tar xf node-v20.10.0-linux-x64.tar.xz
rm node-v20.10.0-linux-x64.tar.xz
# 解压出来可以直接用，将 node 加入环境变量 ~/simple-vim/tools/node-v20.10.0-linux-x64/bin
```

- **安装 Coc 插件** (用于C/C++ 提示)

```sh
进入 vim
vim xxx.cpp
:CocInstall coc-clangd coc-vimlsp # 安装C++相关依赖, 可能需要在一个 c++ 文件中执行
:CocCommand clangd.install  # 安装C++相关依赖, 可能需要在一个 c++ 文件中执行
# 这一步可能需要设置 npm 代理
npm config set  proxy http://xxxxx
npm config set  https-proxy http://xxxxx
# 将 /home/dgt/.config/coc/extensions/coc-clangd-data/install/19.1.2/clangd_19.1.2/bin 加入环境变量
```

- **安装 Coc python 插件** (用于python提示)

```sh
pip3 install python-language-server[all]
vim xxx.py
:CocInstall coc-pyright
```

- **安装 global** (使用 gtags)

```sh
cd ~/simple-vim/tools
cp ./all-pkg/global-6.6.8.tar.gz  .
tar zxf global-6.6.8.tar.gz
rm global-6.6.8.tar.gz
cd global-6.6.8
chmod 777 ./configure && ./configure --prefix=$HOME/simple-vim/tools/global-6.6.8/output
make -j8
make install
# 把 ~/simple-vim/tools/global-6.6.8/output/bin 加入环境变量
```

- **安装 ctags**

```sh
# 如果已经有 ctags，可以跳过该步骤
# 如果有 sudo 权限可以直接安装
sudo apt-get install ctags

# 如果公司服务器没有root权限，只能单独编译，可以参考步骤。
cd ~/simple-vim/tools
git clone https://github.com/universal-ctags/ctags.git -b master ctags
# git reset --hard be5b1fc65e537093a6f1ec339b04bb45d044b980 (如果最新的code无法编译可以尝试回退，否则忽略)
./autogen.sh
./configure --prefix=$HOME/simple-vim/tools/ctags/output
make -j8
make install
# 将 ~/simple-vim/tools/ctags/output/bin/ctags 加入环境变量
```

- **搜索插件 ag** （可以加快查找速度，不使用可以忽略）

```sh
# 如果已经有 ag 命令，可以跳过该步骤
# 如果有 sudo 权限可以直接安装
sudo apt-get install silversearcher-ag

# 如果公司服务器没有root权限，只能单独编译，可以参考步骤。
cd ~/simple-vim/tools
wget https://geoff.greer.fm/ag/releases/the_silver_searcher-2.2.0.tar.gz
tar zxf the_silver_searcher-2.2.0.tar.gz
rm the_silver_searcher-2.2.0.tar.gz
cd the_silver_searcher-2.2.0
# 有可能会依赖 sudo apt install liblzma-dev
./configure --prefix=$HOME/simple-vim/tools/the_silver_searcher-2.2.0/output
make -j8
make install
# 将 simple-vim/tools/the_silver_searcher-2.2.0/output/bin 加入环境变量

# 使用方法见后面总结
```

- **安装 fzf** (加快文件查找)

官网： https://github.com/junegunn/fzf

```sh
cd ~/simple-vim/tools
git clone --depth 1 https://github.com/junegunn/fzf.git
# git reset --hard b5f94f961dbf9e5d12b7ac5a5b514d12be89cb97
cd fzf
./install
# 生成环境变量文件 ~/.fzf.bash
#  把下面一句添加到 ~/.bashrc
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# 使用方法见后面总结
```

## 常用快捷键汇总

### ctrl+s 保存文件

注意需要把 echo stty -ixon 加入环境变量，防止锁住终端

```sh
echo "stty -ixon" >> ~/.bashrc
```

### 生成代码跳转文件

```sh
# 可以直接使用我写好的脚本 run_tags.sh
export PATH=$HOME/simple-vim:$PATH

# 使用示例，目前最多支持三个目录
run-tags.sh ./kernel-6.6/ ./common_drivers/ ./wifi-sdk
run-tags.sh ./kernel-6.6/ ./common_drivers/
run-tags.sh .
# 会生成 GPATH  GRTAGS  GTAG tags 跳转文件
run-tags.sh clean # 清空跳转文件

# 使用 vim 在 GPATH  GRTAGS  GTAG tags 跳转文件 的目录打开代码，就能实现代码跳转
vim kernel-6.6/drivers/leds/leds-pwm.c
```

- ccs : 查看函数调用关系
- ccg : 搜索字符
- ccc : 搜索被调用的地方，**一般使用这个最多**
- ctrl + ] 跳转到函数定义处
- ctrl + t 返回 `ctrl + ]`跳转的地方
- ctrl + o 返回上一处


### 切换到当前文件目录

按 `'\'` 然后按 cd； 可以选择是否进入当前文件的路径。因为 vim 一般是在 代码源目录打开，使用 \ cd 就能进入打开的文件的目录。

### 设置 tab 的空格数

按 “\” 然后按 ct

- 例如输入： 4 no
	- 表示 tab 设置为 4 ,且设置 noexpandtab（不转成空格）
- 例如输入： 8
	- 表示 tab 设置为 8 ,且设置 expandtab（转成空格）


### 打开文件目录列表窗口

ctrl + b

使用 ctrl + w + 方向键 切换窗口（这是 vim 的快捷键，具体自己网络搜索）

- 使用 回车键 打开文件
- 也可以使用 t 打开文件, 然后使用 gt 切换（感觉不实用）

### 打开函数和变量目录列表窗口

ctrl + n

### 模糊搜索文件和查看

```sh
ctrl + p

# 按 ctrl + j/k  上下选择
# 按 ctrl + 上键/下键  代码串口上下滚动

ctrl + f + 回车  # 查找当前鼠标所在位置的字符串
# 按 ctrl + j/k  上下选择
```

- 也可以模糊查找文件打开，在不记得代码具体路径是可以很方便打开文件。 (fzf)

```sh
vim **  # 然后安装 tab
# 输入要查找关键字就能 按回车 打开文件
```

###  其他

```sh
vim -O filt1.txt file2.txt  # 左右窗口打开两个文件
vim -o filt1.txt file2.txt  # 上下窗口打开两个文件
ctrl + w + w  或者  ctrl + w + 方向键 切换窗口

ctrl + # 先上搜索
ctrl + * 向下搜索
也可以按 n 或者 N 上下搜索

vim -t <函数名> 可以直接打开并跳到该函数位置，例如 vim -t OnUsbAudioUevent (在 ctags 文件目录执行)

手动粘贴时格式不会乱，先打开粘贴模式，再粘贴
\ + vp

查看当前文件 tab 大小,最后通过上面 ct 快捷键来设置
:set tabstop

为了方向显示代码对齐，我打开了上下tab 对齐线，但是如果需要用鼠标复制可能不方便，可以使用如下方式隐藏
:set nolist  # 也亏直接在 .vimrc 中关掉
```

**其他的可以仔细查阅 .vimrc , 我都写了中文注释。**

