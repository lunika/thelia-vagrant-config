# Basic Puppet manifest

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

class system-update {

    apt::source { 'ubuntu':
        location => 'http://archive.ubuntu.com/ubuntu',
        release => 'precise',
        repos => 'main universe multiverse restricted',
    }

    apt::source { 'ondrej-php5':
        location => 'http://ppa.launchpad.net/ondrej/php5/ubuntu',
        release => 'precise',
        repos => 'main',
    }

    apt::key { 'ondrej-php5':
        key => 'E5267A6C',
        key_server => 'keyserver.ubuntu.com',
    }

    # Exec['apt_update'] -> Package <||>

    exec { 'apt-get update':
        command => 'sudo apt-get update --fix-missing',
    }

    $sysPackages = [ "build-essential" ]
    package { $sysPackages:
        ensure => "installed",
        require => Exec['apt-get update'],
    }
}

class development {

  $devPackages = [ "curl", "git", "vim"]
  package { $devPackages:
    ensure => "latest",
    require => Exec['apt-get update'],
  }

}

class thelia {
    
    exec { 'git clone thelia ':
        command => 'git clone --recursive https://github.com/thelia/thelia.git /var/www/thelia',
        creates => '/var/www/thelia',
        require => Package["git"]
    }

    exec { 'install composer':
        command => 'curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/bin/composer',
        onlyif => 'test -e /var/www/thelia/composer.json'
    }

    exec { 'run composer for installing dependencies':
        command => 'composer install',
        cwd => '/var/www/thelia',
        timeout => 0,
        tries => 10,
        require => Exec["install composer"]
    }
}

class devbox_php {

    php::module { [ 'curl', 'gd', 'mcrypt', 'mysql', ]:
        require => Exec["apt-get update"],
        notify => Class['apache'] 
    }
    


    php::module { ['xdebug', ]:
        notify => Class['apache'],
        source => '/vagrant/conf/php/xdebug.ini'
    }
 
    
    php::conf { ['mysqli', 'pdo', 'pdo_mysql', ]:
        require => Package['php-mysql'],
        notify => Class['apache'],
    }

    file { "/etc/php5/conf.d/custom.ini":
        owner => root,
        group => root,
        mode => 664,
        source => "/vagrant/conf/php/custom.ini",
        notify => Class['apache'],
    }

    # PEAR Package
    pear::package { "PEAR": }

    # PHPUnit
    pear::package { "PHPUnit":
        version => "latest",
        repository => "pear.phpunit.de",
        require => Pear::Package["PEAR"],
    }

    # create apache vhost
    apache::vhost { "thelia":
        docroot     => "/var/www/thelia/web",
        server_name => "thelia.local",
        template    => 'apache/virtualhost/vhost.conf.erb'
    }

    package { "phpmyadmin":
        ensure      => "latest",
        require     => Exec["apt-get update"],
        notify      => Class['apache']
    }

    file { "/etc/apache2/conf.d/phpmyadmin.conf":
        ensure => "link",
        target => "/etc/phpmyadmin/apache.conf"
    }

}



class { 'apt':
  always_apt_update => true
}

class { "mysql":
  root_password => 'root',
}

Exec["apt-get update"] -> Package <||>

include system-update
include development

include apache
include mysql
include pear
include php::apache2
include devbox_php

# include phpqatools
include thelia
