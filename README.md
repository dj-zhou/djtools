## djtools
### Introduction

This is a **tab-completable** toolsets  contain some useful scripts for installing packages, checking daily work, checking status on repos, building projects, dealing with mirrors, simplifying Yocto BitBake commands, and so on.

Supported system: Ubuntu 18.04/20.04. Note that Ubuntu 18.04 is not fully tested, and Ubuntu 20.04 is under test.

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
d-zhou
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

You can put the names of repositories into theses files to enable the **tab completable** feature of  `dj git ssh-clone` commands.

### `dj` Commands

#### `dj flame-graph`

A tool used to generate flame graph, assisting `perf` tools.

#### `dj format`

* `brush`: apply clang format according to `file` (`.clang-format` file) or `google` (Google style)
* `implement`: to implement a `.clang-format` file to the current path. For example, `dj format implement djz` will copy the file `.clang-format-dj` from the `djtools` folder to the current folder, and rename it to `.clang-format`.
* `show`: to show different coding style, for example, `camel` (to add more).

#### `dj git`

* `config`: to configure a repository with name and email address, locally.
* `search`: to list all remote branches by using the author's name, or email address, or to search some commit that with specific string in the commit message.
* `ssh-clone`: to clone repository using ssh, for example, the command `dj git ssh-clone github robotics-note` is the same as `git clone git@github.com:dj-zhou/robotics-note.git`, because we have setup the GitHub account as `dj-zhou`.

#### `dj grep`

* `in-meson`: to find specific content in all `meson.build` files in current directory.
* `package`: run `ldconfig` command to see the package relationships.
* `string`: to search some string in all files in current directory, avoid those directories: `build`, `bin`, `_bcross*`, `_bnative*`, `builddir`, `.git`, `.cache`.

#### `dj help`

Show some help information for some specific commands.

#### `dj open`

#### `dj pack`

(TODO): to pack files using `tar.gz`, or other formats.

`dj python3`

* `install`: to install python3 related packages natively.

#### `dj replace`

Used to replace the text content of `\<original\>` to `\<new\>` in a file or a folder. Usage:

```bash
dj replace <original> <new> <path to file or folder>
```

It is useful to replace the name of a global variable in a folder.

#### `dj setup`

Used to install packages, including `gcc-arm-stm32,` etc. The list will be extended without notification. By table completion, you can see the full installation list:

```bash
$ dj setup 
abseil-cpp               glfw3                    pangolin
adobe-pdf-reader         glog                     perf
anaconda                 gnome                    picocom
ansible                  gnuplot                  pip
arduino-1.8.13           google-repo              plotjuggler
baidu-netdisk            grpc                     pycharm
boost                    gtest                    python3.9
clang-format             i219-v                   qemu
clang-llvm               kdiff3-meld              qt-5.13.1
cli11                    lcm                      qt-5.14.2
cmake                    libcsv-3.0.2             ros2-foxy
computer                 libev                    ros-melodic
container                libgpiod                 ros-noetic
devtools                 libiio                   rust
driver                   lib-serialport           saleae-logic
dropbox                  libsystemd               slack
eigen3                   magic-enum               spdlog
flamegraph               mathpix                  stm32-cubeMX
fmt                      matplot++                stm32-tools
foxit-pdf-reader         mbed                     sublime
g++-10                   meson                    texlive
g++-11                   mongodb                  typora
gadgets                  nlohmann-json3-dev       vim-env
gcc-aarch64-linux-gnu    nvidia                   vscode
gcc-arm-linux-gnueabi    nvtop                    vtk-8.2.0
gcc-arm-linux-gnueabihf  opencv-2.4.13            windows-fonts
gcc-arm-stm32            opencv-3.4.13            wubi
gitg-gitk                opencv-4.1.1             yaml-cpp
git-lfs                  opencv-4.2.0             you-complete-me        
```

The versions of most of the packages are listed in file `path/to/djtools/.package-version`.

