#!/bin/bash

# xmake getter
# usage: bash <(curl -s <my location>) [[mirror:]branch] [commit/__install_only__]

set -o pipefail

if [ 0 -ne "$(id -u)" ]
then
    sudoprefix=sudo
else
    sudoprefix=
fi

remote_get_content(){
    if curl --version >/dev/null 2>&1
    then
        curl -fsSL "$1"
    elif wget --version >/dev/null 2>&1
    then
        wget -q "$1" -O -
    fi
}

if [ "$1" = "__uninstall__" ]
then
    # uninstall
    makefile=$(remote_get_content https://github.com/tboox/xmake/raw/master/makefile)
    while which xmake >/dev/null 2>&1
    do
        pre=$(which xmake | sed 's/\/bin\/xmake$//')
        # don't care if make exists -- if there's no make, how xmake built and installed?
        echo "$makefile" | make -f - uninstall prefix="$pre" 2>/dev/null || echo "$makefile" | $sudoprefix make -f - uninstall prefix="$pre" || exit $?
    done
    exit
fi

# below is installation
# print a LOGO!
echo '                         _                      '
echo '    __  ___ __  __  __ _| | ______              '
echo '    \ \/ / |  \/  |/ _  | |/ / __ \             '
echo '     >  <  | \__/ | /_| |   <  ___/             '
echo '    /_/\_\_|_|  |_|\__ \|_|\_\____| getter      '
echo '                                                '

if [ 'x__local__' != "x$1" ]
then
    brew --version >/dev/null 2>&1 && brew install --HEAD xmake && xmake --version && exit
fi

my_exit(){
    rv=$?
    if [ "x$1" != x ]
    then
        echo -ne '\x1b[41;37m'
        echo "$1"
        echo -ne '\x1b[0m'
    fi
    rm -rf /tmp/$$xmake_getter 2>/dev/null
    if [ "x$2" != x ]
    then
        if [ $rv -eq 0 ];then rv=$2;fi
    fi
    exit "$rv"
}
test_tools()
{
    prog='#include<stdio.h>\n#include<readline/readline.h>\nint main(){readline(0);return 0;}'
    {
        git --version &&
        make --version &&
        {
            echo -e "$prog" | cc -xc - -o /dev/null -lreadline ||
            echo -e "$prog" | gcc -xc - -o /dev/null -lreadline ||
            echo -e "$prog" | clang -xc - -o /dev/null -lreadline
        }
    } >/dev/null 2>&1
}
install_tools()
{
    { apt-get --version >/dev/null 2>&1 && $sudoprefix apt-get install -y git build-essential libreadline-dev ccache; } ||
    { yum --version >/dev/null 2>&1 && $sudoprefix yum install -y git readline-devel ccache && $sudoprefix yum groupinstall -y 'Development Tools'; } ||
    { zypper --version >/dev/null 2>&1 && $sudoprefix zypper --non-interactive install git readline-devel ccache && $sudoprefix zypper --non-interactive install -t pattern devel_C_C++; } ||
    { pacman -V >/dev/null 2>&1 && $sudoprefix pacman -S --noconfirm --needed git base-devel ccache; }
}
test_tools || { install_tools && test_tools; } || my_exit "$(echo -e 'Dependencies Installation Fail\nThe getter currently only support these package managers\n\t* apt\n\t* yum\n\t* zypper\n\t* pacman\nPlease install following dependencies manually:\n\t* git\n\t* build essential like `make`, `gcc`, etc\n\t* libreadline-dev (readline-devel)\n\t* ccache (optional)')" 1
branch=master
mirror=tboox
IFS=':'
if [ x != "x$1" ]
then
    brancharr=($1)
    if [ ${#brancharr[@]} -eq 1 ]
    then
        branch=${brancharr[0]}
    fi
    if [ ${#brancharr[@]} -eq 2 ]
    then
        branch=${brancharr[1]}
        mirror=${brancharr[0]}
    fi
    echo "Branch: $branch"
fi
if [ 'x__local__' != "x$branch" ]
then
    git clone --depth=50 -b "$branch" "https://github.com/$mirror/xmake.git" /tmp/$$xmake_getter || my_exit "$(echo -e 'Clone Fail\nCheck your network or branch name')"
    if [ x != "x$2" ]
    then
        cd /tmp/$$xmake_getter || my_exit 'Chdir Error'
        git checkout -qf "$2"
        cd - || my_exit 'Chdir Error'
    fi
else
    cp -r "$(git rev-parse --show-toplevel 2>/dev/null || echo thisshouldnotbeafilename)" /tmp/$$xmake_getter || my_exit "$(echo -e 'Clone Fail\nLocal repo might be not found')"
fi
if [ 'x__install_only__' != "x$2" ]
then
    make -C /tmp/$$xmake_getter --no-print-directory build 
    rv=$?
    if [ $rv -ne 0 ]
    then
        make -C /tmp/$$xmake_getter/core --no-print-directory error
        my_exit "$(echo -e 'Build Fail\nDetail:\n' | cat - /tmp/xmake.out)" $rv
    fi
fi
# PATHclone=$PATH
# patharr=($PATHclone)
if [ "$prefix" = "" ]
then
    prefix=~/.local
fi
# for st in "${patharr[@]}"
# do
#     if [[ "$st" = "$HOME"* ]]
#     then
#         cwd=$PWD
#         mkdir -p "$st"
#         cd "$st" || continue
#         echo $$ > $$xmake_getter_test 2>/dev/null || continue
#         rm $$xmake_getter_test 2>/dev/null || continue
#         cd .. || continue
#         mkdir -p share 2>/dev/null || continue
#         prefix=$(pwd)
#         cd "$cwd" || my_exit 'Chdir Error'
#         break
#     fi
# done
if [ "x$prefix" != x ]
then
    make -C /tmp/$$xmake_getter --no-print-directory install prefix="$prefix"|| my_exit 'Install Fail'
else
    $sudoprefix make -C /tmp/$$xmake_getter --no-print-directory install || my_exit 'Install Fail'
fi
shell_profile(){
    if   [[ "$SHELL" = */zsh ]]; then echo ~/.zshrc
    elif [[ "$SHELL" = */ksh ]]; then echo ~/.kshrc
    else echo ~/.bash_profile; fi
}
if xmake --version >/dev/null 2>&1; then xmake --version; else
    echo "export PATH=$prefix/bin:\$PATH" >> "$(shell_profile)"
    export PATH=$prefix/bin:$PATH
    xmake --version
    echo "Reload shell profile by running the following command now!"
    echo -e "\x1b[1msource '$(shell_profile)'\x1b[0m"
fi
