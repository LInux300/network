
#------------------------------------------------------------------------------
# Deploy Ubuntu
#------------------------------------------------------------------------------
https://gorails.com/deploy/ubuntu/16.04

# Deploy Ubuntu Initial ssh-copy-id
#------------------------------------------------------------------------------

#local
ssh root@81.2.254.221
# remote
exit

# local
ssh-copy-id
cat ~/.ssh/id_rsa.pub
ssh-copy-id root@81.2.254.221          # copy text from .ssh/id_rsa.pub, after no more user/pass 
ssh root@81.2.254.221

# remote
sudo adduser deploy
adduser deploy sudo                    # add deploy to sudo group
su deploy
sudo ls
exit
exit

#local
ssh-copy-id deploy@81.2.254.221
ssh deploy@81.2.254.221


# Deploy Ubuntu Install Ruby
#------------------------------------------------------------------------------

# remote
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev


# rbenv version
cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

rbenv install 2.3.0                             # it takes a lot of time !

# ls -la /home/deploy/.rbenv/versions/2.3.0/
# rbenv install -l                              # list of all versions
# ps aux

rbenv global -2.3.0
ruby -v

echo "gem: --no-document" > ~/.gemrc
gem install bundler

#gem install rails

rbenv rehash

# Deploy Ubuntu Install Nginx
#------------------------------------------------------------------------------
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add Passenger APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger & Nginx
sudo apt-get install -y nginx-extras passenger

sudo service nginx restart
sudo service nginx start
sudo service nginx stop

sudo vim /etc/nginx/nginx.conf
"""
        # change
        user www-data; --> user deploy;
        # add
        passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
        passenger_ruby /home/deploy/.rbenv/shims/ruby; # If you use rbenv
"""

sudo service nginx restart

# sudo tail /var/log/nginx/error.log

# Deploy Ubuntu Install PostgreSQL
#------------------------------------------------------------------------------

sudo apt-get install postgresql postgresql-contrib libpq-dev
# sudo service postgresql start

sudo su - postgres
createuser deploy --pwprompt
exit

# Deploy Ubuntu Install Capistrono
#------------------------------------------------------------------------------
vim Gemfile
"""
  # https://rubygems.org/search?utf8=%E2%9C%93&query=capistrano
  group :development do
    gem 'capistrano', '~> 3.5.0'
    gem 'capistrano-rails', '~> 1.1.6'
    gem 'capistrano-rbenv', github: "capistrano/rbenv"
  end
"""
# bundle install
bundle --binstubs
cap install STAGES=production

vim Capfile
"""
# add
require 'capistrano/rbenv'
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.3.0'

require 'capistrano/bundler'
require 'capistrano/rails'
"""

vim config/deploy.rb
"""
   # config valid only for current version of Capistrano
   lock '3.5.0'

   set :application, 'tibetan'
   set :repo_url, 'git@github.com:rudolfvavra/tibetan.git'

   set :deploy_to, '/home/deploy/tibetan'

   # not share files?dirs publickly
   set :linked_files, %w{config/database.yml config/secrets.yml}
   set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
"""

vim config/secrets.yml
"""
production:
  secret_key_base: <%= ENV['SECRET_KEY_BASE'] %>
"""

vim .gitignore
"""
config/secrets.yml
config/database.yml
"""

vim config/deploy/production.rb
"""
set :stage, :production

# Replace 127.0.0.1 with your server's IP address!
server '81.2.254.221', user: 'deploy', roles: %w{web app db}
"""

git add .
git commit -m "Add capistrano" 
git push

cap production deploy                    # have to fix all the errors


ssh deploy@81.2.254.221
cd tibetan/shared/config
touch database.yml
touch secrets.yml
vim secrets.yml
# rake secret                    # run from local rails app !!! to generate new secret key
"""
production:
  secret_key_base: <%= ENV['SECRET_KEY_BASE'] %>
"""

# local
vim Gemfile
"""
gem 'pg'
"""
bundle

# remote
vim database.yml
"""
production:
  adapter: postgresql
  database: tibetan_test
  username: deploy
  password: xxx
"""

sudo su
su postgres
psql
"""
create database tibetan_test with owner = deploy;
"""
\q
exit
su deploy
psql --user deploy --password tibetan_test
"""
# test database
"""



# remote
sudo apt-get install nodejs

# local
bundle exec cap production deploy





#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

Building your Application

Associated with job 'tibetan-build' in Jenkins server.

Jenkins created successfully.  Please make note of these credentials:

   User: admin
   Password: WSrg3h8ANXgx

Note:  You can change your password at: https://jenkins-vavra.rhcloud.com/me/configure

Your application is now building with Jenkins.
#------------------------------------------------------------------------------
# openshift
#------------------------------------------------------------------------------

# cmd
#------------------------------------------------------------------------------
rhc apps                   # list of my apps

# clone tibetan
git clone ssh://572341150c1e668b03000135@tibetan-vavra.rhcloud.com/~/git/tibetan.git/
$ git clone <git_url> <directory_to_create>

# Within your project directory
# Commit your changes and push to OpenShift

$ git commit -a -m 'Some commit message'
$ git push


# install
#------------------------------------------------------------------------------
# https://developers.openshift.com/getting-started/debian-ubuntu.html#client-tools
sudo apt-get install rhc

# check if its nesessary
sudo apt-get install ruby-full
ruby -e 'puts "Welcome to Ruby"'
sudo apt-get install rubygems
sudo apt-get install git-core
sudo gem install rhc
gem instal rhc
gem env
rhc setup


# links
#------------------------------------------------------------------------------
https://developers.openshift.com/getting-started/debian-ubuntu.html#client-tools

# hints
#------------------------------------------------------------------------------
gem regenerate_binstubs
gem pristine executable-hooks --version 1.3.2
ruby -e 'puts "Hello :-)"'
which rhc 
bundle update

https://gorails.com/setup/ubuntu/14.04

# Setting up Your Machine
#------------------------------------------------------------------------------
rhc setup


#------------------------------------------------------------------------------
# user add migration
#------------------------------------------------------------------------------

rails g migration AddFirstNameAndLastNameToUsers first_name:string last_name:string

#------------------------------------------------------------------------------
# Stripe & Devise
#------------------------------------------------------------------------------
https://www.youtube.com/watch?v=hyEsiwc0ys4
https://stripe.com/docs/checkout/tutorial


