# djtools
### Introduction

This is a **tab-completable** toolsets  contain some useful scripts for installing software, checking daily work, checking status on repos, building projects, dealing with mirrors, simplifying Yocto BitBake commands, and so on.

Supported system: Ubuntu 16.04/18.04/20.04. Note that Ubuntu 16.04 is not fully tested, and Ubuntu 20.04 is under test.

### Installation

The installation script will install some necessary software, and will make the bash scripts in this repo valid by putting **BitBucket/GitHub/GiTee usernames** into **~/.bashrc**, which, will source the **djtools.bash** every time when opening a new terminal.

```bash
cd /path/to/djtools
./install
```

The output is as the following:

```bash
/home/robot/workspace/djtools

djtools installation ...
 
Do you have a BitBucket username? [Yes/No]
y

Please enter your BitBucket username
sky-Hawk

Do you have a GitHub username? [Yes/No]
y

Please enter your GitHub username:
dj-zhou

Do you have a GiTee username? [Yes/No]
y

Please enter your GiTee username:
dj-zhou
 
If bitbucket/github/gitee usernames set wrong, you can still edit them in ~/.bashrc
 
djtools installation finished.
```

After the installation, you will get those (similar) lines in `~/.bashrc`:

```bash
# ===========================================================
# djtools setup
bitbucket_username=sky-Hawk
github_username=dj-zhou
gitee_username=dj-zhou
source /home/robot/workspace/djtools/djtools.bash
```

Meanwhile, there are three files generated in `~` directory:

```text
.BitBucket-repos-sky-Hawk
.GiTee-repos-d-zhou
.GitHub-repos-dj-zhou
```

You can put the names of repositories into theses files to enable the **tab completable** feature of  `dj clone` and `dj ssh-clone` commands.

### `dj` Commands

#### `dj clone`

Used to clone the repositories from **BitBucket/GitHub/GiTee**. A specific branch can be cloned.

The tab-completion feature requires to add the repository names into a hard-coded file. For example, you can create a file `.GitHub-repos-<github username>` in home directory, then the command:

```bash
dj clone github <tab> <tab>
```

will list the repository names for selection. Take my GitHub account for example, I have tab-completion after `github` as:

```bash
$ dj clone github 
algorithm-note       dj-lib-cpp           one-third-demo       stl-practise
avr-gcc              djtools              one-third-stm32      stm32-embedded-demo
can-analyzer         embedded-debug-gui   opencv-4.1.1         stm32-lib
cpp-practise         glfw3                pads-clear-up        stm32tools
cv                   math-for-ml-note     pangolin             tutorials
dj-gadgets           matplotlib-cpp       robotics-note        yaml-cpp
```

since I have those listed in the `~/.GitHub-repos-dj-zhou`.

The same rules applied to GiTee and BitBucket.

#### `dj ssh-clone`

A similar command to `dj clone`, with the difference that the repository is with ssh links. For example, the command

```bash
dj ssh-clone github robotics-note
```

is the same as

```bash
git clone git@github.com:dj-zhou/robotics-note.git
```

#### `dj setup`

Used to install software, including `gcc-arm-stm32,` etc. The list will be extended without notification. By table completion, you can see the full installation list:

```bash
$ dj setup 
adobe-pdf-reader         gnome                    pangolin
arduino-1.8.13           google-repo              pip
baidu-netdisk            grpc-1.29.1              qemu
clang-format             gtest-glog               qt-5.13.1
clang-llvm               i219-v                   qt-5.14.2
cmake                    kdiff3-meld              ros2-foxy
computer                 lcm                      ros-melodic
container                libev-4.33               ros-noetic
devtools                 libgpiod                 saleae-logic
dj-gadgets               libiio                   slack
dropbox                  lib-serialport           spdlog
eigen3                   libyaml-cpp              stm32-cubeMX
foxit-pdf-reader         mathpix                  stm32-tools
g++-10                   matplot++                sublime
gcc-aarch64-linux-gnu    mbed                     typora
gcc-arm-linux-gnueabi    mongodb                  vim-env
gcc-arm-linux-gnueabihf  nvidia                   vscode
gcc-arm-stm32            nvtop                    vtk-8.2.0
gitg-gitk                opencv-2.4.13            wubi
git-lfs                  opencv-4.1.1             you-complete-me
glfw3                    opencv-4.2.0             
```

#### `dj ssh`

SSH related commands.

```bash
dj ssh nopassword user@ip
```

This command is used to copy the ssh key to a remote computer such that you will no need to enter password every time when ssh to it.

#### `dj udev`

Used to setup some udev for USB to serial ports, and  video capture card, FT4232H, etc.

```bash
~ $ dj udev 
--dialout          logitech-f710      --show             uvc-video-capture
ft4232h            one-third-console  stlink-v2.1  
```

#### `dj work-check`

Used to check if the repositories have been pushed, for example, the following code 

```bash
dj work-check .
```

