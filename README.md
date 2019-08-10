## 用集成anaconda的docker快速布置数据分析平台
### 前言
众所周知，`conda`和`docker`是进行快速软件安装、平台布置的两大神器，通过这个软件，在终端前敲几个命令即能安装软件就，出了问题也不会影响到系统配置，能够很轻松的还原和重建。

不过，虽说类似`rstudio`或者`jupyter lab`这样的分析平台，已经有别人已经做好的镜像，但是通常是最小化安装，常有系统软件动态库缺失，直接后果是导致部分R包不能安装，而且有时要让不同的镜像协同工作时，目录的映射，权限的设置会让没有经验的人犯晕。比如`jupyterlab`通常是以`root`权限运行，生成的文件用`rstudio`打开就不能保存。

为了克服上述问题，本人设计了一个docker image，集成了`rstudio server`、`jupyter lab`、`ssh server`、`code server`,可用于数据分析或生信分析平台的快速布置，也可供linux初学者练习用。 


### 安装方法
- 直接pull(建议使用这种方法)
```
docker pull leoatchina/datasci
```

- build docker镜像
要先装好`docker-ce`和`git`
```
git clone https://github.com/leoatchina/leoatchina-datasci.git
cd leoatchina-datasci
docker build -t leoatchina/datasci .
```

### 主要集成软件
- 基于ubuntu16.04,后期可能会使用ubuntu18.04
- 安装了大量编译、编辑、下载、搜索等用到的工具和库
- 安装了最新版`anaconda`,`Rstudio-server`
- 安装了`ssh-server`,`code-server`
- 用`supervisor`启动后台web服务
- 美化bash界面
- `pkgs.R`和`conda.sh`，收集的一些R包和conda生信软件的安装脚本