#gem file
gem stripe
bundle install

rails g migration AddSubsriberAndStripeIdToUsers subscribed:boolean stripeid
rake db:migrate
rake db:migrate RAILS_ENV="production" 

rails g controller subscribers
# in controller update action add token
# create strike accout 

http://localhost:3000/subscribers/new

# Create Environment Variable
# https://help.ubuntu.com/community/EnvironmentVariables
cd
vim .profile
export STRIPE_PUBLISHABLE_KEY='xxxx'
export STRIPE_SECRET_KEY='xxxx'

env | grep STRIPE                       # kontroluju jestli jsem nastavil enviromentalni promenou





pri prihlaseni
4242 4242 4242 4242    # test credit number



https://stripe.com/gb/pricing
https://stripe.com/ie/pricing


#------------------------------------------------------------------------------
# Devise Rails 
#------------------------------------------------------------------------------
http://jacopretorius.net/2014/03/adding-custom-fields-to-your-devise-user-model-in-rails-4.html


class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :tariff, :string
  end
end


#------------------------------------------------------------------------------
# Open Shift rupy app
#------------------------------------------------------------------------------
https://www.openshift.com/sites/default/files/documents/OpenShift_Online-2.0-User_Guide-en-US_5.pdf

https://openshift.redhat.com/app/console/application/572341150c1e668b03000135-tibetan/alias/www.tibmedicine.com/edit
Alias 'www.tibmedicine.com' from tibetan

To successfully use this alias, you must have an active CNAME record with your DNS provider. The alias is www.tibmedicine.com and the destination app is tibetan-vavra.rhcloud.com

Domain Name
www.tibmedicine.com → tibetan-vavra.rhcloud.com

If you need to change the domain name, please delete the alias and create a new one.
Delete Alias


#------------------------------------------------------------------------------
# Open Shift rupy app
#------------------------------------------------------------------------------
MySQL 5.5 database added.  Please make note of these credentials:

       Root User: adminT23yhDY
   Root Password: fge44fhiPlNP
   Database Name: tibetan

Connection URL: mysql://$OPENSHIFT_MYSQL_DB_HOST:$OPENSHIFT_MYSQL_DB_PORT/

You can manage your new MySQL database by also embedding phpmyadmin.
The phpmyadmin username and password will be the same as the MySQL credentials above.



Making code changes

Install the Git client for your operating system, and from your command line run

git clone ssh://572341150c1e668b03000135@tibetan-vavra.rhcloud.com/~/git/tibetan.git/
cd tibetan/

This will create a folder with the source code of your application. After making a change, add, commit, and push your changes.

git add .
git commit -m 'My changes'
git push

When you push changes the OpenShift server will report back its status on deploying your code. The server will run any of your configured deploy hooks and then restart the application.


#------------------------------------------------------------------------------
# README.md
#------------------------------------------------------------------------------
# RAILS_ENV=production rake secret
# pased generated string
# RAILS_ENV=production rake secret

RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake assets:clean assets:precompile

RAILS_ENV=production rails s
# or
rails server -e production



#------------------------------------------------------------------------------
# Hosting 
#------------------------------------------------------------------------------

support@hostingsolutions.cz


#------------------------------------------------------------------------------
# Development
#------------------------------------------------------------------------------
bin\rails s
rails s

#------------------------------------------------------------------------------
# Produkctni enviroment
# rails from development to production
#------------------------------------------------------------------------------
http://stackoverflow.com/questions/1949229/change-a-rails-application-to-production



#------------------------------------------------------------------------------
https://www.phusionpassenger.com/library/install/apache/install/oss/trusty/
#------------------------------------------------------------------------------
sudo apt-get update
sudo apt-get install -y libapache2-mod-passenger
sudo a2enmod passenger
# sudo /etc/init.d/apache2 reload
sudo /etc/init.d/apache2 restart

# check installation
sudo /usr/bin/passenger-config validate-install
sudo /usr/sbin/passenger-memory-stats

sudo apt-get update
$ sudo apt-get upgrade



Disable the default site, enable your new site, and restart Apache:

sudo a2dissite 000-default
sudo a2ensite tibetan
sudo /etc/init.d/apache2 restart

tail -200lf /var/log/apache2/error.log

#------------------------------------------------------------------------------

http://martin-denizet.com/install-redmine-2-5-x-git-subversion-ubuntu-14-04-apache2-rvm-passenger/

https://www.digitalocean.com/community/tutorials/how-to-setup-a-rails-4-app-with-apache-and-passenger-on-centos-6
# Step One - Apache Setup
yum install httpd
chkconfig httpd on





#------------------------------------------------------------------------------
# Production
#------------------------------------------------------------------------------
vim /config/environments/production.rb
config.serve_static_assets = true

rake db:create db:migrate RAILS_ENV=production
RAILS_ENV=production rake assets:precompile
RAILS_ENV=production rake db:seed
bundle install --deployment
rails s -e production



bundle exec rake assets:precompile
RAILS_ENV=production rake assets:clean assets:precompile

https://www.reinteractive.net/posts/116-12-tips-for-the-rails-asset-pipeline
#------------------------------------------------------------------------------



# help
rails s -e production -p 3001
RAILS_ENV=production rails server --binding=127.0.0.1:3000
tar -cvzf  tibmedicine.com-03.30.2016.tar.gz tibetan/
tail -300lf log/production.log 




bundle install --no-deployment
bundle update
bundle install --deployment

bundle install --without development test

bundle install --local              # only local gems

bin\rails s -e production
# RAILS_ENV=production rake assets:precompile
tar -cvzf  tibmedicine.com-03.30.2016.tar.gz tibetan/
tail -300lf log/production.log 
rake db:create db:migrate RAILS_ENV=production
RAILS_ENV=production rake assets:precompile
rake assets:precompile
rails s -e production
RAILS_ENV=production rake assets:precompile
# if db exists
rake db:migrate RAILS_ENV=production
#bundle exec rake db:migrate RAILS_ENV=production
# ?
vim /config/environments/production.rb
# ruda add end of file
config.serve_static_assets = true
# https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04
# test if production function
RAILS_ENV=production rails server --binding=server_public_IP
RAILS_ENV=production rails server --binding=127.0.0.1:3000





#------------------------------------------------------------------------------
# Mongo
#------------------------------------------------------------------------------

