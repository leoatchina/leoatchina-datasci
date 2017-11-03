# Rstudio-server and AnacondaLab in a docker
## 说明
leoatchina的jupyter dockerfile，集成了rstudio-server和anacondalab和shinyR
## 启动后可能要的配置 
### bashrc,或者zshrc里要加的内容
```
export PATH=/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TERM=xterm-256color
```
in rstudio console，set up rstudio config
```
Sys.setenv(PATH="/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")
Sys.setenv(TERM="xterm-256color")
options(encoding = "UTF-8")
```

在目标文件夹下建立`~/workspace/shiny-server`文件夹，把`/usr/local/lib/R/site-library/shiny/examples/`下的东西考过去,并重启container
