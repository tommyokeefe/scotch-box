# -*- mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?("vagrant-triggers")
  raise 'vagrant-triggers is not installed. Please run "vagrant plugin install vagrant-triggers"'
end

Vagrant.configure("2") do |config|

  config.vm.box = "scotch/box"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.hostname = "scotchbox"
  config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"]

  config.vm.provision "shell", inline: <<-SHELL

    ## Add sites here
    DOMAINS=("examplesite1" "examplesite2")


    for ((i=0; i < ${#DOMAINS[@]}; i++)); do

      ## Current Domain
      DOMAIN=${DOMAINS[$i]}

      echo "Creating directory for $DOMAIN..."
      mkdir -p /var/www/$DOMAIN/public

      echo "Creating vhost config for $DOMAIN..."
      sudo cp /etc/apache2/sites-available/scotchbox.local.conf /etc/apache2/sites-available/$DOMAIN.local.conf

      echo "Updating vhost config for $DOMAIN..."
      sudo sed -i s,scotchbox.local,dev.$DOMAIN.com,g /etc/apache2/sites-available/$DOMAIN.local.conf
      sudo sed -i s,/var/www/public,/var/www/$DOMAIN/public,g /etc/apache2/sites-available/$DOMAIN.local.conf

      echo "Enabling $DOMAIN. Will probably tell you to restart Apache..."
      sudo a2ensite $DOMAIN.local.conf

      echo "So let's restart apache..."
      sudo service apache2 restart

    done

    ## Add composer to the PATH
    export PATH="~/.composer/vendor/bin:$PATH"

    ## Load databases
    for db in `ls /var/www/dumps`
    do
      IFS='.' read -a mydb <<< "$db"
      if [ "$db" != "readme.md" ]
      then
        echo "adding database for $db"
        mysql -u root -proot ${mydb[0]} < /var/www/dumps/$db
        echo "...done"
      fi
    done

  SHELL

  config.trigger.before :halt do
    run_remote  "bash /var/www/exportdb.sh"
  end

  config.trigger.before :destroy do
    run_remote  "bash /var/www/exportdb.sh"
  end

end
