# = Class: jboss_rws::jboss_eap64
#
# Installs the JBoss EAP 6.4 binaries
#
# == Actions:
#
# Performs basic jboss configuration.
class jboss_rws::jboss_eap64 {

  $jboss_rpm= hiera("jboss_rws.jboss_rpm")

  # make sure the required binaries are installed
  package { "$jboss_rpm":
    ensure => installed,
#    install_options => ['--nopgpcheck'],
    provider => 'yum',
  }->
  exec { "symlink_to_java":
      command => "ln -s /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.65-0.b17.el6_7.x86_64/jre java",
      unless => "/usr/bin/test -L '/opt/java'",
      cwd => "/opt",
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }
  # This is required in order to resolve the sudo issues
  exec { "sudo_requiretty_patch":
      command => "sed -i 's/Defaults.*requiretty/# Defaults   requiretty/' /etc/sudoers",
      cwd => "/opt",
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }
  file { ["/opt/jboss-instances","/var/log/jboss-instances"]:
    recurse => true,
    ensure => 'directory',
    owner => 'jboss',
    group => 'jboss',
    mode => '0750',
  }
  # Creating instance directories
  $apps = hiera("applications")
  $apps.each |String  $app| {
    $msg = "creating instance for app: { $app }"
    notify{ $msg: }
    file { ["/opt/jboss-instances/$app","/var/log/jboss-instances/$app"]:
      recurse => true,
      ensure => 'directory',
      owner => 'jboss',
      group => 'jboss',
      mode => '0750',           
    }
  }
  

  $apps.each |String  $app| {
  
    $offset = hiera("applications_data.$app.offset")
    $listaddr= hiera("applications_data.$app.listaddr")
    $listaddrlb= hiera("applications_data.$app.listaddrlb")
    $listportlb= hiera("applications_data.$app.listportlb")
    $mgmtPort = 9999+$offset
    $filesToCopy = ["start.sh","stop.sh","properties","config.cli","app_init_instance","minimal.tar"]
    $filesToCopy.each |String $fileToCopy| {
      file { "/opt/jboss-instances/$app/$fileToCopy":
        mode => '0750',
        owner => 'jboss',
        group => 'jboss',
        source => "puppet:///modules/jboss_rws/jboss/$fileToCopy",
      }
    }
    exec { "extract_tar_file_$app":
      command => "tar -xvf minimal.tar; rm -f minimal.tar",
      cwd => "/opt/jboss-instances/$app", 
      path => '/usr/local/bin:/bin/:/sbin', 
    }->
    exec { "setting_offset_for_$app":
      command => "cat /opt/jboss-instances/$app/properties | sed -e 's/offset=100/offset=$offset/' > /tmp/properties.tmp; mv -f /tmp/properties.tmp /opt/jboss-instances/$app/properties; rm -f /opt/jboss-instances/$app/$app.pid",
      path => '/usr/local/bin:/bin/:/sbin',
    }->
    exec { "starting_$app":
      command => "/opt/jboss-instances/$app/start.sh",
      unless => "/usr/bin/test -f '/opt/jboss-instances/$app/$app.pid'",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    }->
    exec { "waitfor_starting_$app":
      command => "sleep 5",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    }->
    exec { "create_config_$app":
      command => "cat /opt/jboss-instances/$app/config.cli | sed -e 's/XXX_NEWHOSTNAME_XXX/$listaddr/g'| sed -e 's/XXX_LBADDR_XXX/$listaddrlb/g' | sed -e 's/XXX_LBPORT_XXX/$listportlb/g' >/tmp/config.cli",
      #unless => "/usr/bin/test -d '/opt/jboss-instances/$app'",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      returns => ["0",],
    }
    exec { "config_$app":
      command => "/opt/jboss/bin/jboss-cli.sh --connect --controller=localhost:$mgmtPort < /tmp/config.cli; touch /var/log/jboss-instances/$app/initialized",
      unless => "/usr/bin/test -f '/var/log/jboss-instances/$app/initialized'",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      returns => ["0",],
    }
    exec { "symlink_to_log_$app":
      command => "ln -s /var/log/jboss-instances/$app logs",
      user => 'jboss',
      unless => "/usr/bin/test -L '/opt/jboss-instances/$app/logs'",
      cwd => "/opt/jboss-instances/$app/",
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    }
    exec { "setting_initfile_for_$app":
      command => "cat /opt/jboss-instances/$app/app_init_instance | sed -e 's/XXX_INSTANCE/$app/' > /tmp/app_init_instance; mv -f /tmp/app_init_instance /etc/init.d/jboss-$app-instance; chmod 750 /etc/init.d/jboss-$app-instance; chkconfig --add jboss-$app-instance",
      unless => "/usr/bin/test -f '/etc/init.d/jboss-$app-instance'",
      path => '/usr/local/bin:/bin/:/sbin',
    }
    exec { "cleanup_of_$app":
      command => "rm -f /opt/jboss-instances/$app/app_init_instance; rm -f /opt/jboss-instances/$app/config.cli",
      path => '/usr/local/bin:/bin/:/sbin',
    }
  }
}
