#!/bin/bash
#git-bootstrap.sh
#
#Written by Jimmy Xu 2012-11-14
#Last modified: 2012-11-29
#2012-11-22:  fix bug on Ubuntu
#2012-11-29:  support MacOSX
#2013-05-16:  support MSysGit
#
#This script support
#1.CentOS 5.x/6.x  i386/i686/x86_64
#2.Ubuntu 11.x/12.x i386/i686/x86_64
#3.Cygwin
#4.MacOSX
#5.MSysGit
#
#

STARTTIME=`date "+%Y-%m-%d %H:%M:%S"`

######################################
FNAME=`basename $0`
MODE=""

if [ "${FNAME}" == "git-bootstrap.sh" ]
then
  echo "Run in script"
  MODE="0"
else
  echo "Run in shell"
  MODE="1"
  set +H
fi

##Function declaration####################################

function quit(){
  MSG=$1
  if [ ${MODE} -eq 1 ]
  then
  #shell
    set -H
  else
  #script
    echo $MSG
    exit
  fi
}

function download(){
  date "+%Y-%m-%d %H:%M:%S Start download $1"
  wget -q -c $1
}

function setup_centos(){

  echo
  echo "Setup under CentOS..."
  echo


  echo
  echo "=============================================="
  echo "Step 2. Now will download and install git & gitk & tig"
  echo


  INSTALL_METHOD="yum"  #yum|rpm

  if [ "${INSTALL_METHOD}" == "yum" ]
  then
   #yum

    #google is too slow,so disable it
    sed -i -e 's/enabled=1/enabled=0/' /etc/yum.repos.d/google*

    #yum clean all
    echo "Start Install packages by yum..."
    yum -y  -q install perl-DBI perl-Git bash-completion util-linux git-all gitk tig git-flow

    echo
    echo "Finish Install packages by yum!"
    echo


  else

    cd ${ARCH}
   #rm -rf ${ARCH}
   mkdir -p ${ARCH}
   if [ ! -d ${ARCH} ]
   then
     quit ">>Create dir ${ARCH} failed,Quit!"
   else
     echo "cd ${ARCH}"
   fi



   #rpm
    echo "Install util-linux(support colrm)"
    yum -q -y install util-linux

    #download packages
    GIT_URL="http://pkgs.repoforge.org/git"
    echo
    echo "GIT_URL: ${GIT_URL}"
    echo
    echo "Download git"
    download "${GIT_URL}/git-all-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/perl-Git-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/gitk-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/git-arch-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/git-cvs-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/git-daemon-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/git-email-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/git-gui-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/git-svn-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/gitweb-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/emacs-git-1.7.11.3-1.${SUFFIX}.rpm"
    download "${GIT_URL}/git-1.7.11.3-1.${SUFFIX}.rpm"
    download "http://pkgs.repoforge.org/perl-DBI/perl-DBI-1.621-1.${SUFFIX}.rpm"

    echo
    echo "Download tig"
    download "http://pkgs.repoforge.org/tig/tig-1.1-1.el${OSVERSION}.rf.${ARCH}.rpm"
    download "http://pkgs.repoforge.org/bash-completion/bash-completion-20060301-1.el${OSVERSION}.rf.noarch.rpm"


    echo
    echo "Start install rpm"
    echo
    rpm  -Uvh *.rpm
    echo

    cd ..

  fi



}



function setup_ubuntu(){

  echo
  echo "Setup under Ubuntu..."
  echo


  echo
  echo "=============================================="
  echo "Step 2. Now will download and install git & gitk & tig"
  echo

  apt-get install git git-core git-man git-arch git-extras git-flow git-gui git-review git-sh git-stuff

}


