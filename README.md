# djtools
# Introduction

This repo contains some useful scripts for installing software, check daily work, and so on.

Supported system: Ubuntu 16.04/18.04

The commands in this repo are tab-completable. 

```bash
float-to-u8 1.234
```

## Installation

The installation script will install some necessary software, and then make the bash scripts in this repo valid by putting bitbucket/github/gitee usernames into *.bashrc*, and also sourcing the *djtools.bash* file.

```bash
cd /path/to/djtools
./install
```



## dj Commands

### clone

Used to clone the repos from bitbucket/github/gitee

### setup

Used to install software, including arm-gcc, clang-9.0.0, eigen, foxit, gitg, kdiff3, glfw3, opencv, pangolin, pip, Qt, stm32tools, typora, vscode, vtk, yaml-cpp. The list will extended without notification.

### udev

Used to setup some udev for USB to serial ports, and  video capture card.

### work-check

Use to check if the repos have been pushed, for example, ,the following code 

```bash
dj work-check .
```

will check the current folder status, it tells the repos: commit time, source (github/bitbuckekt/gitee, etc), status (dirty/ahead/behind), branch name, the tag, commit value, commit message.

It is recommended to run this command to see if there is some work have not been finished.

## Other Commands

### resized

used tot resize the windows to a pre-setup.

### keyremap

Used to remap the **alt** and the **ctrl** keys.