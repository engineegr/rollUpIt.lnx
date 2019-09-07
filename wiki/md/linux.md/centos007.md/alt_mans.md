### Alternative mans
---------------------
>[Note!]
> From [here](https://www.ostechnix.com/3-good-alternatives-man-pages-every-linux-user-know/)

1. ##### [Bropages](http://bropages.org/):

    1. Installation:

            sduo yum install -y ruby ruby-devel rubygems gcc-c++
            sudo gem install bropages

    2. Usage:
        
            bro <command>

2. ##### [Mainly](https://github.com/carlbordum/manly)

    1. Installation:

            sudo yum -y groupinstall development
            sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
            sudo yum -y install python36u
            sudo yum -y install python36u-pip

    >[Note!]
    > *PIP*, the python package manager, is used to install, upgrade, remove packages written in Python programming language. 
    
            sudo pip3.6 install --user manly

    2. Usage:

            mainly dpkg -i -R # it describes how to use flags only (ssh -l and etc)