function setup_cygwin(){

  echo
  echo "Setup under cygwin..."
  echo

PKG_PERL="perl"
PKG_GIT="git"
PKG_GIT_COMP="git-completion"
PKG_GIT_GUI="git-gui"
PKG_GITK="gitk"
PKG_TIG="tig"
PKG_OODIFF="git-oodiff"
PKG_DOS2UNIX="dos2unix"

echo -e "Check required packages: \nperl \ngit \ngit-completion \ngit-gui \ngitk \ntig \ngit-oodiff \ndos2unix"
echo


if [  `cygcheck -c -d  | awk '{print $1}' | grep -E "^perl$" | wc -l`   -eq 0  ]
then
  echo "${PKG_PERL} not installed,please install first."
  quit
fi

if [  `cygcheck -c -d  | awk '{print $1}' | grep -E "^git$" | wc -l`  -eq 0  ]
then
  echo "${PKG_GIT} not installed,please install first."
  quit
fi

if [  `cygcheck -c -d | awk '{print $1}' | grep -E "^git-completion$" | wc -l`  -eq 0  ]
then
  echo "${PKG_GIT_COMP} not installed,please install first."
  quit
fi

if [  `cygcheck -c -d | awk '{print $1}' | grep -E "^git-gui$" | wc -l`   -eq 0  ]
then
  echo "${PKG_GIT_GUI} not installed,please install first."
  quit
fi

if [  `cygcheck -c -d | awk '{print $1}' | grep -E "^gitk$" | wc -l`  -eq 0  ]
then
  echo "${PKG_GITK} not installed,please install first."
  quit
fi

if [  `cygcheck -c -d | awk '{print $1}' | grep -E "^tig$" | wc -l`   -eq 0  ]
then
  echo "${PKG_TIG} not installed,please install first."
  quit
fi

if [  `cygcheck -c -d | awk '{print $1}' | grep -E "^git-oodiff$" | wc -l`  -eq 0  ]
then
  echo "${PKG_OODIFF} not installed,please install first."
  quit
fi

if [  `cygcheck -c -d | awk '{print $1}' | grep -E "^dos2unix$" | wc -l`  -eq 0  ]
then
  echo "${PKG_DOS2UNIX} not installed,please install first."
  quit
fi



echo "Check packages passed!"




  # cygcheck -c -d  | awk '{print $1}' | grep -E "^perl$|^git$|^git-completion|^git-gui|^gitk$|^tig$|^git-oodiff$"



}
############################################


function setup_macosx(){

  echo
  echo "Setup under macosx..."
  echo

  if [  ${IS_ROOT} -ne 1 ]
  then
    # hasn't root permisson
    quit "User `who am i | awk '{print $1}'` must has root permission!"
  fi

  port
  if [ $? -eq 0 ]
  then

    echo
    echo  -e "Macports installed, please uninstall it and install Homebrew"
    echo
    echo "please run the following command:"
    echo "  port -f uninstall installed"
    echo
    echo "then run the following command:"
    echo '  rm -rf \'
    echo '    /opt/local \'
    echo '    /Applications/DarwinPorts \'
    echo '    /Applications/MacPorts \'
    echo '    /Library/LaunchDaemons/org.macports.* \'
    echo '    /Library/Receipts/DarwinPorts*.pkg \'
    echo '    /Library/Receipts/MacPorts*.pkg \'
    echo '    /Library/StartupItems/DarwinPortsStartup \'
    echo '    /Library/Tcl/darwinports1.0 \'
    echo '    /Library/Tcl/macports1.0 \'
    echo '    ~/.macports'
    echo
    echo "then run the following command:"
    echo '  ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"'
    echo
    quit "Please install Homebrew, then re-execute this script!"

  else
    echo
    echo "Macports not installed,OK"
  fi

  brew --version
  if [ $? -ne 0 ]
  then
    echo
    echo "Homebrew not installed ,please install it first "
    echo
    echo "run the following command:"
    echo 'ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"'
    echo
    quit "Please install Homebrew, then re-execute this script!"
  fi

  sudo -u `who am i|awk '{print $1}'` brew install git git-flow tig



}

############################################


function setup_mingw32(){

  echo
  echo "Setup under MINGW32..."
  echo

  git clone --recursive git://github.com/nvie/gitflow.git
  cd gitflow

  foundGit="false"
  drv=67
  while [ ${drv} -le 90 ]
  do
    DRV=`echo $drv | awk '{printf("%c\n", $0)}'`
    echo "Check \"${DRV}:\\Program Files (x86)\\Git\""
    if [ -d "/${DRV}/Program Files (x86)/Git" ]
    then
      foundGit="true"
      break
    fi
    drv=`expr ${drv} + 1`
  done

  if [ "${foundGit}" == "true" ]
  then
    echo "Found MSysGit at ${DRV}:"
    cmd.exe /c "contrib\\msysgit-install.cmd \"${DRV}:\\Program Files (x86)\\Git\""
  else
    quit "Not found MSysGit, please install it first, then run this script again."
  fi

}

