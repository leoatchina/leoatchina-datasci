# 用集成了anaconda的docker镜像快速布置生信分析平台

## 前言
众所周知，`conda`和`docker`是进行快速软件安装、平台布置的两大神器，通过使用这两个软件，在终端前敲几个命令、点点鼠标，软件就装好了。出了问题也不会影响到系统配置，能够很轻松的还原和重建。
由于实际进行生信分析工作的需要,本着**不折腾不舒服**的本人一惯风格，我自己写了一个dockerfile，集成了`rstudio server`、`jupyter lab`，可用于生信分析平台的快速布置，也可供linux初学者练习用。

## 我的dockerfile地址
[https://github.com/leoatchina/jupyterlab_rstudio](https://github.com/leoatchina/jupyterlab_rstudio)
觉得好给个**star**吧!

## 下载安装
### build from dockerfile
如何安装docker请自行搜索
```
git clone https://github.com/leoatchina/jupyterlab_rstudio
cd jupyterlab_rstudio
docker build -t leoatchina/jupyterlab_rstudio .
```

### 直接pull
我已经把这个镜像传到官方,直接pull即可
```
docker pull leoatchina/jupyterlab_rstudio
```

## 主要工作
- 基于ubuntu16.04
- 安装了一些编译、编辑、下载、搜索等用到的工具和库,有一部分是安装rstudio某些包所需
- 安装了最新版`anaconda`,`rstudo`
- 安装了部分`bioconductor`工具
- 用`supervisor`启动后台web服务

## 开放接口
- 开放端口：
  - 8888: for jupyter lab
  - 8787: for rstudio server
- 访问密码：
  - 见dockerfile里的`ENV PASSWD=jupyter`
  - 运行时可以修改成你自己喜欢的密码
- 主目录:
  - jupyter： `/jupyter`
  - rstudio： `/home/rserver`
  - VOLUME ["/home/rserver","/jupyter","/mnt","/disks"]

## 运行
### 1. 使用docker-compose
- `docker-compose -f /home/docker/compose/bioinfo/docker-compose.yml up -d`, `-d`代表在后台工作
- `docker-compose.yml`的详细内容如下
```
version: "3"
services:
  jupyter:
    image: leoatchina/jupyterlab_rstudio  # 使用前面做出来的jupyter镜像
    environment:
      - PASSWD=password   # PASSWD ， 对应Dockerfile里的 `ENV PASSWD=jupyter`
    ports:     # 端口映射，右边是container里的端口，左边是实际端口，比如我就喜欢实际端口为内部端口前加2或1。
      - 28787:8787
      - 28888:8888
    volumes:   # 目录映射，右docker内部路径，左实际路径
      - /mnt/bioinfo:/mnt/bioinfo   # 个人习惯，里面会放一些参考基因组等
      - /mnt/github:/mnt/github     # 个人习惯2，比如我的vim配置会放里面
      - /work:/work
      - ./tmp:/tmp
      - ./pkgs:/opt/anaconda3/pkgs  # 这个目录是用conda安装软件时的临时目录,如果不做映射很快会出现pkgs目录已满的问题
      - ./root/.ssh:/root/.ssh   # 这个是为了一次通过ssh-keygen生成密钥后，能多次使用
      - ./root/.vim:/root/.vim   # 为了不同的container能重复利用一套已经下载的vim插件
      - ./jupyter:/jupyter       # 关键目录之1，jupyter的主运行目录
      - ./rserver:/home/rserver  # 关键目录之2，rtudio的工作目录
```

### 2. 使用docker run命令
和docker-compose差不多的意义
```
docker run --name jupyterlab_rstudio  \
-v /mnt/bioinfo:/mnt/bioinfo \
-v /mnt/github:/mnt/github \
-v /home/root/.ssh:/root/.ssh \
-v /home/root/.vim:/root/.vim \
-v /work:/work \
-v ./tmp:/tmp \
-v ./jupyter:/jupyter \
-v ./rserver:/home/rserver \
-p 28787:8787 \
-p 28888:8888 \
-e PASSWD=password \
-d leoatchina/jupyterlab_rstudio    #使用此镜像， -d代表在后台工作
```

### 运行后如何使用
- 通过`IP:[28888|28787]`进行访问
- 密码是`password`,在启动时通过调整参数可以修改
- 进入`rstudio-server`的用户名是`rserver`

## 网页端的shell
本docker中集成的`jupyter lab`的功能不用太多介绍，我要介绍的是集成的bash环境，通过`file->new->terminal`输入`bash`,就会打开一个有高亮的 shell环境

有两个好处
1. 只要你记得你的访问密码PASSWORD（仔细看我的启动脚本)，IP、端口，就可以通过网页端进行操作。
2. 启动`perl`，`python`,`shell`的分析流程后，**可以直接关闭网页**，不需要用`nohup`启动，下次重新打开该页面还是在继续运行你的脚本 。这个，请各位写个分析流程，自行体会下，也是我认为本次教程的最大亮点。

### `.jupyterc`我玩的小花招
众所周知，bash在启动时，会加载用户目录下的`.bashrc`进行一些系统变量的设置，同时又可以通过`source`命令加载指定的配置，在我的做出来的`jupyter`镜像中，为了达到`安装的生信软件`和`container分离`的目的，在删除container时不删除安装的软件的目的，我设置root目录下的`.bashrc`会 `source /juoyter/.jupyterc`(自己建立).
我的`.jupyterc`里就一句话`export PATH=$PATH:/jupyter/bioinfo/bin`,那么用`conda`安装到`/jupyter/bioinfo/`目录下的软件,就会把`可执行文件`放到`bin`子目录下.

### conda install -p 安装生信软件()
各位在学习其他conda教程时，经常会学到`conda create -n XXX`新建一个运行环境以满足特定安装需求，还可以通过`source activate`激活这个环境。
但其实还有一个参数`-p`用于指定安装目录，利用了这一点，我们就可以把自己`docker`里`conda`安装软件到`非conda内部目录`，而是`映射过来的目录`。
举例如下，安装`conda install -p /jupyter/envs/bioinfo trimmomatc`
如此，就安装到对应的位置，如samtools,bcftools,varscan等一众生信软件都可以如此安装。
在安装这些软件相应`container`被删除后，这些通过`-p`安装上的软件不会随着删除，下次重做`container`只要目录映射一致，**不需要重装软件，不需要重装软件，不需要重装软件**。

好处
1. 启动分析流程后，发现代码写错了要强行结束时，只要删除`container`，不需要一个个去kill进程
2. 在另一个机器上快速搭建分析环境，把`docker-file`在新机器上`bulid`下，各个`.xxxrc`文件放到正确的位置，然后把已经装上的软件复制过去就能搭建好分析环境。
3. 本repo里有一个`bioinfo.sh`文件,里面是用`conda`命令安装主流的生信分析软件,当然`gatk`和`annovar`是没有的,要自己下载解压
4. 可以在`shell`环境里`ln -s gatk /jupyter/bionfo/bin/gatk`软链接的方法把gatk也加入到系统环境中
