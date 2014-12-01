#!/bin/sh

# This script sets up a basic system needed for our analysis on the
# freshly created virtual machine. Besides the tools and libraries
# required by READemption it also installs some handy programs like
# tmux and htop. Additionally, it takes care of formating and mounting
# the attached storage as well as creating a non-root user.

main(){
    prepare_storage
    upgrade_and_install_packages
    generate_tmux_conf
    generate_profile
    install_segemehl
    install_deseq2
    install_reademption
    setup_non_root_user
}

prepare_storage(){
    sudo mkfs -t ext4 /dev/vdb
    sudo mkdir /data
    sudo mount /dev/vdb /data
    ln -s /data ~/data
}

upgrade_and_install_packages(){
    sudo apt-get update
    # sudo apt-get upgrade --assume-yes # not necessarily needed
    sudo apt-get install --assume-yes \
	htop make gcc-4.7-base build-essential \
	zlib1g-dev libncurses5-dev samtools bedtools \
	emacs msmtp python3-dev python3-setuptools \
	python3-pip cython3 python3-matplotlib cython3 \
	zlib1g-dev  make libncurses5-dev r-base \
	libxml2-dev tmux mosh git parallel tree
}

install_segemehl(){
    wget http://www.bioinf.uni-leipzig.de/Software/segemehl/segemehl_0_1_7.tar.gz
    tar xfz segemehl_0_1_7.tar.gz
    cd segemehl_0_1_7/segemehl/ && make && cd ../..
    sudo cp segemehl_0_1_7/segemehl/segemehl.x segemehl_0_1_7/segemehl/lack.x /usr/bin/
    rm -rf segemehl_0_1_7* segemehl_0_1_6*
}

install_deseq2(){
    sudo R --slave --vanilla --quiet --no-save << EOF
source("http://bioconductor.org/biocLite.R")
biocLite("DESeq2")
EOF
}

generate_tmux_conf(){
    echo unbind-key C-b >> ~/.tmux.conf
    echo set-option -g prefix C-o >> ~/.tmux.conf
}

install_reademption(){
    sudo pip3 install biopython
    sudo pip3 install pysam
    sudo pip3 install READemption
}

generate_profile(){
    echo alias em=\'/usr/bin/emacs -nw\' >> ~/.profile
    echo alias rm=\'rm -i\' >> ~/.profile
    echo alias d=\'du -sch\' >> ~/.profile
    echo "PATH=\$PATH:~/bin/" >> ~/.profile
}

setup_non_root_user(){
    USERNAME=demo
    adduser --disabled-password --gecos "" $USERNAME
    mkdir -p /home/${USERNAME}/.ssh
    cp -r \
	.profile \
	.tmux.conf \
	/home/${USERNAME}/
    cp -r \
	.ssh/authorized_keys \
	/home/${USERNAME}/.ssh/
    chown -R $USERNAME.$USERNAME /home/$USERNAME/
    ln -s /data /home/$USERNAME/data
    chown -R $USERNAME.$USERNAME /data/
}

main