##main##########################################
function main(){

  echo
  echo "=============================================="
  echo "Step 1. Check OS and Arch..."
  echo

  IS_ROOT=""
  #check user , must has root permission
  if [  $UID -eq 0 ]
  then
    # has root permisson
    echo "User `who am i | awk '{print $1}'` has root permission"
    IS_ROOT="1"
  else
    # hasn't root permisson
    echo "User `who am i | awk '{print $1}'` hasn't root permission"
    IS_ROOT="0"
  fi

  ##check system
  UNAME=`uname -a | awk 'BEGIN{FS="[_ ]"}{print $1}'`
  echo "You are using ${UNAME}"





  if [ "${UNAME}" == "Linux" ]
  then
   ##########Linux##########


    ##check distributor
    #DISTRIBUTOR=`lsb_release -a 2>/dev/null| grep "Distributor ID" | awk '{print $3}'`
    ##check os version
    #OSVERSION=`lsb_release -a | grep Release | awk 'BEGIN{FS="[:. \t]"}{print $3}' `
   #echo "Your OS : ${DISTRIBUTOR} ${OSVERSION}.x ${HOSTTYPE} "

    ALLOS=`cat /etc/*release | head -n 1`
    DISTRIBUTOR=`cat /etc/*release | head -n 1 | cut -d '=' -f 2| cut -d ' ' -f 1`
    OSVERSION=''

    echo "Your OS: ${ALLOS}"
    echo "Your DISTRIBUTOR: ${DISTRIBUTOR}"
    if [ "${DISTRIBUTOR}" == "CentOS" ]
    then
      echo "CentOS"
      OSVERSION=`lsb_release -a | grep Release | awk 'BEGIN{FS="[:. \t]"}{print $3}' `
      if [ ${OSVERSION} -ne 5 -a ${OSVERSION} -ne 6 ]
      then
          quit "Only support CentOS 5.x and CentOS 6.x,Quit!"
      fi
    elif [ "${DISTRIBUTOR}" == "Amazon" ]
    then
      echo "Amazon Linux"
    elif [ "${DISTRIBUTOR}" == "Ubuntu"  ]
    then
      echo "Ubuntu"
      OSVERSION=`lsb_release -a | grep Release | awk 'BEGIN{FS="[:. \t]"}{print $3}' `
      if [ ${OSVERSION} -ne 12 -a ${OSVERSION} -ne 11 ]
      then
                quit "Only support Ubuntu 11.x and Ubuntu 12.x,Quit!"
      fi
    else
      quit "Only support CentOS and Ubuntu,Quit!"
    fi

    ARCH=${HOSTTYPE}
    SUFFIX=""

    if [ "${HOSTTYPE}" == "x86_64" ]; then
      ARCH="x86_64"
    elif [ "${HOSTTYPE}" == "i686" -o  "${HOSTTYPE}" == "i386"  ]; then
      if [ "${OSVERSION}" == "5" ]
      then
          ARCH="i386"
      elif [ "${OSVERSION}" == "6" ]
      then
          ARCH="i686"
      fi
    fi

    if [ "${ARCH}" == "" ]
    then
      quit "${HOSTTYPE} unknown,exit!"
    fi

    case  "${OSVERSION}" in
     "5")
      SUFFIX="el${OSVERSION}.rf.${ARCH}"
      ;;
     "6")
      SUFFIX="el${OSVERSION}.rfx.${ARCH}"
      ;;
    esac

    echo ">>Pass check!"

    if [ "${DISTRIBUTOR}" == "CentOS" ]
    then
      #####CentOS#####
      setup_centos
    elif [ "${DISTRIBUTOR}" == "Amazon" ]
    then
      #####Amazon Linux as CentOS #####
      setup_centos
    else
      #####Ubuntu#####
      setup_ubuntu
    fi

  elif [ "${UNAME}" == "CYGWIN" ]
  then
    ##########Cygwin##########
    setup_cygwin

  elif [ "${UNAME}" == "Darwin" ]
  then
    ##########MacOSX##########
    setup_macosx

  elif [ "${UNAME}" == "MINGW32" ]
  then
    ##########MsysGit##########
    setup_mingw32

  else

     quit "This script do not support current system ${UNAME}"
  fi

  echo
  echo "Setup Complete"
  echo


  #######################################################################

  echo
  echo "=============================================="
  echo "Step 3. Now will install git flow ..."
  echo

  #wget --no-check-certificate -q -O - https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh |  bash
  curl -s https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh -o gitflow-installer.sh | bash
  if [ -f gitflow-installer.sh ]
  then
    chmod 755 gitflow-installer.sh
    ./gitflow-installer.sh
  else
    quit "Download git-flow failed,quit"
  fi

  if [ "${UNAME}" == "CYGWIN" ]
  then
    dos2unix /usr/local/bin/*
  fi

  echo
  echo "=============================================="
  echo "Step 4. Add /usr/local/bin to PATH"

  #create ~/.bashrc if not exist
  touch ~/.bashrc

   #remove old setting
   sed -i -e "/^GREEN/d"  ~/.bashrc
   sed -i -e "/^BLUE/d"  ~/.bashrc
   sed -i -e "/^WHITE/d"  ~/.bashrc
   sed -i -e "/^YELLOW/d"  ~/.bashrc
   sed -i -e "/^export PS1/d"  ~/.bashrc
   sed -i -e "/^PMT=/d"  ~/.bashrc
   sed -i -e "/^export PATH.*local/d" ~/.bashrc
   sed -i -e "/source .*bash_completion.*d.git/d"  ~/.bashrc
   sed -i -e "/source .*git-completion.bash/d"  ~/.bashrc


  if [ `cat ~/.bashrc | grep 'export PATH=/usr/local/bin:${PATH}' | wc -l`  -eq 0 ]
  then
    echo "" >> ~/.bashrc
    echo -e '\nexport PATH=/usr/local/bin:${PATH}\n' >> ~/.bashrc
    echo "" >> ~/.bashrc
    echo ">>Add 'export PATH=/usr/local/bin:\${PATH}' to ~/.bashrc OK!"
  else
    echo ">>Already add 'export PATH=/usr/local/bin:\${PATH}' to ~/.bashrc,nothing to do!"
  fi

  echo
  echo "=============================================="
  echo "Step 5. Modify shell prompt to show current branch"

  if [ `cat ~/.bashrc | grep "export PS1=.*git branch" | wc -l` -eq 0 ]
  then
    echo "" >> ~/.bashrc
    echo 'PMT=""; if [  $UID -eq 0 ];then PMT="#" ;else PMT="$" ; fi' >> ~/.bashrc
    echo 'WHITE="\[\033[0m\]" '>> ~/.bashrc
    echo 'YELLOW="\[\033[0;33m\]"' >> ~/.bashrc
    echo 'GREEN="\[\033[0;32;40m\]"' >> ~/.bashrc
    echo 'BLUE="\[\033[1;34m\]"' >> ~/.bashrc
    echo $'export PS1="[$GREEN\u@\h $BLUE\W$WHITE:$YELLOW\$(git branch 2>/dev/null | grep \'^*\' | colrm 1 2)$WHITE]"'"\$PMT " >> ~/.bashrc
    echo "" >> ~/.bashrc
    echo '>>Modify PS1 in ~/.bashrc OK!'
  else
    echo '>>Already modify PS1 in ~/.bashrc,nothing to do!'
  fi


  echo
  echo "=============================================="
  echo "Step 6. Now will modify environment to support bash auto-completion..."


  if [ "${UNAME}" == "Linux" ]
  then
    echo "Install auto-completion for Linux..."

    if [ `cat ~/.bashrc | grep 'source /etc/bash_completion.d/git' | wc -l`  -eq 0 ]
    then
      echo -e "\nsource /etc/bash_completion.d/git" >> ~/.bashrc
      echo "" >> ~/.bashrc
      echo ">>Add 'source /etc/bash_completion.d/git' to ~/.bashrc OK!"
    else
      echo ">>Already add 'source /etc/bash_completion.d/git' to ~/.bashrc,nothing to do!"
    fi

  elif [ "${UNAME}" == "Darwin" ]
  then
    #echo
    #echo ">>'/etc/bash_completion.d/git' not found! try get git-completion.bash now..."
    #echo

    echo "Install auto-completion for MacOSX..."

    ###for macosx
    curl -s https://github.com/git/git/raw/master/contrib/completion/git-completion.bash -OL
    if [ -f git-completion.bash ]
    then

      cp git-completion.bash ~/

      if [ `cat ~/.bashrc | grep 'source ~/git-completion.bash' | wc -l`  -eq 0 ]
      then
        echo -e "\nsource ~/git-completion.bash" >> ~/.bashrc
        echo "" >> ~/.bashrc
        echo ">>Add 'source ~/git-completion.bash' to ~/.bashrc OK!"
      else
        echo ">>Already add 'source ~/git-completion.bash' to ~/.bashrc,nothing to do!"
      fi
    else
      #
      echo
      echo "Sorry!Not support git auto-completion.Not found /etc/bash_completion.d/git or ~/git-completion.bash."
      echo
    fi

  else
     echo "Skip install auto-completion"

  fi




  echo
  echo "=============================================="
  echo "Step 7. Now will set git global config  ..."


  git config --global core.autocrlf input
  git config --global core.trustctime false
  git config --global core.filemode false

  git config --global color.ui true
  git config --global color.status auto
  git config --global color.diff auto
  git config --global color.branch auto
  git config --global color.interactive auto

  git config --global alias.st  'status'
  git config --global alias.ci  'commit'
  git config --global alias.co  'checkout'
  git config --global alias.br 'branch'
  git config --global alias.sr 'show-ref'
  git config --global alias.cm '!sh -c "br_name=`git symbolic-ref HEAD|sed s#refs/heads/##`; git commit -em \"[\${br_name}] \""'
  git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%x09%C(yellow)%d%Creset %C(cyan)[%an]%Creset %x09 %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"


  echo ">>Set global config OK, you can use 'git lg' to show log"


  ENDTIME=`date "+%Y-%m-%d %H:%M:%S"`

  echo "=============================================="
  echo
  echo "Start time: ${STARTTIME}"
  echo "End time:   ${ENDTIME}"
  echo
  echo "=============================================="
  echo "All be done,Please run 'source ~/.bashrc' or re-login"
  echo

}


#######################################
main