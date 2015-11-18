# = Class: jboss_rws::jboss_eap64
#
# Installs the patches for JBoss EAP 6.4 binaries
#
# == Actions:
#
class jboss_rws::jboss_eap64_patch {

  # make sure the required service is running
  $apps = hiera("applications")
  $apps.each |String  $app| {
    $msg = "check if service for : { $app } is running:  jboss-$app-instance"
    notify{ $msg: }
    service { "jboss-$app-instance":
      ensure => running,
      enable => true,
    }
  }
  file { ["/opt/jboss/patches"]:
    recurse => true,
    ensure => 'directory',
    owner => 'jboss',
    group => 'jboss',
    mode => '0750',
  }
  $patchfile= hiera("jboss_rws.patchfile")
  file { "/opt/jboss/patches/$patchfile":
     mode => '0750',
     owner => 'jboss',
     group => 'jboss',
     source => "puppet:///modules/jboss_rws/jboss/$patchfile",
  }
  $app= hiera("applications")
  $apps.each |String  $app| {

    $offset = hiera("applications_data.$app.offset")
    $listaddr= hiera("applications_data.$app.listaddr")
    $mgmtPort = 9999+$offset
    exec { "patch_$app":
      command => "/opt/jboss/bin/jboss-cli.sh --connect --controller=$listaddr:$mgmtPort \"patch apply --override-all /opt/jboss/patches/$patchfile\"; mkdir -p /opt/jboss/patches/$patchfile.log",
      cwd => "/opt/jboss/bin",
      path => '/usr/local/bin:/bin/:/sbin:/opt/java/bin:/usr/bin',
      creates => '/opt/jboss/patches/$patchfile.log',
    }->
    exec { "patch_restart_$app":
      command => "/etc/init.d/jboss-$app-instance restart; mkdir -p /opt/jboss/patches/$patchfile.restart",
      cwd => "/opt/jboss/bin",
      path => '/usr/local/bin:/bin/:/sbin:/opt/java/bin:/usr/bin',
      creates => '/opt/jboss/patches/$patchfile.restart',
    }

  }
}
