# djtools
### Introduction

This repo contains some useful scripts for installing software, check daily work, and so on.

Supported system: Ubuntu 16.04/18.04

The commands in this repo are tab-completable. 

```bash
float-to-u8 1.234
```

### Installation

The installation script will install some necessary software, and then make the bash scripts in this repo valid by putting bitbucket/github/gitee usernames into *.bashrc*, and also sourcing the *djtools.bash* file.

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

After the installation, you will get those lines in `~/.bashrc`:

```bash
# ===========================================================
# djtools setup
bitbucket_username=sky-Hawk
github_username=dj-zhou
gitee_username=dj-zhou
source /home/robot/workspace/djtools/djtools.bash
```

### `dj` Commands

#### `dj clone github <repo name>`

Used to clone the repositories from bitbucket/github/gitee

#### `dj setup <software package>`

Used to install software, including arm-gcc, clang-9.0.0, eigen, foxit, gitg, kdiff3, glfw3, opencv, pangolin, pip, Qt, stm32tools, typora, vscode, vtk, yaml-cpp. The list will be extended without notification.

#### `dj udev <rule name>`

Used to setup some udev for USB to serial ports, and  video capture card.

#### `dj work-check <folder path>`

Use to check if the repositories have been pushed, for example, ,the following code 

```bash
dj work-check .
```

will check the current folder status, it tells the repos: commit time, source (github/bitbuckekt/gitee, etc), status (dirty/ahead/behind), branch name, the tag, commit value, commit message.

It is recommended to run this command to see if there is some work have not been finished.

### `coding` Commands

The `coding` commands are used to replace strings in a file or the files in a folder; and for coping the `.clang-format` to current folder `./`.

#### `coding replace <original> <new> <path to file or folder>`

Used to replace the text content of \<original\> to \<new\> in a file or a folder.

#### `coding clang-format <type>`

Used to copy a `.clang-format` file to the current path. For example:

```bash
coding clang-format dj
```

will copy the file `.clang-format-dj` from the `djtool` folder to the current folder, and rename it to `.clang-format`.

### `repod` Commands

TODO

### `system` Commands

TODO

### `yocto` Commands

TODO

### `zephyr` Commands

#### `zephyr setup sdk-0.11.3`

Used to setup the Zephyr SDK, version 0.11.3.

#### `zephyr build`

Used to build the image/binary of the Zephyr application. It should be run in the application folder, for example, `~/workspace/zephyr-app-demo`. It is currently use `ninja` to build the image, because I don't know how to invoke the `west` command in a folder other than the zephyr workspace, i.e., `~/zephyr-project/`, in most cases.

### `zephyr flash <platform>`

For STM32 microcontrollers, it is used to flash the binary to the chip using the ST-Link v2 device. The driver of the ST-Link v2 device should be installed by command `dj setup stm32tools`. Example command is:

```bash
zephyr flash stm32
```

### Other Commands

#### `resized`

Used to resize the windows to a pre-setup.

#### `keyremap`

Used to remap the **alt** and the **ctrl** keys.

`touchpad`

Used to enable or disable the touchpad on the computer.