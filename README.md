## 用集成anaconda的docker快速布置数据分析平台
### 前言
众所周知，`conda`和`docker`是进行快速软件安装、平台布置的两大神器，通过这个软件，在终端前敲几个命令即能安装软件就，出了问题也不会影响到系统配置，能够很轻松的还原和重建。
不过，虽说类似`rstudio`或者`jupyterlab`这样的分析平台能够很快地找到别人已经做好的镜像，但是总有功能缺失，会导致部分R包不能安装，而且有时要让不同的镜像协同工作时，目录的映射，权限的设置会让没有经验的人犯晕。
为了工作需要，我自己写了一个dockerfile，集成了`rstudio server`、`jupyter lab`、`ssh server`、`code server`,，可用于数据分析或生信分析平台的快速布置，也可供linux初学者练习用。 并内置`vim8`、`node`、`yarn`，`ctags`、`gtags`、`ripgrep`等软件，配合本人的[leoatchina的vim配置](https://github.com/leoatchina/leoatchina-vim.git)使用，能在ssh bash环境下进行用`vim`进行代码编写。

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
- 基于ubuntu16.04
- 安装了大量编译、编辑、下载、搜索等用到的工具和库
- 安装了最新版`anaconda`,`Rstudio`
- 安装了`ssh-server`,`code-server`
- 用`supervisor`启动后台web服务
- 美化bash界面
- 集成texlive
- `pkgs.R`和`conda.sh`，收集的一些R包和conda生信软件的安装脚本

### 主要控制点
- 开放端口：
  - 8888: for jupyter lab
  - 8822: for ssh-server
  - 8787: for rstudio server
  - 8443: for code-server
- 访问密码：
  - 见dockerfile里的`ENV PASSWD=jupyter`
  - **运行时可以修改密码**， 而且4种服务的密码一致
- 主目录:
  - jupyter： `/jupyter`
  - rstudio： `/home/rserver`

### 使用docker-compose命令
- `docker-compose -f /home/docker/compose/bioinfo/docker-compose.yml up -d`
- `docker-compose.yml`的详细内容如下
```
version: "3"  # xml版本
services:
  jupyter:
    image: leoatchina/datasci  # 使用前面做出来的镜像
    environment:
      - PASSWD=password   # PASSWD ， 在Docker-file里的 `ENV PASSWD=jupyter`
    ports:     # 端口映射，右边是container里的端口，左边是实际端口，比如我就喜欢实际端口在内部端口前加2或1。
      - 48787:8787
      - 48888:8888
      - 8443:8443
      - 8822:8822
    volumes:   # 位置映射，右docker内部，左实际
      - /data/bioinfo:/mnt/bioinfo   # 个人习惯，里面会放一些参考基因组等
      - /home/github:/mnt/github     # 个人习惯2，比如我的vim配置会放里面
      - /tmp:/tmp
      - ./root/.ssh:/root/.ssh   # 这个是为了一次通过ssh-keygen生成密钥后，能多次使用
      - ./root/.vim:/root/.vim   # 为了不同的container能重复利用一套已经下载的vim插件
      - ./root/.fzf:/root/.fzf   # 为了不同的container能重复利用一套已经下载的vim插件
      - ./jupyter:/jupyter       # 关键目录之1，jupyter的主运行目录
      - ./rserver:/home/rserver  # 关键目录之2，rtudio的工作目录
    # build: ./build
    container_name: datasci
```
会运行一个名为`datasci`的`container`
如在启动里想安装相应软件，可以在运行时用`build`指定一个放有`Dockerfile`的目录，如上面的`./build`,安装`tensorflow`, `opencv`
```
FROM leaotchina/datasci
RUN pip install -q tensorflow_hub
RUN conda install tensorflow && conda install -c menpo opencv

```

### 使用docker run命令启动镜像
不推荐这种方法，请自行研究如何

### 运行后的操作
- 默认密码各个服务都一样为`jupyter`，在启动时可以修改
- **ssh-server**, 注意映射端口，对应`8822`，用户名是`root`,可以安装`YCM`, `vista.vim`, `gtags`，`leader`等功能强大的vim插件，配置成轻型IDE
- jupyterlab, 通过`file->new->terminal`输入`bash`,就会打开一个有高亮的 shell环境
![jupyterlab](https://leoatchina-notes-1253974443.cos.ap-shanghai.myqcloud.com/Notes/2019/3/7/1551925588870.png)
- rstudio, 登陆用户名是`rserver`
![rstudio](https://leoatchina-notes-1253974443.cos.ap-shanghai.myqcloud.com/Notes/2019/3/7/1551925709976.png)
- code-sever, 密码和前面的一样
![code-server](https://www.github.com/leoatchina/leoatchina-notes/raw/master/Notes/2019/5/4/1556964572166.png)

两大优点
1. 只要你记得你的访问密码PASSWORD、IP、端口，就可以通过网页端进行操作。
2. 启动`perl`，`python`,`shell`的分析流程后，**可以直接关闭网页**，不需要用`nohup`启动，下次重新打开该页面还是在**继续运行你的脚本** 。

### `.jupyterc`
众所周知，bash在启动时，会加载用户目录下的`.bashrc`进行一些系统变量的设置，同时又可以通过`source`命令加载指定的配置。为了达到`安装的软件`和`container分离`的目的，在删除container时不删除安装的软件的目的, root目录下的`.bashrc`（集成在镜像里) : `source /juoyter/local/.jupyterc`,这样灵活地对系统路径进行配置,。这个`.jupyterc`文件要自行建立。
我的`.jupyterc`
```
export PATH=/opt/anaconda3/bin:$PATH   # 这一条如果不加，在ssh进入的环境中 /opt/anaconda3/bin 不会放入$PATH中， 也就不能调用 conda等命令
export PATH=$PATH:/jupyter/bioinfo/bin
export PATH=$PATH:/jupyter/bioinfo/annovar
export PATH=$PATH:/jupyter/bioinfo/firehose
export PATH=$PATH:/jupyter/bioinfo/gatk4
```

### 一个应用：用conda快速安装生信软件
各位在学习其他conda教程时，经常会学到`conda create -n XXX`新建一个运行环境以满足特定安装需求，还可以通过`source activate`激活这个环境。
但其实还有一个参数`-p`用于指定安装目录，利用了这一点，我们就可以把自己`docker`里`conda`安装软件到`非conda内部目录`，而是`映射过来的目录`。
```
conda install -p /jupyter/bioinfo -c bioconda roary
```
![enter description here](https://leoatchina-notes-1253974443.cos.ap-shanghai.myqcloud.com/Notes/2019/3/7/1551926299681.png)

如此，就安装到对应的位置，如`samtools`,`bcftools`,`varscan`等一众生信软件都可以如此安装。
在安装这些软件相应`container`被删除后，这些通过`-p`安装上的软件不会随着删除，下次重做`container`只要目录映射一致，**不需要重装软件，不需要重装软件，不需要重装软件**。

以些，就可快速布置软件并有以下好处
1. 启动分析流程后，发现代码写错了要强行结束时，只要删除`container`，不需要一个个去kill进程
2. 在另一个机器上快速搭建分析环境，把`docker-file`在新机器上`bulid`下，各个`.xxxrc`文件放到正确的位置，然后把已经装上的软件复制过去就能搭建好分析环境。
3. 可以用`code-server`, `ssh`登陆container直接进行代码编写
