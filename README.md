# djtools
### Introduction

This repo contains some useful scripts for installing software, check daily work, check status on repos, and so on.

Supported system: Ubuntu 16.04/18.04/20.04. Note that Ubuntu 16.04 is not fully tested, and Ubuntu 20.04 is under test.

The commands in this repo are **tab-completable**. 

### Installation

The installation script will install some necessary software, and will make the bash scripts in this repo valid by putting **bitbucket/github/gitee usernames** into **~/.bashrc**, which, will source the **djtools.bash** every time open a new terminal.

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
BitBucket_username=sky-Hawk
GitHub_username=dj-zhou
GiTee_username=dj-zhou
source /home/robot/workspace/djtools/djtools.bash
```

### `dj` Commands

#### `dj clone`

Used to clone the repositories from **BitBucket/GitHub/GiTee**. A specific branch can be cloned.

The tab-completion feature requires to add the repository names into a hard-coded file. For example, you can create a file `.github-repos-<github username>` in home directory, then the command:

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

since I have those listed in the `~/.github-repos-dj-zhou`. If the file is not found, it will use the repository listed in `settings/github-repos` instead.

The same rules applied to GiTee and BitBucket.

#### `dj clone-ssh`

A similar command to `dj clone`, with the difference that the repository is with ssh links. For example,

```bash
dj clone-ssh github robotics-note
```

is the same as

```bash
git clone git@github.com:dj-zhou/robotics-note.git
```

#### `dj setup`

Used to install software, including arm-gcc, clang-9.0.0, eigen, foxit, gitg, kdiff3, glfw3, opencv, pangolin, pip, Qt, stm32tools, typora, vscode, vtk, yaml-cpp. The list will be extended without notification. By table completion, you can see the full installation list.

```bash
$ dj setup 
arm-gcc           gitg-kdiff3       pangolin          sublime
baidu-netdisk     glfw3-gtest-glog  pip               typora
clang-9.0.0       grpc-1.29.1       qt-5.11.2         vscode
computer          i219-v            qt-5.13.1         vtk-8.2.0
container         libev-4.33        qt-5.14.2         wubi
dj-gadgets        mathpix           ros2-foxy         yaml-cpp
dropbox           matplotlib-cpp    ros-melodic       
eigen             opencv-2.4.13     slack             
foxit             opencv-4.1.1      stm32tools 
```

#### `dj ssh`

SSH related commands.

```bash
dj ssh nopassword user@ip
```

This command is used to copy the ssh key to a remote computer such that you will no need to enter password every time when ssh to it.

#### `dj udev`

Used to setup some udev for USB to serial ports, and  video capture card.

<span style="color:blue">This part will be revised to be none-project specific.</span>

#### `dj work-check`

Used to check if the repositories have been pushed, for example, the following code 

```bash
dj work-check .
```

will check all the folders (possibly repositories) in the current folder (`.`), and tell if the repo is <span style="color:red">dirty</span>,  <span style="color:cyan">ahead</span> or <span style="color:blue">ahead</span>. Meanwhile, it will write those information: commit time, source (github/bitbucket/gitee, etc), status (dirty/ahead/behind), branch name, the tag, commit value, commit message, to a text file in the home directory. For example: `work-check-dj-dell-20200709-121415.txt`.

It is recommended to run this command to see if there is some work have not been finished, committed or pushed.

#### `dj meson`

It is a simplified version of meson configuration and build. It has some logic:

* If the current path is in a `build` folder, it will `cd ..` and `rm build` and `meson build` and then `ninja -C build`.
* If the current path contains a `build` folder, it will `rm build` and `meson build` and then `ninja -C build`.
* Otherwise, if there is a `meson.build` file, it will  `meson build` and then `ninja -C build`.

### `coding` Commands

The `coding` commands are used to work with `clang-format` and replacing some content in a folder, or a specific file.

replace strings in a file or the files in a folder; and for coping the `.clang-format` to current folder `./`.

#### `coding replace`

Used to replace the text content of \<original\> to \<new\> in a file or a folder. Usage:

```bash
coding replace <original> <new> <path to file or folder>
```

It is useful to replace the name of a global variable in a folder. <span style="color:blue">Note: global variables are not recommended in programming.</span>

#### `coding clang-format`

Used to implement a `.clang-format` file to the current path. For example:

```bash
coding clang-format implement dj
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

#### `yocto clone`

To clone Yocto related meta data or repos.

#### `yocto flash`

Used to flash the image to the SD card.

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

#### `resized`

Used to resize the windows to a pre-setup.

#### `keyremap`

Used to remap the **alt** and the **ctrl** keys.

#### `touchpad`

Used to enable or disable the touchpad on some (brands of) computers.