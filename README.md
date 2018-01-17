## 用集成了anaconda的docker快速布置生信分析平台
#### 前言
众所周知，`conda`和`docker`是进行快速软件安装、平台布置的两大神器，通过它们，在终端前敲几个命令、点点鼠标，软件就装好。出了问题也不会影响到系统配置，能够很轻松的还原和重建。
不过，虽说类似`rstudio`或者`jupyter notebook/lab`这样的分析平台能够很快地找到别人已经做好的镜像，但是总归有功能缺失，而且有时要让不同的镜像协同工作时，目录的映射，权限的设置会让经验的人犯晕。
本着“不折腾不舒服”的本人一惯风格，我自己写了一个dockerfile，集成了`rstudio server`、`jupyter lab`、`shiny server`，可用于生信分析平台的快速布置，通过一些技巧，也可供linux初学者练习用

#### 我的dockerfile地址
[https://github.com/leoatchina/dockerfile_jupyter](https://github.com/leoatchina/dockerfile_jupyter),觉得好给个star

#### 安装,要先装好`docker-ce`和`git`
```
git clone https://github.com/leoatchina/dockerfile_jupyter.git
cd docker_jupyter
docker build -t jupyter .  # 说明,这个镜像的名字是jupyter，你们可以改成其他自己喜欢的任何名字

```

#### 我在这个dockerfile里主要做的工作
