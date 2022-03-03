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
function _dj_python3_venv_numpy_pandas() {

    python3_v=$(version check python3)
    echo "Python3: $python3_v"
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
    # install latest pip3
    _show_and_run python -c "import pkg_resources; pkg_resources.require('pip>=21')" &>/dev/null || pip install --upgrade 'pip>=21'
    # prepare requirements.txt file
    requirements_file=$(mktemp) # FIXME: cannot use _show_and_run here, don't know why
    _show_and_run trap 'rm -f "$requirements_file"' SIGTERM EXIT
    _show_and_run cat >"$requirements_file" <<EOF
    black
    ipympl
    jupyterlab
    jupyterlab_templates
    matplotlib
    numba
    numpy
    pandas
    pythreejs
    plyfile
    pyyaml
    scipy
EOF
    # some fix (will know)
    _show_and_run export PIP_INDEX_URL=https://pypi.org/simple
    # install packages
    _show_and_run python -c "import pkg_resources; pkg_resources.require(open('${requirements_file}',mode='r'))" &>/dev/null || pip install --ignore-installed -r "${requirements_file}"
    # temporary fix fr nodejs
    nodejs_v=$(version check nodejs)
    anw=$(_version_if_ge_than $nodejs_v "12.0.0")
    if [ "$anw" = "no" ]; then
        _show_and_run dj setup nodejs
    fi
    # start Jupyter-lab
    _show_and_run export JUPYTER_CONFIG_DIR="$VENV_DIR/.jupyter"
    _show_and_run jupyter labextension install jupyter-threejs
    _show_and_run jupyter nbextension install https://github.com/drillan/jupyter-black/archive/master.zip — user
    _show_and_run jupyter nbextension enable jupyter-black-master/jupyter-black
    _show_and_run jupyter-lab
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