Configure Rails for MongoDB
In this section I’ll show you how to setup Mongoid to work with Rails and OpenShift.

First we’ll need to generate our database yaml file.

rails g mongoid:config

#------------------------------------------------------------------------------
# DB phpMyAdmin Hosting
#------------------------------------------------------------------------------
# tibetan_test =>
https://ppa.hostingsolutions.cz:8443/domains/databases/phpMyAdmin/index.php?pleskStartSession#PMAURL-0:index.php?db=&table=&server=1&target=&lang=en&token=4bc6cb0c5b336d7d75bdd47cd0fee976
#------------------------------------------------------------------------------
# Hosting
#------------------------------------------------------------------------------

Název subdomény *
 
development
 . tibmedicine.com

<BS>Nastavení hostingu
Document root *
  /  
development.tibmedicine.com
Cesta k root adresáři.

#------------------------------------------------------------------------------
# Tsa Lung
#------------------------------------------------------------------------------
Tsa-Lung comes from the Tantric yoga system of the ancient Tibetan and Indian masters.

According to the Tibetan teachings, there is, in addition to the physical body, also an energetic or subtle body that consists of energy channels. The channels (Tsa or Nadi) are used for circulating the subtle energy or winds (Lung or Prana) and the consciousness.

bower install c3 --save
#------------------------------------------------------------------------------
# healing
#------------------------------------------------------------------------------

rails generate controller imagination index
rails generate controller healing index
rails g scaffold prayer prayer:string messge:string user_id:integer answered:boolean


power of creative imagination

#------------------------------------------------------------------------------
# contact us
#------------------------------------------------------------------------------
rails g scaffold contact_us email:string messge:string user_id:integer answered:boolean

#------------------------------------------------------------------------------
# javascript json sorting 
#------------------------------------------------------------------------------

var homes = [{

   "h_id": "3",
   "city": "Dallas",
   "state": "TX",
   "zip": "75201",
   "price": "162500"

}, {

   "h_id": "4",
   "city": "Bevery Hills",
   "state": "CA",
   "zip": "90210",
   "price": "319250"

}, {

   "h_id": "5",
   "city": "New York",
   "state": "NY",
   "zip": "00010",
   "price": "962500"

}];

// Sort by price high to low
homes.sort(sort_by('price', true, parseInt));

// Sort by city, case-insensitive, A-Z
homes.sort(sort_by('city', false, function(a){return a.toUpperCase()}));
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
rails g scaffold survey_answer title:string topic:string answer:text user_id:integer


rails g scaffold recipe title:string cooking_time:string difficulty_level:string food_type_id:integer food_preference_id:integer cuisine_id:integer ingredients:text procedure:text


#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
query-interface-client
gem 'gon'
gem 'multi_json'
gem 'momentjs-rails'

gem 'unicorn'
gem 'unicorn-rails'

gem 'rs_paginator'
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
rails generate model Contact email_address:string message:text type:string user_id:integer

#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
rails generate controller dashboard index

#------------------------------------------------------------------------------
#slider
http://owlgraphic.com/owlcarousel/
bower install owl-carousel --save
#------------------------------------------------------------------------------
# d3pie default pie chart
#------------------------------------------------------------------------------
http://www.cssscript.com/fullscreen-3d-cube-slider-with-pure-css-css3/



# With javascript
    // multi_answers = JSON.parse(JSON.stringify(s.data));
# With jQuery
    multi_answers = $.parseJSON(JSON.stringify(s.data));

#------------------------------------------------------------------------------
# d3pie default pie chart
#------------------------------------------------------------------------------
function pieChartDefault(div_id, dataSet) {
  var pie = new d3pie(div_id, {
  	header: {
  		title: {
  			text:    "",
  			color:    "#333333",
  			fontSize: 18,
  			font:     "arial"
  		},
  		subtitle: {
  			color:    "#666666",
  			fontSize: 14,
  			font:     "arial"
  		},
  		location: "top-center",
  		titleSubtitlePadding: 8
  	},
  	footer: {
  		text: 	  "",
  		color:    "#666666",
  		fontSize: 14,
  		font:     "arial",
  		location: "left"
  	},
  	size: {
  		canvasHeight: 500,
  		canvasWidth: 500,
  		pieInnerRadius: 0,
  		pieOuterRadius: null
  	},
  	data: {
  		sortOrder: "none",
  		smallSegmentGrouping: {
  			enabled: false,
  			value: 1,
  			valueType: "percentage",
  			label: "Other",
  			color: "#cccccc"
  		},

  		// REQUIRED! This is where you enter your pie data; it needs to be an array of objects
  		// of this form: { label: "label", value: 1.5, color: "#000000" } - color is optional
  		content: []
  	},
  	labels: {
  		outer: {
  			format: "label",
        hideWhenLessThanPercentage: null,
        pieDistance: 10
  		},
  		inner: {
  			format: "percentage",
  			hideWhenLessThanPercentage: null
  		},
  		mainLabel: {
  			color: "#333333",
  			font: "arial",
  			fontSize: 10
  		},
  		percentage: {
  			color: "#dddddd",
  			font: "arial",
  			fontSize: 10,
  			decimalPlaces: 0
  		},
  		value: {
  			color: "#cccc44",
  			font: "arial",
  			fontSize: 10
  		},
  		lines: {
  			enabled: true,
  			style: "curved",
  			color: "segment" // "segment" or a hex color
  		}
  	},
  	effects: {
  		load: {
  			effect: "default", // none / default
  			speed: 1000
  		},
  		pullOutSegmentOnClick: {
  			effect: "bounce", // none / linear / bounce / elastic / back
  			speed: 300,
  			size: 10
  		},
  		highlightSegmentOnMouseover: true,
  		highlightLuminosity: -0.2
  	},
  	tooltips: {
  		enabled: false,
  		type: "placeholder", // caption|placeholder
  		string: "",
  		placeholderParser: null,
  		styles: {
  			fadeInSpeed: 250,
  			backgroundColor: "#000000",
  			backgroundOpacity: 0.5,
  			color: "#efefef",
  			borderRadius: 2,
  			font: "arial",
  			fontSize: 10,
  			padding: 4
  		}
  	},

  	misc: {
  		colors: {
  			background: null, // transparent
  			segments: [
  				"#2484c1", "#65a620", "#7b6888", "#a05d56", "#961a1a",
  				"#d8d23a", "#e98125", "#d0743c", "#635222", "#6ada6a",
  				"#0c6197", "#7d9058", "#207f33", "#44b9b0", "#bca44a",
  				"#e4a14b", "#a3acb2", "#8cc3e9", "#69a6f9", "#5b388f",
  				"#546e91", "#8bde95", "#d2ab58", "#273c71", "#98bf6e",
  				"#4daa4b", "#98abc5", "#cc1010", "#31383b", "#006391",
  				"#c2643f", "#b0a474", "#a5a39c", "#a9c2bc", "#22af8c",
  				"#7fcecf", "#987ac6", "#3d3b87", "#b77b1c", "#c9c2b6",
  				"#807ece", "#8db27c", "#be66a2", "#9ed3c6", "#00644b",
  				"#005064", "#77979f", "#77e079", "#9c73ab", "#1f79a7"
  			],
  			segmentStroke: "#ffffff"
  		},
  		gradient: {
  			enabled: false,
  			percentage: 95,
  			color: "#000000"
  		},
  		canvasPadding: {
  			top: 5,
  			right: 5,
  			bottom: 5,
  			left: 5
  		},
  		pieCenterOffset: {
  			x: 0,
  			y: 0
  		},
  		cssPrefix: null
  	},
  	callbacks: {
  		onload: null,
  		onMouseoverSegment: null,
  		onMouseoutSegment: null,
  		onClickSegment: null
  	}
  });
}


