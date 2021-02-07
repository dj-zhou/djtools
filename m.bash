#!/bin/bash

# =============================================================================
# =============================================================================
# not the build command

# =============================================================================
# example of .project-stm32: 
# STM32F107VCT6
# 256 FLASH (*1024)
#  64 RAM   (*1024)


# example output
# Memory region         Used Size  Region Size  %age Used
#            FLASH:       14644 B         2 MB      0.70%
#             DTCM:          0 GB       128 KB      0.00%
#             SRAM:        4544 B       384 KB      1.16%
#         IDT_LIST:         200 B         2 KB      9.77%

# =============================================================================
function compile_makefile()
{
    clean_tag=$1
    if [ "$clean_tag" = "clean" ] ; then
        echo -e "\n${PRP} make clean${NOC}\n"
        make clean
        return
    fi
    echo -e "\n${PRP}make -j$(cat /proc/cpuinfo | grep processor | wc -l) $clean_tag${NOC}\n"
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) $clean_tag

    # stm32 project dedicated scripts, can be moved into Makefile
    if [ -f .project-stm32 ] && [ -f bin/*.elf ] ; then
        micro_controller=$(grep "STM32" .project-stm32 | awk '{print $1}')
        flash_kb=$(grep "FLASH" .project-stm32 | awk '{print $1}')
        ram_kb=$(grep "RAM" .project-stm32 | awk '{print $1}')
        text_used=$(arm-none-eabi-size -B -d bin/*.elf | awk '{print $1}')
        text_used=$(echo $text_used | awk '{print $2}')
        data_used=$(arm-none-eabi-size -B -d bin/*.elf | awk '{print $2}')
        data_used=$(echo $text_used | awk '{print $2}')
        flash_percentage=$(awk "BEGIN {print ($((text_used))+$((data_used))) * 100  / $((flash_kb)) / 1024}" | awk '{printf("%d",$0);}')
        bss_used=$(arm-none-eabi-size -B -d bin/*.elf | awk '{print $3}')
        bss_used=$(echo $bss_used | awk '{print $2}')
        ram_percentage=$(awk "BEGIN {print $((bss_used)) * 100  / $((ram_kb)) / 1024}" | awk '{printf("%d",$0);}')
        echo -e "${GRN}\n------------------------------------${NOC}"
        echo -e " $micro_controller memory usage: FLASH: ${flash_percentage}%, RAM: ${ram_percentage}%\n"
    fi
    return
}

# =============================================================================
function compile_cmakelist()
{
    current_directory=${PWD}

    clean_tag=$1
    if [ -z "$clean_tag" ] ; then
        if [ ! -d build ] ; then
            echo -e "${PRP}\n mkdir build && cd build && cmake ..${NOC}\n"
            mkdir build && cd build && cmake ..
        else
            cd build/
        fi
        echo -e "${PRP}\n make -j$(cat /proc/cpuinfo | grep processor | wc -l)${NOC}\n"
        make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    elif [ "$clean_tag" = "clean" ] ; then
        echo -e "${PRP}\n rm -rf build/, bin/${NOC}\n"
        rm -rf build/
        rm -rf bin/
    fi

    cd $current_directory
}

# =============================================================================
# if Makefile exists, use Makefile to compile and exit, otherwise
# if CMakeLists.txt exists, use cmake to compile (use default cmake ..) and exit, otherwise
# if meson.build exists, use "build meson -native" command to build and exit, otherwise
# if make.sh exist, use it, and make.sh file can be writen in whatever fashion

# build directories
# Makefile           bin/
# CMakeList.txt      build/
# meson.build       _bnative/, or _bcross.*/
# make.sh            no build directory

function compile_make_build_etc()
{
    clean_tag=$1
    current_dir=${PWD}

    # ------------------------------
    if [ -f "Makefile" ] ; then
        compile_makefile $clean_tag
        return
    fi
    # ------------------------------
    if [ -f "CMakeLists.txt" ] ; then
        compile_cmakelist $clean_tag
        return
    fi
    # ------------------------------
    if [ -f "meson.build" ] ; then
        if [ "$clean_tag" = 'clean' ] ; then
            rm build -rf
            rm _bcross* -rf
            rm _bnative -rf
            rm builddir -rf
            return
        fi
        build meson -native
        return
    fi
    # ------------------------------
    if [ -f "make.sh" ] ; then
        ./make.sh $clean_tag
        return
    fi
    echo -e "(djtools) m/mc: ${RED}build method not defined${NOC}"
    cd $current_dir
}

# =============================================================================
function m()
{
    compile_make_build_etc $1 $2 $3 $4 $5
}

# =============================================================================
function mc()
{
    compile_make_build_etc clean
}