#### `dj ssh-general`

* `no-password`: to copy the host ssh file to a target to avoid using password in the future.

#### `dj ssh-github`

GitHub related commands:

* `activate`: to activate one account;
* `all-accounts`: to show all available accounts;
* `current-account`: to show current active account.

#### `dj udev`

Used to setup some udev for USB to serial ports, and  video capture card, FT4232H, etc.

```bash
~ $ dj udev 
--dialout          logitech-f710      --show             uvc-video-capture
ft4232h            one-third-console  stlink-v2.1  
```

#### `dj udevadm`

To run `udevadm` command to show detail of some USB device, that is the same as running this command:

```bash
udevadm info -a -n [usb device]
```

#### `dj work-check`

Used to check if the repositories have been pushed, for example, the following command 

```bash
dj work-check .
```

will check all the folders (possibly repositories) in the current folder (`.`), and tell if the repo is <span style="color:red">dirty</span>,  <span style="color:blue">ahead</span> or <span style="color:cyan">behind</span>, or <span style="color:yellow">upstream-gone</span>, Meanwhile, it will write those information: commit time, source (github/bitbucket/gitee, etc), status (dirty/ahead/behind), branch name, the tag, commit value, commit message, to a text file in the home directory. For example: `work-check-dj-dell-20200709-121415.txt`.

It is recommended to run this command to see if there is some work have not been finished, committed or pushed.

### `system` Commands

* `check`:  used to check some system information. For example, temperature, udev rules, cpu-memory, and so on.
* `enable`: used to enable something, not implemented yet.
* `disable`: used to disable something, for example: `system disable program-problem-detected`.
* `wallpaper`: used to setup the wallpaper: `system wallpaper random`, this command will leave settings in the `~/.bashrc` file.

### `yocto` Commands

#### `yocto bake`

To bitbake an image defined in some meta layer. The command is valid only in a Yocto Build directory. Take [yocto-image-builder](https://github.com/dj-zhou/yocto-image-builder) as an example:

```bash
~$ cd yocto-image-builder/wandboard-imx6qp-revd1
viper@x299: wandboard-imx6qp-revd1 $ yocto bake 
image      plain-sdk  
viper@x299: wandboard-imx6qp-revd1 $ yocto bake image 
meta-freescale           meta-freescale-distro    meta-zhou
meta-freescale-3rdparty  meta-openembedded        poky
viper@x299: wandboard-imx6qp-revd1 $ yocto bake image meta-zhou appolo-image   
```

You can also bitbake a plain-sdk once an image is built.

#### `yocto flash`

Used to flash the image to the SD card. For ARM based Yocto images, it will flash the `wic` image file to a SD card:

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
viper@x299: yocto-image-builder $ yocto show recipe-bb eigen

---------------------------------------
meta-openembedded
./meta-oe/recipes-support/libeigen/libeigen_3.4.0.bb

---------------------------------------
meta-zhou
./recipes-support/libeigen/libeigen_3.3.7.bb
```

hence we know the `libeigen` upstream is defined in `meta-openembedded` and `meta-zhou` layer.

### `zephyr` Commands

#### `zephyr setup`

Used to setup the Zephyr SDK. For example, for SDK version 0.11.4, you can run:

```bash
zephyr setup sdk-0.11.4
```

#### `zephyr build`

Used to build the image/binary of the Zephyr application. It should be run in the application folder, for example, `~/workspace/zephyr-app-demo`. It is currently use `ninja` to build the image, because I don't know how to invoke the `west` command in a folder other than the zephyr workspace, i.e., `~/zephyr-project/`, in most cases.

#### `zephyr flash`

For STM32 microcontrollers, it is used to flash the binary to the chip using the **ST-Link v2** device. The driver of the **ST-Link v2** device should be installed by command `dj setup stm32tools`. Example command is:

```bash
zephyr flash stm32
```

For other platform, the tools and so on are not setup yet.