will check all the folders (possibly repositories) in the current folder (`.`), and tell if the repo is <span style="color:red">dirty</span>,  <span style="color:cyan">ahead</span> or <span style="color:blue">ahead</span>. Meanwhile, it will write those information: commit time, source (github/bitbucket/gitee, etc), status (dirty/ahead/behind), branch name, the tag, commit value, commit message, to a text file in the home directory. For example: `work-check-dj-dell-20200709-121415.txt`.

It is recommended to run this command to see if there is some work have not been finished, committed or pushed.

#### `dj meson`

`dj meson find` is used to find some contents in the `meson.build` files in a project. It is very useful if the project has multiple `meson.build` files.

#### `dj replace`

Used to replace the text content of `\<original\>` to `\<new\>` in a file or a folder. Usage:

```bash
dj replace <original> <new> <path to file or folder>
```

It is useful to replace the name of a global variable in a folder.

#### `dj formrat`

Used to implement a `.clang-format` file to the current path. For example:

```bash
coding clang-format implement djz
```

will copy the file `.clang-format-dj` from the `djtools` folder to the current folder, and rename it to `.clang-format`.

It can also be used to show the naming convention in programming:

```bash
coding clang-format show
```

### `repod` Commands

#### `repod branches`

Branched related commands. For example, to list all local or remote branches:

```bash
repod branches list-all --local
repod branches list-all --remote
```

#### `repod checkout`

Used to checkout all branches:

```bash
repod checkout all-branch
```

Todo: when a branch checked out out is older, pull it; when the upstream of a branch checked out is gone, delete it.

#### `repod update`

This command works in a folder that contains multiple repos. It is similar to `dj work-check` command, but gives more information. For example, in `~/workspace`, I run `repod update --all-sub-folders`, the output is (with color):

```text
----------------------------
djtools dirty 

----------------------------
one-third-demo 

----------------------------
one-third-stm32 

----------------------------
tutorials dirty 
```

### `system` Commands

#### `system check`

Used to check some system information. For example, temperature, udev rules, cpu-memory, and so on.

#### `system enable`

Used to enable something, not implemented yet.

#### `system disable`

Used to disable something, for example:

```bash
system disable program-problem-detected
```

#### `system wallpaper`

Used to setup the wallpaper:

```bash
system wallpaper random
```

This command will leave settings in the `~/.bashrc` file.

### `yocto` Commands

#### `yocto bake`

To bitbake an image defined in some meta layer. The command is valid only in a Yocto Build directory. Take [yocto-up-board](https://github.com/dj-zhou/yocto-up-board) as an example:

```bash
cd yocto-up-board/up-board
mamba@asus-rog: up-board $ yocto bake <tab tab>
meta-intel           meta-up-board        openembedded-core    
meta-openembedded    meta-virtualization  poky                 
mamba@asus-rog: up-board $ yocto bake meta-up-board upboard- <tab tab>
upboard-image-base        upboard-image-secureboot  
upboard-image-sato        upboard-robotics-image    
```

#### `yocto build`

It is used tot build a plain SDK. If there are multiple images in the build directory, you will need to choose one image:

```bash
mamba@asus-rog: up-board $ yocto build plain-sdk upboard-
upboard-image-base      upboard-robotics-image  
```

#### `yocto flash`

Used to flash the image to the SD card. For ARM based Yocto images, it will flash the `wic` iamge file to a SD card:

```bash
yocto flash /dev/sda appolo-image
```

The output is:

```bash
todo
```

For x86 based Yocto images: TODO.

#### `yocto list`

It is used to list distributions, images, machines defined in the meta layers.

```bash
mamba@asus-rog: up-board $ yocto list 
distros    images     machines   resources 
```

#### `yocto setup`

It is used to setup the development environment, or the plain-sdk.

#### `yocto show`

It is used to  list a specific distro, image, machine, or recipe. For example:

```bash
mamba@asus-rog: yocto-up-board $ yocto show recipe-bb eigen

---------------------------------------
meta-openembedded
./meta-oe/recipes-support/libeigen/libeigen_3.3.7.bb
```

hence we know the `libeigen` upstream is defined in `meta-openembedded` layer.

### `zephyr` Commands

#### `zephyr setup`

Used to setup the Zephyr SDK. For example, for SDK version 0.11.3, you can run:

```bash
zephyr setup sdk-0.11.3
```

#### `zephyr build`

Used to build the image/binary of the Zephyr application. It should be run in the application folder, for example, `~/workspace/zephyr-app-demo`. It is currently use `ninja` to build the image, because I don't know how to invoke the `west` command in a folder other than the zephyr workspace, i.e., `~/zephyr-project/`, in most cases.

#### `zephyr flash`

For STM32 microcontrollers, it is used to flash the binary to the chip using the **ST-Link v2** device. The driver of the **ST-Link v2** device should be installed by command `dj setup stm32tools`. Example command is:

```bash
zephyr flash stm32
```

For other platform, the tools and so on are not setup yet.

### Other Commands

#### `window-tile`

Used to tile the windows to a pre-setup configuration.

#### `keyremap`

Used to remap the **alt** and the **ctrl** keys.

#### `touchpad`

Used to enable or disable the touchpad on some (brands of) computers.