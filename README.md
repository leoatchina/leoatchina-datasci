## 用集成了anaconda的docker快速布置生信分析平台
#### 前言
众所周知，`conda`和`docker`是进行快速软件安装、平台布置的两大神器，通过它们，在终端前敲几个命令、点点鼠标，软件就装好了。出了问题也不会影响到系统配置，能够很轻松的还原和重建。
不过，虽说类似`rstudio`或者`jupyter notebook/lab`这样的分析平台能够很快地找到别人已经做好的镜像，但是总归有功能缺失，而且有时要让不同的镜像协同工作时，目录的映射，权限的设置会让经验的人犯晕。
本着**不折腾不舒服**的本人一惯风格，我自己写了一个dockerfile，集成了`rstudio server`、`jupyter lab`、`shiny server`，可用于生信分析平台的快速布置，通过一些技巧，也可供linux初学者练习用

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
      - /data/bioinfo:/mnt/bioinfo   # 个人习惯，里面会放一些参考基因组等  
      - /home/github:/mnt/github     # 习惯2，比如我的vim配置会放里面
      - /tmp:/tmp 
      - /data/disks:/disks           
      - /data/work:/work
      - /home/root/.ssh:/root/.ssh   # 这个是为了一次通过ssh-keygen生成密钥后，能多次使用
      - /home/root/.vim:/root/.vim   # 为了使用我配置的vim
      - /root/.vimrc.local:/root/.vimrc.local  # 同上
      - /home/jupyter:/jupyter       # 关键目录之1，jupyter的主运行目录 
      - /home/rserver:/home/rserver  # 关键目录之2，rtudio的工作目录 
```
会运行一个名为`bioinfo_jupyter_1`的`container`，是由目录`bioinfo`+镜像`jupyter`+数字`1`组成 


##### 使用docker run命令
和使用docker-compose差不多的意义
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
1. 打开  `运行机器的IP:28787`，修改下R的源，bioClite源
2. 可能要运行下 `R CMD javareconf`
3. shinny的运行目录是在 `/home/rsever/shinny-server`
4. 进入`rstudio-server`的用户名是`rserver`


#### `.bashrc`和`.zshrc`,我玩的小花招
众所周知，bash/zsh在启动时，会加载用户目录下的`.bashrc/.zshrc`进行一些系统变量的设置，同时又可以通过`source`命令加载指定的配置，在我的做出来的`jupyter`镜像中，为了达到`安装的软件和container分离`，在删除container时不删除安装的软件的目的，我做了如下source次序
- root目录下的`.bashrc`或者`.zshrc`(在镜像里已经写入) ： `source /juoyter/.jupyterc`
- 在映射过去的 `/jupyter/.jupyterc中`（另外自行建立）:  `source /jupyter/.bioinforc`
- 贴出我的 `.jupyterc`和`.bioinforc`

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

- 你们可以看到，`/opt/anaconda3/bin`在$PATH变量中优先级最高，而安装在`/jupyter/envs/bioinfo/bin`，`/jupyter/envs/entrez-direct/bin`等目录下的可执行文件不需要输入全路径也运行，这是搞哪一出？


#### conda install -p 快速安装软件
各位在学习其他conda教程时，经常会学到`conda create -n XXX`新建一个运行环境以满足特定安装需求，还可以通过`source activate`激活这个环境，但其实还有一个参数`-p`用于指定安装目录。
利用了这一点，我们就可以把自己`docker`里`conda`安装软件到`非conda内部目录`，而是`实际的硬盘`上。
举例如下安装`conda install -p /jupyter/envs/bioinfo trimmomatc`
![install trim](http://oxa21co60.bkt.clouddn.com/99acb90192939d988774b08cd910aaf7.png)
如此，就安装到对应的位置，如samtools,bcftools,varscan等一众生信软件都可以如此安装。
![](http://oxa21co60.bkt.clouddn.com/67697b228ccd03b2d790ffa431f42f56.png)

关键的，在安装这些软件相应`container`被删除后，这些通过`-p`安装上的软件不会随着删除，下次重做`container`只要目录映射一致，**不需要重装，不需要重装，不需要重装**。

有用的时刻？
1. 启动分析流程后，发现代码写错了要强行结束时，只要删除`container`，不需要一个个去kill进程
2. 在另一个机器上快速搭建分析环境，把`docker-file`在新机器上`bulid`下，各个`.xxxrc`文件放到正确的位置，然后把已经装上的软件复制过去就能搭建好分析环境。


#### 网页端的shell
本docker中集成的jupyter lab的功能不用太多介绍，我要介绍的是集成的zsh环境，通过`file->new->terminal`输入`zsh`,就会打开一个有高亮的 shell环境
![](http://oxa21co60.bkt.clouddn.com/8a01aa9e432b7aec038509dea20617ec.png)

![](http://oxa21co60.bkt.clouddn.com/a5bcb9e27ae5bc575a42bdd6fc00d3d6.png)

有两个好处
1. 只要你记得你的访问密码PASSWORD（仔细看我的启动脚本)，IP、端口，就可以通过网页端进行操作。
2. 启动`perl`，`python`,`shell`的分析流程后，**可以直接关闭网页**，不需要用`nohup`启动，下次重新打开该页面还是在继续运行你的脚本 。这个，请各位写个分析流程，自行体会下。
