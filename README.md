# 用集成miniconda3的docker快速布置数据分析平台

## 前言
众所周知，`conda`和`docker`是进行快速软件安装、平台布置的两大神器，通过这个软件，在终端前敲几个命令即能安装软件就，出了问题也不会影响到系统配置，能够很轻松的还原和重建。

不过，虽说类似`rstudio`或者`jupyter lab`这样的分析平台，已经有别人已经做好的镜像，但是通常是最小化安装，常有系统软件动态库缺失，直接后果是导致部分R包不能安装，而且有时要让不同的镜像协同工作时，目录的映射，权限的设置会让没有经验的人犯晕。比如`jupyterlab`通常是以`root`权限运行，生成的文件用`rstudio`打开就不能保存。

为了克服上述问题，本人设计了一个docker image，集成了`rstudio server`、`jupyter lab`、`ssh server`、`code server`,可用于数据分析或生信分析平台的快速布置，也可供linux初学者练习用。

## 安装方法
- 直接pull(建议使用这种方法)
```
docker pull leoatchina/datasci:latest
```
- build docker镜像
要先装好`docker-ce`和`git`。

## 主要集成软件
- 基于ubuntu16.04
- 安装了大量编译、编辑、下载、搜索等用到的工具和库
- 安装了最新版`miniconda3`,`Rstudio-server`
- 安装了`ssh-server`,`code-server`
- 用`supervisor`启动后台web服务
- 美化bash界面
- install_scripts下面的`pkgs.R`和`conda.sh`，收集的一些R包和conda生信软件的安装脚本

