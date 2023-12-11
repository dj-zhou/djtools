#!/bin/bash

# =============================================================================
function _setup_opencv_dependencies() {
    # Generic tools
    packages="build-essential cmake pkg-config unzip yasm git checkinstall "
    # Image I/O libs
    packages+="libjpeg-dev libpng-dev libpng-dev libtiff-dev libtiff5-dev "
    # Video/Audio Libs — FFMPEG, GSTREAMER, x264 and so on
    packages+="libavcodec-dev libavformat-dev libswscale-dev libavresample-dev "
    packages+="libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev "
    packages+="libxvidcore-dev x264 libx264-dev libfaac-dev libtheora-dev "
    packages+="libfaac-dev libmp3lame-dev libvorbis-dev "
    # OpenCore — Adaptive Multi Rate Narrow Band (AMRNB) and Wide Band (AMRWB) speech codec
    packages+="libopencore-amrnb-dev libopencore-amrwb-dev "
    # Cameras programming interface libs
    packages+="libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils "

    _show_and_run _pushd_quiet ${PWD}
    _show_and_run cd /usr/include/linux
    _show_and_run sudo ln -sf ../libv4l1-videodev.h videodev.h
    _popd_quiet

    # GTK lib for the graphical user functionalities coming from OpenCV highghui module
    packages+="libgtk-3-dev "
    # Python libraries for Python3
    packages+="python3-dev python3-pip "
    packages+="python3-testresources "
    # Parallelism library C++ for CPU
    packages+="libtbb-dev "
    # Optimization libraries for OpenCV
    packages+="libatlas-base-dev gfortran "
    # Optional libraries
    packages+="libprotobuf-dev protobuf-compiler libgflags-dev "
    packages+="libgphoto2-dev libeigen3-dev libhdf5-dev doxygen "
    # Install OpenCL SDK related things
    packages+="ocl-icd-opencl-dev "

    # others
    packages+="libopencv-dev "

    _show_and_run _install_if_not_installed $packages

    _show_and_run pip3 install -U pip numpy
    _show_and_run pip3 install virtualenvwrapper

}

# =============================================================================
function _dj_setup_opencv_3_4_13() {
    _show_and_run _pushd_quiet ${PWD}

    _setup_opencv_dependencies

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf opencv-3.4.13
    _show_and_run rm -rf opencv_contrib-3.4.13

    opencv_url=https://github.com/opencv
    file=opencv-3.4.13.zip
    url_file=$opencv_url/opencv/archive/3.4.13.zip
    _show_and_run _wget_if_not_exist $file "76ea65511341b5cd02b2d00674e72247" $url_file -O
    file=opencv_contrib-3.4.13.zip
    url_file=$opencv_url/opencv_contrib/archive/3.4.13.zip
    _show_and_run _wget_if_not_exist $file "38ef3a805ea89677becca879bda70647" $url_file -O

    _show_and_run unzip opencv-3.4.13.zip
    _show_and_run unzip opencv_contrib-3.4.13.zip

    # some kind of virtual??
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/local/bin/virtualenvwrapper.sh
    _show_and_run mkvirtualenv cv -p python3

    _show_and_run cd opencv-3.4.13
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_C_COMPILER=/usr/bin/gcc-9 \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D WITH_TBB=ON \
        -D BUILD_opencv_cudacodec=OFF \
        -D ENABLE_FAST_MATH=1 \
        -D WITH_V4L=ON \
        -D WITH_QT=OFF \
        -D WITH_OPENGL=ON \
        -D WITH_GSTREAMER=ON \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D OPENCV_PC_FILE_NAME=opencv.pc \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_PYTHON3_INSTALL_PATH=~/.virtualenvs/cv/lib/python3.8/site-packages \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.4.13/modules \
        -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python \
        -D BUILD_EXAMPLES=ON \
        -D WITH_CUDNN=ON \
        -D CUDA_FAST_MATH=1 \
        -D WITH_CUDA=ON \
        -D OPENCV_DNN_CUDA=ON \
        -D CUDA_ARCH_BIN=7.5 \
        -D CUDNN_LIBRARY=/usr/local/cuda/lib64/libcudnn.so.7.6.5 \
        -D CUDNN_INCLUDE_DIR=/usr/local/cuda/include ..

    _show_and_run make -j$(($(nproc) / 2))
    _show_and_run sudo make install

    cat <<eom
    lib files *.so:
            /usr/local/lib/
    header files:
            /usr/local/include/opencv/
            /usr/local/include/opencv2/
    pkg-config file:
        /usr/local/lib/pkgconfig/opencv.pc
eom

    _popd_quiet
}

