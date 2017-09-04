class nrpe::params  {
  case $::osfamily {
	'Debian': {
	    $packages=["nagios-nrpe-server", "nagios-plugins", "nagios-plugins-basic", "nagios-plugins-standard"]
	    $service="nagios-nrpe-server"
	    $plugin_loc="/usr/lib/nagios/plugins"
	    $nrpe_user="nagios"
	    $pid_file="/var/run/nagios/nrpe.pid"
	    $config_dir="/etc/nagios/nrpe.d"
	}
	'RedHat': {
	    $packages=["nrpe", "nagios-plugins-all"]
	    $service="nrpe"
	    $plugin_loc="/usr/lib/nagios64/plugins"
	    $nrpe_user="nrpe"
	    $pid_file="/var/run/nrpe/nrpe.pid"
	    $config_dir="/etc/nrpe.d"
	}
	default: {
	    fail("os family $osfamily not supported")
	}
    }
    $pluginsdir="/usr/local/bin"
}
