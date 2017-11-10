# Rstudio-server and AnacondaLab in a docker
## 说明
leoatchina的jupyter dockerfile，集成了rstudio-server和anacondalab和shinyR
## 启动后可能要的配置 
### bashrc,或者zshrc里要加的内容
```
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export PATH=/opt/anaconda3/bin:$PATH
export TERM=xterm-256color
```
in rstudio console，set up rstudio config
```
Sys.setenv(TERM="xterm-256color")
options(encoding = "UTF-8")
Sys.setenv(LC_ALL="en_US.UTF-8")
```

在目标文件夹下建立`~/workspace/shiny-server`文件夹，把`/usr/local/lib/R/site-library/shiny/examples/`下的东西考过去,并重启container