### 2019年8月8日，增加了好多个特性
- 可选`Anaconda3`或`Anaconda2`， 默认是`Anaconda3`，编译时用`ANACONDAVERSION`指定
- 运行时可以自定义用户名， 用 `WKUSER`变量指定，默认是`datasci`，UID为`8888`。
- `jupyterlab`和`rstudio`和`code-server`都是以上述用户权限运行，这样就解决了原来**文件权限不一样的问题**，默认密码是`jupyter`， 可用`PASSWD`变量指定。
- `ssh-server`可用`root`或者自定义用户登陆 ，`root`密码默认和自定义用户密码一致，可用`ROOTPASSWD`变量另外指定。
- 由于`jupyterlab`非root权限，因此，如不开放ssh端口不以`root`连入，不能装插件，也不能用`apt`等装系统软件，只能往自己的用户目录下用`conda`命令装软件 ，一定程度上提高了安全性。
- `jupyterlab` 里集成了`table of content`, `variableinspect`, `drawio`等插件， 使用体验已接近`rstudio`。
- 内置`neovim`、`node`、`yarn`，`uctags`、`gtags`、`ripgrep`等软件，能在ssh bash环境下进行用`vim`进行代码编写。
  - 此处推荐下本人的[leoatchina的vim配置](https://github.com/leoatchina/leoatchina-vim.git)使用，接近一个轻型IDE，有按键提示，高亮、补全、运行、检查一应具全。
- 内置`tmux`。 这里又强推下本人的配置 [tmux config](https://github.com/leoatchina/leoatchina-tmux.git)
  - ln -s leoatchina-tmux/.tmux.conf ~/.tmux.conf
  - `Alt+I`插入新tab, `Alt+P`往前翻,`Alt+N`往后翻
  - `Alt+Shift+I`关闭当前tab, `Alt+Shift+P`往前移，`Alt+Shift+N`往后移
- 内置`fzf`，你进入bash环境后按`ctral+T`试试
- 除常规PATH路径外， 还把`/opt/anaconda/bin`和 `/root/bin`分别放入$PATH的`最前和最后`，可以把部分软件放入`/root/bin`中
  
### 主要接口
- 开放端口：
  - 8888: for jupyter lab
  - 8822: for ssh-server
  - 8787: for rstudio server
  - 8443: for code-server
- 访问密码：
  - 见dockerfile里的`ENV PASSWD=jupyter`
  - **运行时可以修改密码**
- 目录: 
  - `/home/datasci`或者`/home/你指定的用户名`
  - `/root`目录

### 使用docker-compose命令
- `docker-compose -f /home/docker/compose/bioinfo/docker-compose.yml up -d`
- `docker-compose.yml`的详细内容如下
```
version: "3"  # xml版本
services:
  datasci:
    image: leoatchina/datasci  
    environment:
      - PASSWD=yourpasswd  # PASSWD 
      - ROOTPASSWD=rootpasswd # 区分普通用户的root密码，如没有，和普通用户相同
      - WKUSER=yourname   # 指定用户名
    ports:     # 端口映射，右边是container里的端口，左边是实际端口
      - 8787:8787
      - 8888:8888
      - 8443:8443
      - 8822:8822
    volumes:   # 位置映射，右docker内部，左实际
      - ./pkgs:/opt/anaconda/pkgs   # 这个不映射在某些低级内核linux上会有问题
      - ./jupyter:/opt/anaconda/share/jupyter   # 此目录是jupyterlab 插件目录,在启动 
      - ./yourname:/home/yourname  # 工作目录
      - ./log:/opt/log  # 除rstudio外的log目录
      - ~/github:/mnt/github     # 个人习惯，比如我的vim配置会放在这里面
      放里面
      - ./root:/root # root目录，/root/bin会放入$PATH中
    container_name: datasci
```
如上，会生成一个名为`datasci`的container
如在启动里想安装相应软件，可以在运行时用`build`指定一个放有`Dockerfile`的目录
如上面， 把`image`这一行换成`build: ./build`， 在`./build`目录下建立`Dockerfile` ,安装`tensorflow`, `opencv`
```
FROM leaotchina/datasci
RUN pip install -q tensorflow_hub
RUN conda install tensorflow && conda install -c menpo opencv
```

### 使用docker run命令启动镜像
不推荐这种方法，请自行研究如何

### 运行后的操作
- 默认密码各个服务都一样为`jupyter`，可在yml文件里调整
- **ssh-server**端口`8822`，用户名是`root`或`你指定的用户名`
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

### 环境变量
众所周知，bash在启动时，会加载用户目录下的`.bashrc`进行一些系统变量的设置，同时又可以通过`source`命令加载指定的配置。
为了达到`安装的软件`和`container分离`, 在删除container时不删除安装的软件的目的, 本镜像内置的`.bashrc`会source`$HOME`下面的`.configrc`文件，可以在在里面自行设置

```
export PATH=$PATH:/root/bioinfo/bin
export PATH=$PATH:/root/bioinfo/annovar
export PATH=$PATH:/root/bioinfo/firehose
export PATH=$PATH:/root/bioinfo/gatk4
```
### jupyterlab的特殊说明
- `rstudio`和`code-server`的插件都会放到`/home/yourname`下
- 由于`jupyterlab`是用`root`权限的`supervisor`用`非root`启动， 因此虽然侧边工作目录已经移到`/home/yourname`下，但启动bash后还是在`/`目录下，而且主目录是 `/root`(矛盾吧，主目录为root的非root账户，**但ssh进去就正常了**)， 要自行 `CD /home/yourname`目录。
- `jupyterlab`已经内置多个插件，这些插件是在`container`启动里从另一目录`rsync`到 `/opt/anaconda/share`下
  - 因此只要在yml文件中映射一目录到`/opt/anaconda/share/jupyter`，自行再安装的插件就能保存
  - 但是还是因为权限问题，要用`root`账户进入后用用 `jupyter labextension install xxx`再`jupyter lab build`才能安装并激活相应插件
  - 请在`settings`里`enable` extensions


### 一个应用：用conda快速安装生信软件
各位在学习其他conda教程时，经常会学到`conda create -n XXX`新建一个运行环境以满足特定安装需求，还可以通过`source activate`激活这个环境。
但其实还有一个参数`-p`用于指定安装目录，利用了这一点，我们就可以把自己`docker`里`conda`安装软件到`非conda内部目录`，而是`映射过来的目录`。
```
conda install -p /work/bioinfo -c bioconda roary
```
![enter descriptiowork(https://leoatchina-notes-1253974443.cos.ap-shanghai.myqcloud.com/Notes/2019/3/7/1551926299681.png)

如此，就安装到对应的位置，如`samtools`,`bcftools`,`varscan`等一众生信软件都可以如此安装。
在安装这些软件相应`container`被删除后，这些通过`-p`安装上的软件不会随着删除，下次重做`container`只要目录映射一致，**不需要重装软件，不需要重装软件，不需要重装软件**。