#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
$("#sidebar > ul > li > a").click(function(e) { 
      // Prevent a page reload when a link is pressed
    e.preventDefault(); 
      // Call the scroll function
    goToByScroll(this.id); 

#------------------------------------------------------------------------------
# open files chrom
#------------------------------------------------------------------------------

chromium-browser --allow-file-access-from-files
#------------------------------------------------------------------------------
# generate svg grapthick from word i give or as js library
#------------------------------------------------------------------------------
https://www.jasondavies.com/wordcloud/
https://github.com/jasondavies/d3-cloud

#------------------------------------------------------------------------------
# D3 libraries
#------------------------------------------------------------------------------


http://d3plus.org/examples/

https://github.com/jasondavies/d3-cloud
#------------------------------------------------------------------------------
# Nutrition
#------------------------------------------------------------------------------

rails generate controller nutrition index


#------------------------------------------------------------------------------
# d3
#------------------------------------------------------------------------------
# generator pie chart d3   !!!
http://d3pie.org/#generator-tooltips

bower install d3 --save
bower install d3pie --save


http://bl.ocks.org/mbostock/4063423

# examples
http://bl.ocks.org/mbostock


https://live.zoomdata.com/zoomdata/visualization?__target=embedded&key=52265abb6abdbcaa8c217789#51db7ad4e4b04caf9ab346db-51db7ad4e4b04caf9ab346d5

# collapsible tree
http://bl.ocks.org/mbostock/4339083

# code of tree
http://bl.ocks.org/mbostock/4347473
https://gist.github.com/mbostock/4339607
http://bl.ocks.org/mbostock/raw/4063550/flare.json
http://mbostock.github.io/d3/talk/20111018/tree.html
http://bl.ocks.org/mbostock/4339184
http://bl.ocks.org/mbostock/4063550


# circle packing
http://bl.ocks.org/mbostock/4063530



# zoonable view
http://bl.ocks.org/mbostock/7607535
http://bl.ocks.org/mbostock/4348373

# table
http://bl.ocks.org/mbostock/1005873

colapsive
http://bl.ocks.org/mbostock/4339083



# bower 
http://bower.io/search/?q=d3

#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

https://github.com/PolymerElements/neon-animation#demos
https://elements.polymer-project.org/elements/neon-animation?view=demo:demo/index.html&active=neon-animated-pages

! animation on load

#------------------------------------------------------------------------------
# Google graphic library
#------------------------------------------------------------------------------
https://libraries.io/bower/google-chart
#bower install google-chart --save
# the same like google-chart
bower install --save GoogleWebComponents/google-chart

#------------------------------------------------------------------------------
# foundation icon fonts
#------------------------------------------------------------------------------
# http://zurb.com/playground/foundation-icon-fonts-3
bower install foundation-icon-fonts --save

# application css
 *= require foundation-icon-fonts/foundation-icons
#------------------------------------------------------------------------------
# bower file
#------------------------------------------------------------------------------
# bower.json
{
  "name": "tibetan",
  "homepage": "https://github.com/rudolfvavra/tibetan",
  "authors": [
    "rudolfvavra <rudolfvavra@gmail.com>"
  ],
  "description": "The Tibetan",
  "main": "README",
  "moduleType": [
    "amd",
    "es6",
    "globals",
    "node",
    "yui"
  ],
  "keywords": [
    "The",
    "tibetan",
    "name",
    "prayers",
    "medicin",
    "info",
    "Bon"
  ],
  "license": "MIT",
  "ignore": [
    "**/.*",
    "node_modules",
    "bower_components",
    "vendor/assets/components",
    "test",
    "tests"
  ],
  "dependencies": {
    "amcharts3": "^3.19.2",
    "ammap3": "^3.19.2",
    "motion-ui": "^1.2.1",
    "foundation": "^5.5.3",
    "slick-carousel": "^1.5.9"
  }
}

# .bowerrc 
{
  "directory": "vendor/assets/components"
}


#------------------------------------------------------------------------------
# google search
#------------------------------------------------------------------------------
("Goa" OR "India") ("Gandhi", "Buddha")



////= require welcome
////= require motion-ui/motion-ui
////= require amcharts3/amcharts/amcharts
////= require ammap3/ammap/ammap




# tooltip TODO
http://www.cssscript.com/pure-html5-css3-animated-tooltip-library-tooltip-css/
http://www.cssscript.com/css-css3/






# http://www.cssmatic.com/box-shadow

#------------------------------------------------------------------------------
# JS LIbrary
#------------------------------------------------------------------------------
# http://speckyboy.com/2015/12/13/javascript-resources-2015/


conate.js   -> transform your icons with frendy animations
#http://bitshadow.github.io/iconate/


mojs.js -> add moving objects, like sphers, squeares
http://mojs.io/tutorials/easing/path-easing/

# add pop up navigations
http://kushagragour.in/lab/ctajs/


# for faster animations
http://smoothstate.com/
http://jankfree.org/

# sliders
http://meandmax.github.io/lory/
http://msurguy.github.io/background-blur/

https://github.com/whackashoe/antimoderate          # blurred micro images on the page while loading full sized images

http://vst.mn/selectordie/   # nice select
#------------------------------------------------------------------------------
# survey javascript 
#------------------------------------------------------------------------------

rails generate controller examination index

#------------------------------------------------------------------------------
# survey javascript 
#------------------------------------------------------------------------------
http://andrewtelnov.github.io/surveyjs/

survey.js - the JavaScript Survey Library.

Insert survey into your web site/page.
Make a survey that is a part of your web site
Set the ininitial data or change them on the fly
Create the content of your survey using JSON or pure JavaScript
The full set of JS events will help you fully control the proccess, for example change the question visibility on changing a data
Extend the library by adding new questions, validators and so on.
You will need several simple steps to introduce a survey into your web site.
Download survey.js library
Insert links on js and css files. Their size is about 55k.
<link href="css/survey.css" type="text/css" rel="stylesheet">
<script src="js/survey.min.js"></script>
Add a link to a KnockoutJS. It is a MVVM library. The file size is about 50k.
<script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.3.0/knockout-min.js"></script>
Create a survey object.
var survey = new Survey.Survey({title: "Simple survey example",
                triggers: [{ type: "visible", name: "used", operator: "eq", value: "Yes", questions: ["solution"] }],
                questions: [
                    { type: "radiogroup", name: "used", title: "Have you been running a survey on your site(s)?", isRequired: true,
                    choices: ["Yes", "No"]},
                    { type: "checkbox", name: "solution", title: "What do you use to run survey?",
                        visible: false, isRequired: true, hasOther: true,
                        choices: ["custom|Custom solution", "Survey Monkey", "Survey Gizmo"]},
                    { type: "comment", name: "description", title: "Please tell us, what do you need from a Survey Library?" }]
}, "surveyContainer");
You have to pass to the constructor or render function, a JSON object and html element (or it's id). JSON object should contains the full information to allow create a Survey on the client. You may use the Survey JSON Builder to create a JSON for your Survey.
Use onComplete event to get the result of a Survey and send it to a server. In this example, the dxSurvey.com service is used.
survey.onComplete.add(function (s) {
    document.getElementById("surveyContainer").innerHTML = "The survey result: " + JSON.stringify(s.data);
    s.sendResult('e544a02f-7fff-4ffb-b62d-6a9aa16efd7c');
});
survey.onSendResult.add(function(s, options) {
    if(options.success) {
        s.getResult('d72c2b05-2449-4838-99b2-c3f0ec76da7a', 'solution');
    }
});
 
survey.onGetResult.add(function(s, options) {
    if(options.success) {
        showChart(options.dataList);
    }
});

#------------------------------------------------------------------------------
# from screch
#------------------------------------------------------------------------------
rake db:drop
rake db:create
rake db:migrate
rake db:seed



#------------------------------------------------------------------------------
# layout
#------------------------------------------------------------------------------
# encoding: UTF-8
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<% = render "/refinery/html_tag" %>
<%- site_bar = render('/refinery/site_bar', :head => true) %>
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  <title> <%=  content_for?(:title) ? yield(:title) : "Tibetan" %> Survey: <%= controller.action_name %></title>

  <%= stylesheet_link_tag "application" %>
  <%= javascript_include_tag "application", "data-turbolinks-track" => true %>
  <%= csrf_meta_tag %>
  <%= render "/refinery/head" %>

  <%= surveyor_includes %>
</head>
<body>
  <% -if admin_signed_in?
    = site_bar %>
  <br/>
  <div id="page_container">
    <header id="header">
      <%= render "welcome/slider_top" %>
    </header>
    <section id="pagess">
      <div class='row' >
        <%= yield %>
      </div>
      <footer class="footer">
        <%= render "/refinery/footer" %>
      <footer/>

  </div>
  <%= render "/refinery/javascripts" %>
</body>
</html>










a href='/surveys' = t('view.top_nav.first')


+.row.text-center.max-height-multislider

#------------------------------------------------------------------------------
# DSL
#------------------------------------------------------------------------------
http://www.sinatrarb.com/about.html
https://travis-ci.org/



#------------------------------------------------------------------------------
# rails help
#------------------------------------------------------------------------------
gem 'library', '~> 2.2'
which is shorthand for
gem 'library', '>= 2.2.0', '< 3.0'
#------------------------------------------------------------------------------
# Install gem from environment
#------------------------------------------------------------------------------
# in environment.rb
config.gem "surveyor", :version => '~> 0.10.0', :source => 'http://gemcutter.org'

rake gems:install

#------------------------------------------------------------------------------
# TEST
#------------------------------------------------------------------------------
rake test


#------------------------------------------------------------------------------
# online store
#------------------------------------------------------------------------------
# http://www.sitepoint.com/build-online-store-rails/

Foundation to design responsive pages
Redis to store shopping cart items quickly in memory
Braintree to accept payments and provide premium plan subscriptions.


#------------------------------------------------------------------------------
# Add a default role to a User DEVISE
#------------------------------------------------------------------------------
# https://github.com/plataformatec/devise/wiki/How-To:-Add-an-Admin-Role
rails generate devise Admin
vim db/migrate/20160227093118_devise_create_admins.rb
rake db:migrate


# another links
https://github.com/plataformatec/devise/wiki/How-To:-Add-a-default-role-to-a-User

#------------------------------------------------------------------------------
# pip
#------------------------------------------------------------------------------
apt-get -y install python-pip


#------------------------------------------------------------------------------
# Stem
#------------------------------------------------------------------------------
# https://stem.torproject.org/download.html

% sudo easy_install pip
% sudo pip install stem

#------------------------------------------------------------------------------
# Tor
#------------------------------------------------------------------------------

 sudo add-apt-repository ppa:webupd8team/tor-browser
 sudo apt-get update
 sudo apt-get install tor-browser
#------------------------------------------------------------------------------
# Pundit
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Git branch
#------------------------------------------------------------------------------

git checkout -b development
# create remove branch from new local development branch
git push --set-upstream origin development


#------------------------------------------------------------------------------
# Devise
#------------------------------------------------------------------------------
# https://github.com/plataformatec/devise

gem 'devise'
rails generate devise:install
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. If you are deploying on Heroku with Rails 3.2 only, you may want to set:

       config.assets.initialize_on_precompile = false

     On config/application.rb forcing your application to not access the DB
     or load models when precompiling your assets.

  5. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================
# do settings

#rails generate devise MODEL -> MODEL can be any name, but after not current_user, but current_member
rails generate devise User

# how to work with it

rails g devise:views
# rails generate devise:views users
# rails generate devise:views -v registrations confirmations


# helpers
before_action :authenticate_user!
user_signed_in?
current_user
user_session


rails generate devise:controllers [scope]





# http://blog.zedroot.org/rails-devise-working-with-multiple-models/
How to use devise_group
In my case I need this group all the time so I'm adding this to the ApplicationController:

class ApplicationController < ActionController::Base  
  protect_from_forgery with: :exception
  devise_group :person, contains: [:user, :admin]
  before_action :authenticate_person! # Ensure someone is logged in
end  
Now I can use everywhere in my application current_person where the code is common to the User and Admin classes. 
I can still use current_user and current_admin which is cool.


#------------------------------------------------------------------------------
confirmable – Users will have to confirm their e-mails after registration before being allowed to sign in.
lockable – Users’ accounts will be locked out after a number of unsuccessful authentication attempts.

model/users.rb
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

#------------------------------------------------------------------------------
# Rails MySql2
#------------------------------------------------------------------------------
# https://rubygems.org/gems/mysql2
# Mysql
# gem 'mysql2', '~> 0.4.3'     # --> new version doesn't work with activeRecords
gem 'mysql2', '~> 0.3.13'
bundle install
rake db:create
rake db:migrate
rake db:seed
rails s
------------------------------------------------------------------------------
# Open Shift rupy app

development: &development
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: root
  password: root
  socket: /var/run/mysqld/mysqld.sock
  database: <%= Rails.application.engine_name.gsub(/_application/,'').downcase %>_development

test: &test
  adapter: mysql2
  host: localhost
  username: root
  password: root
  database: <%= Rails.application.engine_name.gsub(/_application/,'').downcase %>_test

production: &production
  adapter: mysql2
  host: localhost
  database: <%= Rails.application.engine_name.gsub(/_application/,'').downcase %>_production
  username: your_production_database_login
  password: your_production_database_password


#------------------------------------------------------------------------------
# MySql
#------------------------------------------------------------------------------

# https://www.digitalocean.com/community/tutorials/how-to-use-mysql-with-your-ruby-on-rails-application-on-ubuntu-14-04
sudo apt-get install mysql-server mysql-client libmysqlclient-dev
# directory structure where it will store its information
sudo mysql_install_db
sudo mysql_secure_installation

sudo /etc/init.d/mysql start

#------------------------------------------------------------------------------
# Adminer
#------------------------------------------------------------------------------
sudo apt-get install adminer
sudo service apache2 restart
http://[SERVER_IP]/adminer.php

# maybe with it 
# manualy make symlink 
$ sudo ln -s /etc/apache2/conf-available/adminer.conf /etc/adminer/apache.conf
# enable this conf
$ sudo a2enconf adminer.conf
$ sudo service apache2 reload

# https://www.vultr.com/docs/install-adminer-on-debian-ubuntu

#------------------------------------------------------------------------------
# Survey
#------------------------------------------------------------------------------
# https://github.com/runtimerevolution/survey
https://github.com/runtimerevolution/survey-demo/tree/master/app/assets
http://survey-demo.herokuapp.com/
gem "survey", "~> 0.1"  

# Rapidfire
https://github.com/code-mancers/rapidfire
gem 'rapidfire'

https://github.com/NUBIC/surveyor
gem "surveyor"
#------------------------------------------------------------------------------
# Surveyor
#------------------------------------------------------------------------------
 *= require surveyor/reset
 *= require surveyor/jquery-ui-1.10.0.custom
 *= require surveyor/jquery-ui-timepicker-addon
 *= require surveyor/ui.slider.extras
 *= require surveyor/results
 *= require surveyor
 *= require custom



http://www.rubydoc.info/gems/surveyor/1.4.0

 1422  bundle install
 1423  script/rails generate surveyor:install
 1424  rails generate surveyor:install
 1425  bundle update
 1426  rails generate surveyor:install
 1427  git status/survey
 1428  spring stop
 1429  spring start
 1430  rails generate surveyor:install
 1431  bundle exec rake db:migrate
 1432  bundle exec rake surveyor FILE=surveys/kitchen_sink_survey.rb
 1433  rails s
 1434  rails generate surveyor:custom
 1435  rails s


# example with users
https://github.com/diasks2/surveyor_example`


https://github.com/NUBIC/surveyor/blob/master/lib/generators/surveyor/templates/surveys/kitchen_sink_survey.rb


https://github.com/kjayma/surveyor_gui

#------------------------------------------------------------------------------
# Therubyracer 
#------------------------------------------------------------------------------
http://www.rubydoc.info/gems/therubyracer/0.12.2#FEATURES
https://github.com/cowboyd/therubyracer

# with ruby
gem install therubyracer
require 'v8'

#rails
gem "therubyracer"

cxt = V8::Context.new
cxt.eval('7 * 6') #=> 42

truthy = val[:isTruthy] #=> V8::Function
truthy.call(' ') #=> true
truthy.call(0) #=> false


cxt['foo'] = "bar"
cxt.eval('foo') # => "bar"

class MyMath
  def plus(lhs, rhs)
    lhs + rhs
  end
end

cxt['math'] = MyMath.new
cxt.eval("math.plus(20,22)") #=> 42

# different ways of loading JavaScript source
File.open("mysource.js") do |file|
  cxt.eval(file, "mysource.js")
end
# or
cxt.load("mysource.js")

#------------------------------------------------------------------------------
# Refinery Create Add Own Extensions
#------------------------------------------------------------------------------
# generate extension
# http://www.refinerycms.com/guides/multiple-resources-in-an-extension




#------------------------------------------------------------------------------ 
# Refinery NEWS
#------------------------------------------------------------------------------ 
gem "refinerycms-news", '~> 2.1.0'


#------------------------------------------------------------------------------ 
# Slick
#------------------------------------------------------------------------------ 
bower install --save slick-carousel

# http://kenwheeler.github.io/slick/



// $('.slick-dots button').remove();
// $('.slick-dots li:nth-child(1)').append('<div class="btn btn-slider">First</div>');
// $('.slick-dots li:nth-child(2)').append('<div class="btn btn-slider">Second</div>');
// $('.slick-dots li:nth-child(3)').append('<div class="btn btn-slider">Third</div>');



#------------------------------------------------------------------------------ 
     <%= link_to image_tag( "logo.jpg" ), refinery.root_path, width: 10, height: 25 %>





    .row
      .callout.large
        .row.text-center
          h1 Changing the World Through Design
          p.lead Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam in dui mauris.
          a.button.large href="#"  Learn More
          a.button.large.hollow href="#"  Learn Less
    .row
      .medium-6.columns.medium-push-6
        img.thumbnail src="http://placehold.it/750x350" /
      .medium-6.columns.medium-pull-6
        h2 Our Agency, our selves.
        p Vivamus luctus urna sed urna ultricies ac tempor dui sagittis. In condimentum facilisis porta. Sed nec diam eu diam mattis viverra. Nulla fringilla, orci ac euismod semper, magna diam porttitor mauris, quis sollicitudin sapien justo in libero. Vestibulum mollis mauris enim. Morbi euismod magna ac lorem rutrum elementum. Donec viverra auctor.
    .row
      .medium-4.columns
        h3 Photoshop
        p Vivamus luctus urna sed urna ultricies ac tempor dui sagittis. In condimentum facilisis porta. Sed nec diam eu diam mattis viverra. Nulla fringilla, orci ac euismod semper, magna.
      .medium-4.columns
        h3 Javascript
        p Vivamus luctus urna sed urna ultricies ac tempor dui sagittis. In condimentum facilisis porta. Sed nec diam eu diam mattis viverra. Nulla fringilla, orci ac euismod semper, magna.
      .medium-4.columns
        h3 Marketing
        p Vivamus luctus urna sed urna ultricies ac tempor dui sagittis. In condimentum facilisis porta. Sed nec diam eu diam mattis viverra. Nulla fringilla, orci ac euismod semper, magna.
    hr/
    .row.column
      h3 Our Recent Work
    .row.medium-up-3.large-up-4
      .column
        img.thumbnail src="http://placehold.it/300x300" /
      .column
        img.thumbnail src="http://placehold.it/550x550" /
      .column
        img.thumbnail src="http://placehold.it/550x550" /
      .column
        img.thumbnail src="http://placehold.it/550x550" /
    hr/
    .row.column
      ul.menu
        li
          a href="#"  One
        li
          a href="#"  Two
        li
          a href="#"  Three
        li
          a href="#"  Four
    script src="https://code.jquery.com/jquery-2.1.4.min.js" 
    script src="http://dhbhdrzi4tiry.cloudfront.net/cdn/sites/foundation.js" 
    javascript:
      | $(document).foundation();
    script src="https://intercom.zurb.com/scripts/zcom.js" type="text/javascript" 



#------------------------------------------------------------------------------
# Foundation documentation localy
#------------------------------------------------------------------------------
### View documentation locally

You'll want to clone the Foundation repo first and install all the dependencies. You can do this using the following commands:

```
git clone git@github.com:zurb/foundation.git
cd foundation
npm install -g grunt-cli bower
npm install
bower install
bundle install
```

Then just run `grunt build` and the documentation will be compiled:

#------------------------------------------------------------------------------
# SCSS sass
#------------------------------------------------------------------------------
http://sass-lang.com/guide

$font-stack:    Helvetica, sans-serif;
$primary-color: #333;

body {
  font: 100% $font-stack;
  color: $primary-color;
}



@import 'util/util';

// 1. Global
// ---------

$global-font-size: 100%;
$global-width: rem-calc(1200);
$global-lineheight: 1.5;


$header-sizes: (
  small: (
    'h1': 24,
    'h2': 20,
    'h3': 19,
    'h4': 18,
    'h5': 17,
    'h6': 16,
  ),
  medium: (
    'h1': 48,
    'h2': 40,
    'h3': 31,
    'h4': 25,
    'h5': 20,
    'h6': 16,
  ),
);
$header-color: inherit;
$header-lineheight: 1.4;



#------------------------------------------------------------------------------
# jQuery
#------------------------------------------------------------------------------
# https://github.com/rails/jquery-rails

For jQuery UI, we recommend the jquery-ui-rails gem, as it includes the jquery-ui css and allows easier customization.


#------------------------------------------------------------------------------
# Angular
#------------------------------------------------------------------------------
# add to bower

  "dependencies": {
    "angular": "~1.2.16",
    "amcharts3": "^3.19.2"
  }



#------------------------------------------------------------------------------
# AmCharts
#------------------------------------------------------------------------------
# https://www.amcharts.com/download/

bower install ammap3  --save




#------------------------------------------------------------------------------

ERROR: /usr/bin/env: node: No such file or directory
#------------------------------------------------------------------------------

sudo ln -s "$(which nodejs)" /usr/bin/node


#------------------------------------------------------------------------------
# Bower
#------------------------------------------------------------------------------
# http://dotwell.io/taking-advantage-of-bower-in-your-rails-4-app/
sudo npm install -g bower

vim .bowerrc
mkdir vendor/assets/components
bower init
bower install
bower install amcharts3 --save

# Create a bower.json file for your package with bower init.
# Then save new dependencies to your bower.json with bower install PACKAGE --save

vim /config/application.rb

#------------------------------------------------------------------------------
# Sass
#------------------------------------------------------------------------------
npm start to run the Sass compiler. It will re-run every time you save a Sass file.



#------------------------------------------------------------------------------
doctype html
= render "/refinery/html_tag"
  = site_bar = render('/refinery/site_bar', :head => true)
  head
    = render "/refinery/head"
    
  body id="<%= canonical_id @page %>">
    p= 'fsd'
    = site_bar
    div id="page_container"
      header id="header"
        = render "/refinery/header"
      section id="page"
        == yield
      footer
        = render "/refinery/footer"
      
      
    = render "/refinery/javascripts"



#------------------------------------------------------------------------------
# Layout
#------------------------------------------------------------------------------

rake refinery:override view=refinery/_footer.html
rake refinery:override view=refinery/pages/show
rake refinery:override view=refinery/pages/home


rake refinery:override view=refinery/_site_bar
rake refinery:override view=refinery/_content_page
rake refinery:override view=refinery/_menu
rake refinery:override view=refinery/_head
rake refinery:override view=refinery/_footer 

#------------------------------------------------------------------------------
<!DOCTYPE html>
<%= render "/refinery/html_tag" %>
  <% site_bar = render('/refinery/site_bar', :head => true) -%>
  <head>
    <%= render "/refinery/head" %>
  </head>
  <body id="<%= canonical_id @page %>">
    <%= site_bar -%>
    <div id="page_container">
      <header id="header">
        <%= render "/refinery/header" -%>
      </header>
      <section id="page">
        <%= yield %>
      </section>
      <footer>
        <%= render "/refinery/footer" -%>
      </footer>
    </div>
    <%= render "/refinery/javascripts" %>
  </body>
</html>



#------------------------------------------------------------------------------
# Rafinery
#------------------------------------------------------------------------------
rake refinery:override view=layouts/application



# http://www.refinerycms.com/guides/getting-started
# http://www.refinerycms.com/guides/with-an-existing-rails-app

rails generate refinery:cms --fresh-installation
vim config/initializers/refinery/core.rb   
  # config.mounted_path = "/subfolder"
  # config.site_name = 'Tibetan'

# You can create the initial admin user by visiting localhost:3000/subfolder/refinery


# Overriding your first view
$ rake refinery:override view=refinery/pages/show
    create  app/views/refinery/pages/show.html.erb


# Generate en Extension to User YOur Own MVCs
#------------------------------------------------------------------------------
field type 	description
text          	a multiline visual editor
resource 	a link which pops open a dialog which allows the user to select an existing file or upload a new one
image 	        a link which pops open a dialog which allows the user to select an existing image or upload a new one
string and integer 	a standard single line text input

rails generate refinery:engine singular_model_name attribute:type [attribute:type ...]
rails generate refinery:engine event title:string date:datetime photo:image blurb:text
rails g refinery:engine   # to see all the options supported

# Update
#------------------------------------------------------------------------------
rails generate refinery:cms --update
rake db:migrate
bundle install

#------------------------------------------------------------------------------
git clone git@github.com:rudolfvavra/tibetan.git


vim config/secrets.yml
rake secret                  # generate code for secrets.yml


rails generate controller welcome index


# Slim 
gem "slim-rails"
# https://rubygems.org/gems/refinerycms
gem 'refinerycms', '~> 3.0', '>= 3.0.1'
# https://rubygems.org/gems/activemerchant
gem 'activemerchant', '~> 1.57'


Edit: we have decided on using Comfortable Mexican Sofa and extend it to the point where it integrates with Spree and other apps through Devise. Thanks everyone for the answers!


#------------------------------------------------------------------------------
# Refinery help pages
#------------------------------------------------------------------------------
http://www.sitepoint.com/working-with-refinery/
https://groups.google.com/forum/?fromgroups=#!forum/refinery-cms


# Video, movie
https://firebearstudio.com/blog/best-ruby-on-rails-content-management-systems-cms.html



# override layout
#------------------------------------------------------------------------------
$ rake refinery:override view=refinery/pages/show
$ rake refinery:override view=refinery/pages/home
#------------------------------------------------------------------------------
# Design FOUNDATION OK
#------------------------------------------------------------------------------
http://foundation.zurb.com/learn/tutorials.html
Zurb Foundation
http://foundation.zurb.com/sites/download/

http://blog.milkfarmproductions.com/post/73806803072/refinery-cms-and-zurb-foundation-5

$ gem 'foundation-rails'
bundle
rails g foundation:install


# INSTALL MOTION UI FOUNDATION
#------------------------------------------------------------------------------
# https://github.com/zurb/motion-ui/blob/master/docs/installation.md
#https://github.com/zurb/motion-ui/tree/master/docs
# 

# app/assets/stylesheets/foundation_and_overrides.scss
@import 'motion-ui/motion-ui';
@include motion-ui-transitions;
@include motion-ui-animations;

#npm install motion-ui
bower install motion-ui --save


# TEMPLATE
sudo npm install -g foundation-cli
#sudo npm install --global foundation-cli












rails g foundation:install [layout_name] [options]

Options:
  [--haml]  # Generate HAML layout instead of erb
  [--slim]  # Generate Slim layout instead of erb
Runtime options:
  -f, [--force]    # Overwrite files that already exist
  -p, [--pretend]  # Run but do not make any changes
  -q, [--quiet]    # Suppress status output
  -s, [--skip]     # Skip files that already exist

#------------------------------------------------------------------------------
# Refinery blog
#------------------------------------------------------------------------------
gem ‘refinerycms-blog’, :git => ‘git://github.com/resolve/refinerycms-blog.git’, :branch => ‘rails-3-1’ - See more at: http://blog.flatironschool.com/build-a-blog-based-site-with-refinerycms/#sthash.Tqoj4lqt.dpuf

rails g refinery:blog
rake db:migrate


http://blog.flatironschool.com/build-a-blog-based-site-with-refinerycms/
#------------------------------------------------------------------------------
# Instalation
#------------------------------------------------------------------------------
sudo apt-get install ruby rubygems
# SQLite
sudo apt-get install sqlite3 libsqlite3-dev
# MySql
sudo apt-get install mysql-client mysql-server libmysqlclient-dev
# Image
sudo apt-get install imagemagick


sudo apt-get install nodejs
sudo apt-get install chromium-browser
#------------------------------------------------------------------------------
# install RVM
#------------------------------------------------------------------------------
sudo apt-get update
sudo apt-get install curl

# The Quick Way
# https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-on-ubuntu-14-04-using-rvm
# https://rvm.io/rvm/install
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --rails
source ~/.rvm/scripts/rvm


# Working
rvm install ruby_version
rvm list
rvm list known
rvm usr ruby_version


#------------------------------------------------------------------------------

rails generate controller welcome index


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.




#------------------------------------------------------------------------------
# PRAWN   
#------------------------------------------------------------------------------
gem install prawn
http://www.sitepoint.com/hackable-pdf-typesetting-in-ruby-with-prawn/?utm_source=sitepoint&utm_medium=nextpost&utm_term=ruby

Prawn is the spiritual successor to PDF::Writer. It is currently well-maintained and, like many other Ruby projects, Prawn is intended as a platform on which tools can be built.