# =============================================================================
# https://medium.com/@sb.jaduniv/how-to-install-opencv-4-2-0-with-cuda-10-1-on-ubuntu-20-04-lts-focal-fossa-bdc034109df3
function _dj_setup_opencv_4_5_5() {
    _show_and_run _pushd_quiet ${PWD}

    if [[ -d "/usr/local/include/opencv2" ]]; then
        echo_error "other version of opencv is installed, exit"
        echo "you can remove by:"
        echo "$ sudo rm /usr/local/include/opencv2 -r"
        echo "$ sudo rm /usr/local/include/opencv4 -r"
        echo "$ sudo rm /usr/local/lib/libopencv_* -r"
        return
    fi

    _setup_opencv_dependencies

    file=4.5.5

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf opencv-$file
    # _show_and_run rm -rf opencv_contrib-$file

    opencv_url=https://codeload.github.com/opencv/opencv/zip/refs/tags

    url_file=$opencv_url/$file
    _show_and_run _wget_if_not_exist $file.zip "85a43b8f4748939ab8a865838c2dd7f2" $url_file -O
    # _show_and_run unzip $file.zip
    _show_and_run unzip -q $file.zip >/dev/null 2>&1
    # file=opencv_contrib-4.2.0.zip
    # url_file=$opencv_url/opencv_contrib/archive/4.2.0.zip
    # _show_and_run _wget_if_not_exist $file "4776354662667c85a91bcd19f6a13da7" $url_file -O
    # _show_and_run unzip $file

    # some kind of virtual??
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
        source /usr/local/bin/virtualenvwrapper.sh
    elif [ -f ~/.local/bin/virtualenvwrapper.sh ]; then
        source ~/.local/bin/virtualenvwrapper.sh
    fi
    mkvirtualenv cv -p python3

    _show_and_run cd opencv-$file
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D WITH_TBB=ON \
        -D BUILD_opencv_cudacodec=OFF \
        -D ENABLE_FAST_MATH=1 \
        -D WITH_V4L=ON \
        -D WITH_QT=OFF \
        -D WITH_OPENGL=ON \
        -D WITH_GSTREAMER=ON \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D OPENCV_PC_FILE_NAME=opencv.pc \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_PYTHON3_INSTALL_PATH=~/.virtualenvs/cv/lib/python3.8/site-packages \
        -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python \
        -D BUILD_EXAMPLES=ON \
        ..

    # -D WITH_CUBLAS=1 \
    # -D CMAKE_C_COMPILER=/usr/bin/gcc-9 \
    # -D WITH_CUDA=ON \
    # -D OPENCV_DNN_CUDA=ON \
    # -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.2.0/modules \
    # -D WITH_CUDNN=ON \
    # -D CUDA_FAST_MATH=1 \
    # -D CUDA_ARCH_BIN=7.5 \
    # -D CUDNN_LIBRARY=/usr/local/cuda/lib64/libcudnn.so.7.6.5 \
    # -D CUDNN_INCLUDE_DIR=/usr/local/cuda/include ..

    _show_and_run make -j$(($(nproc) / 2))
    _show_and_run sudo make install

    _show_and_run sudo ln -sf /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2

    _popd_quiet
}
