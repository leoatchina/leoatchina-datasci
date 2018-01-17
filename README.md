## 用集成了anaconda的docker快速布置生信分析平台
#### 前言
众所周知，`conda`和`docker`是进行快速软件安装、平台布置的两大神器，通过它们，在终端前敲几个命令、点点鼠标，软件就装好。出了问题也不会影响到系统配置，能够很轻松的还原和重建。
不过，虽说类似`rstudio`或者`jupyter notebook/lab`这样的分析平台能够很快地找到别人已经做好的镜像，但是总归有功能缺失，而且有时要让不同的镜像协同工作时，目录的映射，权限的设置会让经验的人犯晕。
本着“不折腾不舒服”的本人一惯风格，我自己写了一个dockerfile，集成了`rstudio server`、`jupyter lab`、`shiny server`，可用于生信分析平台的快速布置，通过一些技巧，也可供linux初学者练习用

#### 我的dockerfile地址
[https://github.com/leoatchina/dockerfile_jupyter](https://github.com/leoatchina/dockerfile_jupyter),觉得好给个**star**吧!

#### 安装,要先装好`docker-ce`和`git`
```
git clone https://github.com/leoatchina/dockerfile_jupyter.git
cd docker_jupyter
docker build -t jupyter . 
```
*说明,这个镜像的名字是`jupyter`，你们可以改成其他自己喜欢的任何名字*

#### 我在这个dockerfile里主要做的工作
- 基于ubuntu16.04
- 安装了一堆编译、编辑、下载、搜索等用到的工具和库
- 安装了最新版`anaconda`,`Rstudo`,`Shinny`
- 安装了部分`bioconductor`工具
- 用`supervisor`启动后台web服务
- 集成`zsh`以及`oh-my-zsh`,`vim8`,`git`


#### 主要控制点
- 开放端口：
  - 8888: for jupyter lab
  - 7777: for jupyter notebook
  - 8787: for rstudio server
  - 3838: for shiny
- 访问密码：
  - 见dockerfile里的`ENV PASSWD=jupyter`
  - 运行时可以修改
- jupyter的主目录： `/jupyter`
- rstudio的主目录： `/home/rserver`
- shinny的主目录： `/home/rserver/shiny-server`
- VOLUME ["/home/rserver","/jupyter","/mnt","/disks","/oss","/data"]



#### 运行
##### 使用docker-compose
- docker-compose -f /home/docker/compose/bioinfo/docker-compose.yml up -d
- `docker-compose.yml`的内容，详细内容如下
```
version: "3"  # vml版本
services:
  jupyter:  
    image: jupyter  # 使用前面做出来的jupyter镜像
    environment:
      - PASSWD=mitipass   # PASSWD ， 在Docker-file里的 `ENV PASSWD=jupyter`
    ports:     # 端口映射，右边是container里的商品，左边是实际商品
      - 28787:8787
      - 27777:7777
      - 28888:8888
      - 23838:3838
    volumes:   # 位置映射，右docker，左实际
      - /data/bioinfo:/mnt/bioinfo   # 个人习惯   
      - /home/github:/mnt/github     # 习惯2
      - /tmp:/tmp 
      - /data/disks:/disks           
      - /data/work:/work
      - /home/root/.ssh:/root/.ssh   # 这个是为了一次通过ssh-keygen生成密钥后，能多次使用
      - /home/root/.vim:/root/.vim   # 为了使用我配置的vim
      - /root/.vimrc.local:/root/.vimrc.local  # 同上
      - /home/jupyter:/jupyter       # 关键目录之1，jupyter的主运行目录 
      - /home/rserver:/home/rserver  # 关键目录之2，rtudio的工作目录 
```
- 这样会运行出来一个叫`bioinfo_jupyter_1`的`container`，是由目录`bioinfo`+镜像`jupyter`+数字`1`组成 


##### 使用docker run命令
- 和使用docker-compose差不多的意义
```
docker run --name jupyter  \
-v /data/bioinfo:/mnt/bioinfo \ 
-v /home/github:/mnt/github \
-v /tmp:/tmp \
-v /data/disks:/disks \
-v /data/work:/work \
-v /home/root/.ssh:/root/.ssh \
-v /home/root/.vim:/root/.vim \
-v /home/jupyter:/jupyter \
-v /home/rserver:/home/rserver \
-p 27777:7777 \
-p 28787:8787 \
-p 28888:8888 \
-p 23838:3838 \
-e PASSWD=mitipass \    
-d jupyter    #使用jupyter镜像， -d代表在后台工作
```

##### 运行后的调整
打开  `运行机器IP:28787`，修改下R的源，bioClite源


#### `.bashrc`和`.zshrc`,我玩的小花招
众所周知，bash/zsh在启动时，会加载用户目录下的`.bashrc/.zshrc`进行一些系统变量的设置，同时又可以通过`source`命令加载指定的配置，在我的做出来的`jupyter`镜像中，为了达到`安装的软件和container分离`，在删除container时不删除安装的软件的目的，我做了如下source次序
- root目录下的`.bashrc`或者`.zshrc`(在镜像里已经写入) ： `source /juoyter/.jupyterc`
- 在映射过去的 `/jupyter/.jupyterc中`（另外自行建立）:  `source /jupyter/.bioinforc`
- 贴出 `.jupyterc`和`.bioinforc`

**/jupyter/.jupyterc**
``` 
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 
# PATH I write or complied
export PATH=/jupyter/usr/bin:$PATH
# bioinfo path
if [ -f /jupyter/.bioinforc ]; then
    source /jupyter/.bioinforc  # 重要
fi
# PATH for conda
export PATH=/opt/anaconda3/bin:$PATH   # /opt/anaconda3/是安装的anaconda目录，放最重要的位置上去
```

**/jupyter/.bioinforc**
```
# PATH for conda installed envs
export PATH=$PATH:/jupyter/envs/entrez-direct/bin
export PATH=$PATH:/jupyter/envs/bioinfo/bin

# ascp
export PATH=/jupyter/biotools/.aspera/connect/bin:$PATH
alias ascp_putty='ascp -i /jupyter/biotools/.aspera/connect/etc/asperaweb_id_dsa.putty --mode=recv -l 200m '
alias ascp_ssh='ascp -i /jupyter/biotools/.aspera/connect/etc/asperaweb_id_dsa.openssh --mode=recv -l 200m '
alias fd="fastq-dump --split-3 --defline-qual '+' --defline-seq '@\$ac-\$si/\$ri'"

# PATH for biotools
export PATH=/jupyter/biotools/vcftools/bin:$PATH
export PERL5LIB=$PERL5LIB:/jupyter/biotools/vcftools/share/perl/5.22.1

export PATH=/jupyter/biotools/sratoolkit.2.5.6-ubuntu64/bin:$PATH
export PATH=/jupyter/biotools/gdc-client/bin:$PATH
export PATH=/jupyter/biotools/RSEM-1.3.0:$PATH
export PATH=/jupyter/biotools/express-1.5.1-linux_x86_64:$PATH
```

- 这样，你们可以看到，`/opt/anaconda3/bin`在$PATH变量中优先级最高，而安装在`/jupyter/envs/bioinfo/bin`等目录下的可执行文件不需要输入全路径也运行，这是搞哪一出？



#### conda install -p 
可能各们前面注意到了，我
