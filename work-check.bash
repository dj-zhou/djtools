#!/bin/bash

# =============================================================================
function _work_check_git_source() {
    # git repo has a .git/ directory
    # git submodule has a .git file
    if [[ ! -d ".git" && ! -f ".git" ]]; then
        git_source="----"
        echo $git_source
        return
    fi
    git_remote_v=$(git remote -v | grep fetch)
    if [[ $git_remote_v = *"bitbucket"* ]]; then
        git_source="BitBucket"
    elif [[ $git_remote_v = *"github"* ]]; then
        git_source="GitHub"
    else
        git_source="----"
    fi
    echo $git_source
}

# =============================================================================
function _work_check() {

    fast_option_provided=false
    for arg in "$@"; do
        case $arg in
        --fast)
            fast_option_provided=true && break
            ;;
        esac
    done

    cur_dir=$PWD

    package_width=30
    branch_width=30
    tag_width=30    # if len > 30, then use xxx for the last three charactors
    status_width=10 # "upstream-gone" revised to "lost"

    if [[ $# = 0 ]]; then
        target_path=$(pwd)
    elif [[ $# = 1 && $1 = "." ]]; then
        target_path=$(realpath .)
    elif [[ -d $1 ]]; then
        target_path="$1"
    else
        echo_warn "dj work-check: \"$1\" is not a valid workspace path."
        return
    fi

    cd $target_path
    workspace_path=$(realpath $target_path)

    if [ $system = 'Linux' ]; then
        hostname=${HOSTNAME}
    elif [ $system = 'Darwin' ]; then
        hostname=$(scutil --get ComputerName)
    fi
    OUTPUT_FILE="$workspace_path/work-check-${hostname}-$(_get_time_short).txt"

    echo -e '\c' >"$OUTPUT_FILE"
    echo -ne "\nWorking Directory: "$workspace_path"\n" >>"$OUTPUT_FILE"
    echo -ne "Computer Hostname: "$hostname"\n" >>"$OUTPUT_FILE"
    echo -ne "Computer Username: "$USER"\n" >>"$OUTPUT_FILE"
    echo -ne "Work Check Time  : "$(date)"\n\n" >>"$OUTPUT_FILE"
    echo -e "${HGRN}Dir/Repo${NOC} | ${CYN}Branch${NOC} | ${GRN}Tag${NOC} | Commit Time | Commit Message | Status | Dirty"
    $(_write_to_file_width "Commit Time" 20 "$OUTPUT_FILE")
    $(_write_to_file_width "Source" 10 "$OUTPUT_FILE")
    $(_write_to_file_width "Status" $status_width "$OUTPUT_FILE")
    $(_write_to_file_width "Dir/Repo" $package_width "$OUTPUT_FILE")
    $(_write_to_file_width "Branch" $branch_width "$OUTPUT_FILE")
    $(_write_to_file_width "Tag" $tag_width "$OUTPUT_FILE")
    $(_write_to_file_width "Commit" 10 "$OUTPUT_FILE")
    $(_write_to_file_width "Commit Message" 50 "$OUTPUT_FILE")
    echo -ne "\n" >>"$OUTPUT_FILE"

    has_dirty_repo="no"
    for item in $workspace_path/*; do
        if [[ ! -d $item ]]; then
            continue
        fi
        repo=$(basename "$item")
        printf "${HGRN}$repo${NOC}"
        cd "$workspace_path/$repo"

        # --------------------------------------------------------
        git_source=$(_work_check_git_source)
        # --------------------------------------------------------
        if [[ $git_source != "----" ]]; then
            if [ "$fast_option_provided" = false ]; then
                git fetch -p --quiet
            fi
            b_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
            b_name="${b_name/ detached / }"
            # if too long, make it shorter
            b_name_len=${#b_name}
            if [ $b_name_len -gt $branch_width ]; then
                b_name=${b_name:0:$branch_width}
            fi
            printf " | ${CYN}$b_name${NOC}"
            t_name_original=$(git describe --abbrev=7 --dirty --always --tags 2>/dev/null)
            t_name="${t_name_original/-dirty/+}"
            t_name="${t_name_original/refs\/tags\/tag\//}"
            printf " | ${GRN}$t_name${NOC}"
            branch_commit=$(git log --pretty=oneline | awk 'NR==1')
            branch_commit_len=${#branch_commit}
            branch_commit_value=${branch_commit:0:10}"     "
            date_time=$(git log -1 --format=%ai)
            printf " | ${date_time:0:19}"
            date_time="${date_time:0:19}"
            # --------------------------------------------------------
            commit_str=${branch_commit:41:$branch_commit_len-41}
            # if too long, make it shorter
            commit_str_len=${#commit_str}
            if [ $commit_str_len -gt 50 ]; then
                commit_str=${commit_str:0:50}"......"
            fi
            printf " | ${commit_str:0:25}..."

            # # --------------------------------------------------------
            # to see if current commit is ahead or behind the remote
            git_status=$(git status)
            if [[ $git_status = *"is ahead"* ]]; then
                git_status_str="ahead"
                printf " | ${YLW}ahead${NOC}"
            elif [[ $git_status = *"is behind"* ]]; then
                git_status_str="behind"
                printf " | ${YLW}behind${NOC}"
            elif [[ $git_status = *"upstream is gone"* ]]; then
                git_status_str="lost"
                printf " | ${RED}upstream-gone${NOC}"
            else
                git_status_str="    "
                printf " | ${GRN}✔️${NOC} "
            fi
            if [[ $t_name_original = *"dirty"* ]]; then
                has_dirty_repo="yes"
                if [[ $git_status_str = "    " ]]; then
                    git_status_str="dirty"
                else
                    git_status_str=$git_status_str" + dirty"
                fi
                printf " | ${RED}dirty${NOC}"
            fi
        else
            b_name="----"
            t_name="----"
            branch_commit_value="----------"
            commit_str="----"
            git_status_str="----"
            printf " | not a git repo"
        fi
        # --------------------------------------------------------
        $(_write_to_file_width "$date_time" 20 "$OUTPUT_FILE")
        $(_write_to_file_width "$git_source" 10 "$OUTPUT_FILE")
        $(_write_to_file_width "$git_status_str" $status_width "$OUTPUT_FILE")
        $(_write_to_file_width "$repo" $package_width "$OUTPUT_FILE")
        $(_write_to_file_width "$b_name" $branch_width "$OUTPUT_FILE")
        $(_write_to_file_width "$t_name" $tag_width "$OUTPUT_FILE")
        $(_write_to_file_width "$branch_commit_value" 10 "$OUTPUT_FILE")
        $(_write_to_file_width "$commit_str" 50 "$OUTPUT_FILE")
        echo -ne "\n" >>"$OUTPUT_FILE"

        cd $cur_dir
        echo -e ""
    done
    if [[ $has_dirty_repo = "no" ]]; then
        echo -ne "\n\n" >>"$OUTPUT_FILE"
        echo -e "${HWHT}work-check result is stored in file $OUTPUT_FILE${NOC}"
        return
    fi
    echo -ne "\n\n" >>"$OUTPUT_FILE"
    echo -ne "+-----------------------------------------------+\n" >>"$OUTPUT_FILE"
    echo -ne "|--------------- git simple diff ---------------|\n" >>"$OUTPUT_FILE"
    echo -ne "+-----------------------------------------------+\n" >>"$OUTPUT_FILE"
    for item in $workspace_path/*; do
        if [[ ! -d $item ]]; then
            continue
        fi

        repo=$(basename "$item")
        cd "$workspace_path/$repo"

        git_source=$(_work_check_git_source)
        if [[ $git_source = "----" ]]; then
            continue
        fi
        branch_diff=$(git diff | awk 'NR==1')
        if [[ ! -z $branch_diff ]]; then
            echo -ne "\n+------ $repo ------+\n" >>"$OUTPUT_FILE"
            echo -ne "$branch_diff\n" >>"$OUTPUT_FILE"
        fi
        # echo $(basename "$item")": not a supported git repo"
        cd $cur_dir
    done

    echo -ne "\n\n" >>"$OUTPUT_FILE"
    echo -e "${HWHT}work-check result is stored in file $OUTPUT_FILE${NOC}"

    cd ${cur_dir}
}
