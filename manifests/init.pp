# grotendeels gepikt van https://github.com/brightbox/puppet/blob/master/modules/nagios/manifests/init.pp


class nrpe(
    $allowed_hosts = [], 
    $command_timeout = 60,
    $packages=$nrpe::params::packages,
    $pid_file=$nrpe::params::pid_file,
    $config_dir=$nrpe::params::config_dir,
    Hash $configs = {},
    ) inherits nrpe::params {
    notify { "nrpe package: $nrpe::params::packages":}

  tag("nrpe")
	# "nagios-plugins-extra",  -> enkel in ubuntu
  package { $::nrpe::params::packages:
	ensure => latest,
  }
    file { "/etc/nagios/nrpe.d":
	ensure => directory,
	require => Package[$nrpe::params::packages],
    }
    notify  { "nrpe: allowed_hosts is $allowed_hosts": }

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