## 2019年8月8日，增加了好多个特性
- 运行时可以自定义用户名， 用 `WKUSER`变量指定，默认是`datasci`。 可指定不小于1000的`UID`，默认为`1000`。
- `jupyterlab`和`rstudio`和`code-server`都是以上述用户权限运行，这样就解决了原来**文件权限不一样的问题**，默认密码是`jupyter`， 可用`PASSWD`变量指定。
- `ssh-server`可用`root`或者自定义用户登陆 ，`root`密码默认和自定义用户密码一致，可用`ROOTPASSWD`变量另外指定。
- ~~由于`jupyterlab`非root权限，因此，如不开放ssh端口不以`root`连入，不能装插件，也不能用`apt`等装系统软件，只能往自己的用户目录下用`conda`命令装软件 ，一定程度上提高了安全性。~~
- 我是如何解决权限问题的请打开[entrypoint.sh](entrypoint.sh)这个启动脚本学习。
- ~~`jupyterlab` 里集成了`table of content`, `variableinspect`, `drawio`等插件， 使用体验已接近`rstudio`。~~
- 内置`neovim`、`node`、`yarn`，`uctags`、`gtags`、`ripgrep`等软件，能在ssh bash环境下进行用`vim`进行代码编写。
  - 此处推荐下本人的[leoatchina的vim配置](https://github.com/leoatchina/leoatchina-vim.git)使用，接近一个轻型IDE，有按键提示，高亮、补全、运行、检查一应具全。
- 内置`tmux`。 这里又强推下本人的配置 [tmux config](https://github.com/leoatchina/leoatchina-tmux.git)
  - ln -s leoatchina-tmux/.tmux.conf ~/.tmux.conf
  - `Alt+I`插入新tab, `Alt+P`往前翻,`Alt+N`往后翻
  - `Alt+Shift+I`关闭当前tab, `Alt+Shift+P`往前移，`Alt+Shift+N`往后移
  - 先导键是`ctrl+X`

## 2019年10月31号
在实际工作中发现因为jupyterlab服务，是由`root`账户用以`supervisor`程序以`非root`权限启动后，会出现一系列问题，所以现在改用手动启动，相应配置文件直接写入到`/opt/config/jupyter_lab_config.py`中手动启动，启动后密码同`rstudio server`
### 启动方法一
- 用非root账户ssh进入后，然后`jupyter lab --config=/opt/config/jupyter_lab_config`，然后访问8888端口
### 方法二， 我喜欢这种
- 启动后，打开`Rstudio Server`，切换到`Terminal`，然后 `jupyter lab --config=/opt/config/jupyter_lab_config`。
### 内置tmux
- 当然，我更喜欢启动`tmux`后再启动`jupyter lab`， 这样能保证在关掉ssh终端或者在rstudiostuido的terminal里能复用终端

## 主要控制点
- 开放端口：
  - 8888: for jupyter lab
  - 8787: for rstudio server
  - 8686: for code-server
  - 8585: for ssh-server
- 访问密码：
  - 见dockerfile里的`ENV PASSWD=datasci`
  - **运行时可以修改密码**
- 目录:
  - 默认`/home/datasci`或者`/home/你指定的用户名`,以下以用户名为`datasci`为例
  - `/root`目录

## 使用docker-compose命令
- `docker-compose -f datasci.yml up -d`
- `docker-compose.yml`的详细内容如下
```
version: "3"  # xml版本
services:
  datasci:
    image: leoatchina/datasci:latest
    environment:
      - PASSWD=yourpasswd  # PASSWD
      - ROOTPASSWD=rootpasswd # 区分普通用户的root密码，如没有，和普通用户相同
      - WKUSER=datasci   # 指定用户名
      - WKUID=23333   # 指定用户ID, 默认是1000
      - WKGID=23333   # 指定用户GROUPID，默认是1000 ， 这个和WKUID设置成和宿主一致可以搞
    ports:     # 端口映射，右边是container里的端口，左边是实际端口
      - 8787:8787
      - 8888:8888
      - 8686:8686
      - 8585:8585
    volumes:   # 位置映射，右docker内部，左实际
      - ./pkgs:/opt/miniconda3/pkgs   # 这个不映射在某些低级内核linux上用conda安装软件时会有问题
      - ./datasci:/home/datasci  # 工作目录， 要和上面的WKUSER一致
      - ./log:/opt/log  # 除rstudio外的log目录
      - ./root:/root # root目录
    container_name: datasci
```
如上，会生成一个名为`datasci`的container。

如在启动里想安装相应软件，可以在运行时用`build`指定一个放有`Dockerfile`的目录

如上面的yml文件，把`image`这一行换成`build: ./build`， 在`./build`目录下建立`Dockerfile` ，运行时就会安装`tensorflow`, `opencv`
```
FROM leaotchina/datasci:latest
RUN pip install -q tensorflow_hub
RUN conda install tensorflow && conda install -c menpo opencv
```

## 使用docker run命令启动镜像
不推荐这种方法，请自行研究如何

## 运行后的操作
- 默认密码各个服务都一样为`datasci`，可在yml文件里调整
- **ssh-server**端口`8585`，用户名是`root`和`datasci`， 注意`root`密码可以和普通用户不一致
- jupyterlab, 通过`file->new->terminal`输入`bash`,就会打开一个有高亮的 shell环境
![jupyterlab](https://leoatchina-notes-1253974443.cos.ap-shanghai.myqcloud.com/Notes/2019/3/7/1551925588870.png)
- rstudio
![rstudio](https://leoatchina-notes-1253974443.cos.ap-shanghai.myqcloud.com/Notes/2019/3/7/1551925709976.png)
- code-sever, 要忽略掉`warning`才能打开
![code-server](https://www.github.com/leoatchina/leoatchina-notes/raw/master/Notes/2019/5/4/1556964572166.png)
- 以此，就可快速布置软件环境并有以下好处
  1. 启动分析流程后，发现代码写错了要强行结束时，只要删除`container`，不需要一个个去kill进程
  2. 在另一个机器上快速搭建分析环境，把已经装上的软件复制过去就能搭建好分析环境。
  3. 可以用`code-server`, `ssh`登陆container直接进行代码编写

## 插件特殊说明
- `rstudio`和`code-server`的插件都会放到`/home/datasci`下
- 用`jupyterlab  labextension install` 安装jupyterlab的插件, 最后要build
```
jupyter labextension install @jupyter-widgets/jupyterlab-manager &&
jupyter labextension install ipysheet &&
jupyter labextension install @jupyterlab/toc &&
jupyter labextension install jupyterlab-drawio &&
jupyter labextension install jupyterlab-kernelspy &&
jupyter labextension install jupyterlab-spreadsheet &&
jupyter labextension install @mflevine/jupyterlab_html &&
jupyter labextension install @krassowski/jupyterlab_go_to_definition &&
jupyter labextension install @telamonian/theme-darcula &&
jupyter labextension install @mohirio/jupyterlab-horizon-theme &&
jupyter labextension install jupyterlab_vim &&
jupyter labextension install @lckr/jupyterlab_variableinspector &&
jupyter lab build
```

## 环境变量
众所周知，bash在启动时，会加载用户目录下的`.bashrc`进行一些系统变量的设置，同时又可以通过`source`命令加载指定的配置。本镜像内置的`.bashrc`会source`$HOME`下面的`.configrc`文件，可以在在里面自行设置。
能达到`安装的软件`和`container分离`, 在删除container时不删除安装的软件的目的

**应用：用conda快速安装生信软件**
各位在学习其他conda教程时，经常会学到`conda create -n XXX`新建一个运行环境以满足特定安装需求，还可以通过`conda activate`激活这个环境。

但其实还有一个参数`-p`用于指定安装目录，利用了这一点，我们就可以把自己`docker`里`conda`安装软件到`非conda内部目录`，而是`映射过来的目录`。如下
```
conda install -p /home/datasci/bioinfo -c bioconda roary
```
![enter descriptiowork](https://leoatchina-notes-1253974443.cos.ap-shanghai.myqcloud.com/Notes/2019/3/7/1551926299681.png)

就安装到对应的位置，如`samtools`,`bcftools`,`varscan`等一众生信软件都可以如此安装。

由于在`.configrc`里作了路径配置，这些软件即时能用！

在安装这些软件相应`container`被删除后，这些通过`-p`安装上的软件不会随着删除，下次重做`container`只要目录映射一致，**不需要重装软件，不需要重装软件，不需要重装软件**。

## BUGS
1. 用`conda`安装的并激活一个环境中，报和`libcurl.so`相关的错误

把你 对应目录下的 `lib/libcurl.so.4`给删除掉，或者从 `/usr/lib/x86_64-linux-gnu`下链接过来

2. 最近发现jupyter lab升级后，装插件后会显示异常

发现是build过程中的问题，要性能强的服务器才能顺利完成这个工作。

3. 安装tidyvers包出问题

google后发现问题出在haven和reaxl包上, 用下面方法解决
> withr::with_makevars(c(PKG_LIBS = "-liconv"), install.packages("haven"), assignment = "+=")
  withr::with_makevars(c(PKG_LIBS = "-liconv"), install.packages("readxl"), assignment = "+=")
