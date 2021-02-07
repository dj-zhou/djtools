#!/bin/bash


# =============================================================================
# may not be a good way to install opencv
# recommend to install opencv-4.1.1
function _dj_setup_opencv_2_4_13()
{
    cwd_before_running=$PWD

    echo -e "\n Have you installed Qt? The openCV installation may need Qt"
    echo " use the following command to install Qt 5.11.2"
    echo -e "     dj setup qt-5.11.2\n\n"
    _press_enter_or_wait_s_continue 20
    
    cd ~ && mkdir -p soft && cd soft/

    sudo rm -rf opencv-4.1.1 # otherwise, it will not going to clone into this folder

    wget https://codeload.github.com/opencv/opencv/zip/2.4.13.6
    mv 2.4.13.6 opencv-2.4.13.6.zip
    unzip opencv-2.4.13.6.zip
    cd opencv-2.4.13.6
    mkdir build && cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON \
          WITH_OPENCL=ON WITH_GDAL=ON WITH_IPP=ON BUILD_JASPER=ON BUILD_JPEG=ON \
          BUILD_PNG=ON BUIILD_TIFF=ON WITH_OPENMP=ON ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install

    _ask_to_remove_a_folder opencv-2.4.13
    _ask_to_remove_a_file opencv-2.4.13.zip

    cd ${cwd_before_running}
    echo -e "\n" 
    echo " lib files *.so are installed in /usr/local/lib/"
    echo " header files are installded in /usr/local/include/opencv2/"
    echo -e "\n" 
}

# =============================================================================
function _setup_opencv_dependencies()
{
    # Generic tools
    packages="build-essential cmake pkg-config unzip yasm git checkinstall "
    # Image I/O libs
    packages+="libjpeg-dev libpng-dev libpng12-dev libtiff-dev libtiff5-dev "
    # Video/Audio Libs — FFMPEG, GSTREAMER, x264 and so on
    packages+="libavcodec-dev libavformat-dev libswscale-dev libavresample-dev "
    packages+="libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev "
    packages+="libxvidcore-dev x264 libx264-dev libfaac-dev libtheora-dev "
    packages+="libfaac-dev libmp3lame-dev libvorbis-dev "
    # OpenCore — Adaptive Multi Rate Narrow Band (AMRNB) and Wide Band (AMRWB) speech codec
    packages+="libopencore-amrnb-dev libopencore-amrwb-dev "
    # Cameras programming interface libs
    packages+="libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils "

    cwd_before_running=$PWD
    cd /usr/include/linux
    sudo ln -s -f ../libv4l1-videodev.h videodev.h
    cd $cwd_before_running

    # GTK lib for the graphical user functionalities coming from OpenCV highghui module
    packages+="libgtk-3-dev "
    # Python libraries for Python3
    packages+="python3-dev python3-pip "
    sudo -H pip3 install -U pip numpy
    packages+="python3-testresources "
    # Parallelism library C++ for CPU
    packages+="libtbb-dev "
    # Optimization libraries for OpenCV
    packages+="libatlas-base-dev gfortran "
    # Optional libraries
    packages+="libprotobuf-dev protobuf-compiler "
    packages+="libgoogle-glog-dev libgflags-dev "
    packages+="libgphoto2-dev libeigen3-dev libhdf5-dev doxygen "
    # Install OpenCL SDK related things
    packages+="ocl-icd-opencl-dev "

    # others
    packages+="libopencv-dev libjasper-dev libgstreamer-plugins-base0.10-dev "
    packages+="libgstreamer0.10-dev libqt4-dev "
    
    _install_if_not_installed $packages

}

# =============================================================================
function _dj_setup_opencv_3_4_13()
{
    _setup_opencv_dependencies

    cwd_before_running=$PWD

    cd ~ && mkdir -p soft && cd soft/

    rm -rf opencv-3.4.13
    rm -rf opencv_contrib-3.4.13
    
    opencv_url=https://github.com/opencv
    file=opencv-3.4.13.zip
    url_file=$opencv_url/opencv/archive/3.4.13.zip
    _wget_if_not_exist $file "76ea65511341b5cd02b2d00674e72247" $url_file -O
    file=opencv_contrib-3.4.13.zip
    url_file=$opencv_url/opencv_contrib/archive/3.4.13.zip
    _wget_if_not_exist $file "38ef3a805ea89677becca879bda70647" $url_file -O
    
    unzip opencv-3.4.13.zip
    unzip opencv_contrib-3.4.13.zip

    # some kind of virtual??
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/local/bin/virtualenvwrapper.sh
    mkvirtualenv cv -p python3
    
    cd opencv-3.4.13
    mkdir build && cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_C_COMPILER=/usr/bin/gcc-9 \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D WITH_TBB=ON \
        -D BUILD_opencv_cudacodec=OFF \
        -D ENABLE_FAST_MATH=1 \
        -D WITH_CUBLAS=1 \
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
        -D CUDNN_INCLUDE_DIR=/usr/local/cuda/include  ..
    
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install
    
    cd ${cwd_before_running}
    cat << eom
    lib files *.so:
            /usr/local/lib/
    header files:
            /usr/local/include/opencv/
            /usr/local/include/opencv2/
    pkg-config file:
        /usr/local/lib/pkgconfig/opencv.pc
eom
}

