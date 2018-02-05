#!/bin/bash

# #Parameters
rootPwd=$PWD
warPwd=$PWD/connectors

tag_name=$1

# 如果有tagName就會用tagName壓 Build包的 filanema 如 connector_install_v2.3.3 
# 沒有tagName 就會用日期壓，如connector_install_20170918
if [ -z $tag_name ]; then
    DATETIME=$(date +"%Y%m%d_%H%M%S")
else
    DATETIME=$tag_name
fi

function pull_git() {
    path=$1
    git_url=$2
    remote_name=$3
    branch_name=$4
    tag_name=$5

    if [ ! -d ./$path ]; then
        git clone $git_url
    fi

    echo $PWD
    pwd=$PWD
    cd $path
    echo $PWD

    git clean -f -d
    if [ -z $tag_name ]; then
        git reset -q HEAD --
        git checkout master

        git fetch --prune $remote_name
        git pull --no-edit $remote_name $branch_name
    else
        git reset -q HEAD --
        git checkout $tag_name
    fi

    cd $pwd
}

function build_war() {
    gitRepository=$1
    war_name=$2
    tag_name=$3

    cd $rootPwd
    filename="$(basename $gitRepository)"
    downloadDir=$rootPwd/"${filename%.*}"
    pull_git $downloadDir $gitRepository origin master $tag_name
    cd $downloadDir
    ant build-war
    cp $downloadDir/bin/$war_name $warPwd/$war_name
}

mkdir $warPwd

# build mobileIron
build_war "http://emmasvn.cmes.com.tw/gitlab/iScreen/mobileironConnector.git" "MobileIronConnector.war" $tag_name

#build tableau
build_war "http://emmasvn.cmes.com.tw/gitlab/iScreen/tableauConnector.git" "TableauConnector.war" $tag_name

#build attendance
build_war "http://emmasvn.cmes.com.tw/gitlab/iScreen/Attendance.git" "AttendanceConnector.war" $tag_name

#build mailMonitor 
build_war "http://emmasvn.cmes.com.tw/gitlab/iScreen/MailMonitorConnector.git" "MonitorConnector.war" $tag_name

#build nagios
build_war "http://emmasvn.cmes.com.tw/gitlab/iScreen/nagios-connector.git" "nagios-connector.war" $tag_name
cd $rootPwd
tar -zcf connectors_$DATETIME.tar.gz connectors