
# wat dit doet: een bestandje toevoegen, maar enkel op nodes (??) ("containers"
# zeggen de docs)  die getagged zijn met de tag "nrpe". 

define nrpe::config($content = "") {
  if tagged("nrpe") {
    file { "$nrpe::config_dir/$name":
      content => "$content\n",
      notify => Exec["nrpe-config"],
      #require => [ Package[$packages],  File["/etc/nagios/nrpe.d"]],
      require =>  File["/etc/nagios/nrpe.d"],
    }
  }
}

