#!/bin/bash
# variables used in dj-commands.bash ----------
_python3_cmds="install virtual-env "
_install_list="matplotlib numpy pandas "
_virtual_env_list="numpy-pandas "

# =============================================================================
function _dj_python3_install() {
    if [ "$1" = "matplotlib" ]; then
        sudo apt-get install python3-matplotlib
        return
    fi
    if [ "$1" = "numpy" ]; then
        pip3 install numpy
        return
    fi
    if [ "$1" = "pandas" ]; then
        pip3 install pandas
        return
    fi
}

# =============================================================================
# this seems failed in some Ubuntu 20.04 system, don't know why
# this works in Ubuntu 18.04
function _dj_python3_venv_numpy_pandas() {

    python3_v=$(version check python3)
    _show_and_run echo "Python3: $python3_v"
    if [[ $python3_v = *"3.8"* ]]; then
        _show_and_run _install_if_not_installed python3.8-venv
    fi

    VENV_DIR=".venv"

    if [[ -d "$VENV_DIR" && -f $VENV_DIR/bin/activate ]]; then
        _show_and_run source "$VENV_DIR"/bin/activate
    else
        _show_and_run python3 -m venv "$VENV_DIR"
        _show_and_run source "$VENV_DIR"/bin/activate
    fi
    _show_and_run echo "install latest pip3"
    python -c "import pkg_resources; pkg_resources.require('pip>=21')" \
        &>/dev/null || pip install --upgrade 'pip>=21'
    _show_and_run echo "install wheel"
    python -c "import pkg_resources; pkg_resources.require('pip>=21')" \
        &>/dev/null || pip install wheel
    # prepare requirements.txt file
    rqs_file=$(mktemp)
    trap 'rm -f "$rqs_file"' SIGTERM EXIT
    cat >"$rqs_file" <<EOF
    jupyterlab
    jupyter-black
    jupyterlab_templates
    numpy
    pandas
EOF
    # some fix (will know)
    _show_and_run export PIP_INDEX_URL=https://pypi.org/simple
    _show_and_run echo "install packages"
    # install packages
    python -c "import pkg_resources; pkg_resources.require(open('${rqs_file}',mode='r'))" \
        &>/dev/null || pip install --ignore-installed -r "${rqs_file}"
    # # temporary fix fr nodejs
    nodejs_v=$(version check node)
    anw=$(_version_if_ge_than $nodejs_v "12.0.0")
    if [ "$anw" = "no" ]; then
        _show_and_run dj setup nodejs
    fi
    # start Jupyter-lab
    _show_and_run export JUPYTER_CONFIG_DIR="$VENV_DIR/.jupyter"
    _show_and_run jupyter labextension install jupyter-threejs
    _show_and_run jupyter nbextension install \
        https://github.com/drillan/jupyter-black/archive/master.zip --user
    _show_and_run jupyter nbextension enable jupyter-black-master/jupyter-black
    _show_and_run jupyter-lab --port 1688
}

# =============================================================================
function _dj_python3() {
    if [ "$1" = "install" ]; then
        shift 1
        _dj_python3_install "$@"
        return
    fi
    if [ "$1" = "virtual-env" ]; then
        if [ "$2" = "numpy-pandas" ]; then
            _dj_python3_venv_numpy_pandas
            return
        fi
    fi
}
