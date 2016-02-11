# Class: nexus_rws
# ===========================
#
# configure the following values in your hiera data structure
#  nexus:
#  version: nexus-2.11.4-01
#  install_file: nexus-2.11.4-01-bundle.tar.gz
#
#
#
class nexus_rws {

 case $::osfamily {
    'Redhat': {
        $msg = "OS on hostname: $hostname is supported, starting install:"
        notify{ $msg: }
    }
    default: {
      $msg = " on hostname: $hostname is NOT supported, exiting"
      fail("${::osfamily} ${msg}")
    }
  }

  $install_file = hiera("nexus.install_file")
  $nexus_version = hiera("nexus.version")

  #$msg = "install nexus with file: { $install_file }"
  #notify{ $msg: }
  
  group { 'nexus':
    ensure => 'present',
  }->
  user { 'nexus':
    ensure => 'present',
    groups => 'nexus',
  }->
  exec { "nexus_mkdir":
    command => "mkdir /opt/nexus",
    unless => "/usr/bin/test -d '/opt/nexus'",
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }->
  file { "/opt/nexus/$install_file":
     mode => '0750',
     owner => 'nexus',
     group => 'nexus',
     source => "puppet:///modules/nexus_rws/$install_file",
  }
  exec { "nexus_unzip":
    command => "tar -xvf /opt/nexus/$install_file; rm -f /opt/nexus/$install_file",
    cwd => "/opt/nexus",
    unless => "/usr/bin/test -d '/opt/nexus/sonatype-work'",
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }
  exec { "nexus_cfg":
    command => "sed -i 's/NEXUS_HOME=.*/NEXUS_HOME=\/opt\/nexus\/$nexus_version/' /opt/nexus/$nexus_version/bin/nexus",
    cwd => "/opt/nexus",
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }->
  file { "/etc/init.d/nexus":
    mode => "750",
    source => "/opt/nexus/$nexus_version/bin/nexus",
  }->
  exec { "nexus_initd":
    command => "chkconfig --add nexus; chkconfig --levels 345 nexus on",
    cwd => "/opt/nexus",
     unless => "/etc/init.d/nexus",
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }
}
