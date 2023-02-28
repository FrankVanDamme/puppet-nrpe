# grotendeels gepikt van https://github.com/brightbox/puppet/blob/master/modules/nagios/manifests/init.pp


class nrpe(
    $allowed_hosts = [], 
    $command_timeout = 60,
    $packages=$nrpe::params::packages,
    $pid_file=$nrpe::params::pid_file,
    $config_dir=$nrpe::params::config_dir,
    Hash $configs = {},
    ) inherits nrpe::params {

    tag("nrpe")
    # "nagios-plugins-extra",  -> enkel in ubuntu
    package { $::nrpe::params::packages:
        ensure => latest,
    }
    file { "/etc/nagios/nrpe.d":
        ensure => directory,
        require => Package[$nrpe::params::packages],
    }

# dit vind ik vuil aanvoelen

  exec { "nrpe-config":
    # command => "/bin/cat /etc/nagios/nrpe.d/* > /etc/nagios/nrpe_puppet.cfg",
    command => "/bin/true",
    notify => Service[$nrpe::params::service],
    require => Package[$nrpe::params::packages],
    refreshonly => true
  }
  file { "/etc/nagios/nrpe.cfg":
    content => template("nrpe/nrpe.cfg.erb"),
    require => Package[$nrpe::params::packages],
    notify => Service[$nrpe::params::service],
    mode => '640',
    owner => root,
    group => $nrpe::params::nrpe_user
  }

  ## system service, including override for systemd - 
  ## allows monitoring partitions under /tmp or /var/tmp

  if ( $facts[os][family] == "Debian" ){
    file { "/etc/systemd/system/${nrpe::params::service}.service.d":
      ensure => directory,
    }
    ->
    file { "nrpe_systemd_override":
      path    => "/etc/systemd/system/${nrpe::params::service}.service.d/override.conf",
      ensure  => present,
      content => template("nrpe/nrpe.systemd_override.erb"),
      before  => Service[$nrpe::params::service],
    }
    ~>
    exec { "nrpe_wrapper_refresh_systemd":
      command     => "/bin/systemctl daemon-reload",
      refreshonly => true,
      notify      => Service[$nrpe::params::service],
    }
  }

  service { $nrpe::params::service:
    ensure => true,
    enable => true,
    hasstatus => false,
    pattern => "nrpe",
    require => [Package[$nrpe::params::packages], File["/etc/nagios/nrpe.cfg"]]
  }

  $configs_ = hiera_hash("${module_name}::configs", {})
  $configs.each | $name, $args | {
      Resource["${module_name}::config"] { $name:
          * => $args
      }
  }
}
