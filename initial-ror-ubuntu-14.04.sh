

linuxInstallVim() {
    sudo apt-get install vim-gnome
    # Install the "third party"
    sudo apt-get install ubuntu-restricted-extras   # have to confirm 
}


installDocker() {
    which wget
    #-------------------------------------------
    # Install Docker
    # https://docs.docker.com/installation/ubuntulinux/
    #-------------------------------------------
    wget -qO- https://get.docker.com/ | sh
    sudo start docker
    sudo docker run hello-world   # verify docker is isntalled correctly	
    #-------------------------------------------
    # Optional configurtion for Docker
    #-------------------------------------------
    # sudo /etc/init.d/docker status
    # create Docker group
    sudo usermod -aG docker kuntuzangpo   # after it log out, log in
    docker run hello-world
}


installRuby() {
    #------------------------------------------------------------------------
    # Setup Ruby on Rails on Ubuntu 14.04 Trusty Tahr
    # https://gorails.com/setup/ubuntu/14.04
    #------------------------------------------------------------------------

    # Pre-Install
    sudo apt-get update
    sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

    # Install RUBY     - Using rbenv (Recommended)
    #--------------------------------------------
    cd
    git clone git://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL

    git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

    rbenv install 2.2.2
    rbenv global 2.2.2
    ruby -v

    # Now we tell Rubygems not to instal the documentation for each package locally and then install Bundler
    #--------------------------------------------
    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
    gem install bundler
}


gitConfiguring() {
    # Configuring Git
    #--------------------------------------------
    git config --global color.ui true
    git config --global user.name "rudolfvavra"
    git config --global user.email "rudolfvavra@gmail.com"
    ssh-keygen -t rsa -C "rudolfvavra@gmail.com"

    # Take newly generated SSH and add it to your Github accout. 
    cat ~/.ssh/id_rsa.pub
"""
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0MrRxE2UvdR7xgH2J2d4Q/WTP91EcY758w+1wZYwbyNCWR/XjtCm7UxBDu/V3M2WN8XOMPPT5TBJxSajQnlgH999ZDNrmWAgIbRPwvZdcF4n8n19XoSWzkH6wUVF0MzaqghX7GBIw6RLplolwVoSmgijjiw5n4nPLCOiIqDthoTrw1cyqx1HLZQymh2unE66i8OnovtqGLcI73u21AXK3QXRuec1OM9DLhFFnueoGRqcfjIUaCEsNFYd16m4KY9N389IKWmHggu1sd6osmeM8zuhrHjAbdLf5Xouq/DmlWeVk3o55HQFd6AV4MQyG8PitbljR1laCxLWufNjrLRxb rudolfvavra@gmail.com
"""
    # go https://github.com/settings/ssh and "Add SSH key" name it as i want  
    ssh -T git@github.com                # check and see if it worked
    # Hi rudolfvavra! You've successfully authenticated, but GitHub does not provide shell access.
}

installRails() {
    # Installing Rails       4.2.1 Recommended
    #--------------------------------------------
    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install nodejs

    gem install rails -v 4.2.1
    rbenv rehash
    rails -v
    # Rails 4.2.1
}


postgresqlSettingUp() {
    # Setting up PostgreSQL       4.2.1 Recommended
    #--------------------------------------------
    sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install postgresql-common
    sudo apt-get install postgresql-9.3 libpq-dev

    # Posgres installation doesn't setup a user for me, i need to create a user with permission to create databases. 
    sudo -u postgres createuser ruda -s

    # If you would like to set a password for the user, you can do the following
    sudo -u postgres psql
	#postgres=# \password ruda
        # Enter new password: ruda      
        # \q                       # exit psql
}

railsCreateApp() { 
    # Final Steps      --> create rails app
    #--------------------------------------------
    rails new myapp -d postgresql
    cd myapp
    # If you setup MySQL or Postgres with a username/password, modify the
    # config/database.yml file to contain the username/password that you specified
"""
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: localhost

development:
  <<: *default
  database: myapp_development
  username: ruda
  password: ruda
"""
    # Create the database
    rake db:create

    rails server
    # http://localhost:3000
}

postgresqlHelp() {
    # PostgreSQL cmds
    #--------------------------------------------
    /etc/init.d/postgresql reload
    postgres=# \password
    postgres=# \password ruda
    postgres=# create user "ruda2" with password "ruda2"
}


phpPgAdmin() {
    # Install phpPgAdmin
    #--------------------------------------------
    sudo apt-get update
    sudo apt-get install postgresql postgresql-contrib phppgadmin
    sudo service apache2 start
    sudo vim /etc/apache2/conf.d/phppgadmin
	# order deny,allow
	# deny from all
	# allow from 127.0.0.0/255.0.0.0 ::1/128
	# allow from all

    # Configure the .htaccess Authentication
    sudo vim /etc/apache2/sites-enabled/000-default
"""
<Directory "/usr/share/phpPgAdmin">
        AuthUserFile /etc/phpPgAdmin/.htpasswd
        AuthName "Restricted Area"
        AuthType Basic
        require valid-user
</Directory>
"""
    sudo apt-get install apache2-utils
    sudo htpasswd -c /etc/phpPgAdmin/.htpasswd username
    sudo service apache2 restart
}