# =============================================================================
# the installation is from the book, which has a github repo:
# https://github.com/PacktPublishing/Learn-OpenCV-4-By-Building-Projects-Second-Edition
# however, this is a bad reference
# notice: there is some manual work todo before actually automate this procedure
# this does not work on Ubuntu 20.04!
function _dj_setup_opencv_4_1_1()
{
    if [[ -d "/usr/local/include/opencv2" ]] ; then
        echo "other version of opencv is installed, exit"
        return
    fi

    cwd_before_running=$PWD

    echo -e "\n Have you installed Qt? The openCV installation may need Qt"
    echo " use the following command to install Qt 5.14.2"
    echo -e "     dj setup qt-5.14.2\n\n"
    _press_enter_or_wait_s_continue 20

    _setup_opencv_dependencies

    cd ~ && mkdir -p soft && cd soft/
    rm -rf opencv-4.1.1

    git clone https://github.com/dj-zhou/opencv-4.1.1.git
    git clone https://github.com/dj-zhou/ippicv.git

    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        git clone https://github.com/dj-zhou/opencv_contrib-4.1.1.git
    fi
    
    cd opencv-4.1.1
    git checkout add-eigen3-include
    sudo rm -rf build && mkdir build && cd build
    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
              -D INSTALL_C_EXAMPLES=ON -D BUILD_EXAMPLES=ON \
              -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.1.1/modules ..
    else
        cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
              -D INSTALL_C_EXAMPLES=ON -D BUILD_EXAMPLES=ON ..
    fi
    
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install
    
    sudo ln -sf /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2
    

    cd ${cwd_before_running}
    cat << eom
    lib files *.so are installed in
            /usr/local/lib/
    header files are installded in
            /usr/local/include/opencv4/
            in which there is another directory opencv2/
    
    example code or template project can be seen from:
    https://github.com/dj-zhou/opencv4-demo/001-imread-imshow

eom
}

# =============================================================================
# https://medium.com/@sb.jaduniv/how-to-install-opencv-4-2-0-with-cuda-10-1-on-ubuntu-20-04-lts-focal-fossa-bdc034109df3
function _dj_setup_opencv_4_2_0()
{
    if [[ -d "/usr/local/include/opencv2" ]] ; then
        echo "other version of opencv is installed, exit"
        return
    fi

    _setup_opencv_dependencies

    cwd_before_running=$PWD

    cd ~ && mkdir -p soft && cd soft/
    
    rm -rf opencv-4.2.0
    rm -rf opencv_contrib-4.2.0
    
    opencv_url=https://github.com/opencv
    file=opencv-4.2.0.zip
    url_file=$opencv_url/opencv/archive/4.2.0.zip
    _wget_if_not_exist $file "b02b54115f1f99cb9e885d1e5988ff70" $url_file -O
    file=opencv_contrib-4.2.0.zip
    url_file=$opencv_url/opencv_contrib/archive/4.2.0.zip
    _wget_if_not_exist $file "4776354662667c85a91bcd19f6a13da7" $url_file -O
    
    # some kind of virtual??
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/local/bin/virtualenvwrapper.sh
    mkvirtualenv cv -p python3
    
    cd opencv-4.2.0
    mkdir build && cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_C_COMPILER=/usr/bin/gcc-9 \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D WITH_TBB=ON \
        -D BUILD_opencv_cudacodec=OFF \
        -D ENABLE_FAST_MATH=1 \
        -D WITH_CUBLAS=1 \
        -D WITH_V4L=ON \
        -D WITH_QT=OFF \
        -D WITH_OPENGL=ON \
        -D WITH_GSTREAMER=ON \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D OPENCV_PC_FILE_NAME=opencv.pc \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_PYTHON3_INSTALL_PATH=~/.virtualenvs/cv/lib/python3.8/site-packages \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.2.0/modules \
        -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python \
        -D BUILD_EXAMPLES=ON \
        -D WITH_CUDNN=ON \
        -D CUDA_FAST_MATH=1 \
        -D WITH_CUDA=ON \
        -D OPENCV_DNN_CUDA=ON \
        -D CUDA_ARCH_BIN=7.5 \
        -D CUDNN_LIBRARY=/usr/local/cuda/lib64/libcudnn.so.7.6.5 \
        -D CUDNN_INCLUDE_DIR=/usr/local/cuda/include  ..
    
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install
    
    sudo ln -sf /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2

    cd ${cwd_before_running}
}
