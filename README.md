# Rstudio-server and AnacondaLab in a docker
## 说明
leoatchina的jupyter dockerfile，集成了rstudio-server和anacondalab和shinyR
## 启动后可能要的配置 
### 在.bashrc,或者.zshrc里要加的内容
```
export TERM=xterm-256color # 否则在zsh终端环境下，backspace会变成space
```
### in rstudio console
```
Sys.setenv(TERM="xterm-256color")
options(encoding = "UTF-8")
```

在/home/rserver下建立`~/shiny-server`文件夹，把`/usr/local/lib/R/site-library/shiny/examples/`下的东西考过去,并重启container


### git
```
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative" 
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.br branch
```
