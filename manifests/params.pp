class nrpe::params  {
    case $facts[os][family] {
        'Debian': {
            $packages=['nagios-nrpe-server', 'monitoring-plugins', 'monitoring-plugins-basic', 'monitoring-plugins-standard']
            $service='nagios-nrpe-server'
            $plugin_loc='/usr/lib/nagios/plugins'
            $nrpe_user='nagios'
            $pid_file='/var/run/nagios/nrpe.pid'
            $config_dir='/etc/nagios/nrpe.d'
        }
        'RedHat': {
            $packages=['nrpe', 'nagios-plugins-all']
            $service='nrpe'
            $plugin_loc='/usr/lib64/nagios/plugins'
            $nrpe_user='nrpe'
            $pid_file='/var/run/nrpe/nrpe.pid'
            $config_dir='/etc/nrpe.d'
        }
        default: {
            fail("os family ${facts[os][family]} not supported")
        }
    }
    $pluginsdir='/usr/local/bin'
}
