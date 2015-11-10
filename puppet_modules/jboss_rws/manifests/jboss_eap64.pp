# = Class: jboss_rws::jboss_eap64
#
# Installs the JBoss EAP 6.4 binaries
#
# == Actions:
#
# Performs basic jboss configuration.
class jboss_rws::jboss_eap64 {

  # make sure the required binaries are installed
  package { 'jboss_rws-6.4-2.x86_64':
    ensure => installed,
    source => 'jboss_rws-6.4-2.src.rpm',
    provider => 'rpm',
  }->
  exec { "symlink_to_java":
      command => "ln -s /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.65-0.b17.el6_7.x86_64/jre java",
      unless => "/usr/bin/test -L '/opt/java'",
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
      command => "cat /opt/jboss-instances/$app/properties | sed -e 's/offset=100/offset=$offset/' > /tmp/properties.tmp; mv -f /tmp/properties.tmp /opt/jboss-instances/$app/properties",
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
      command => "cat /opt/jboss-instances/$app/config.cli | sed -e 's/XXX_NEWHOSTNAME_XXX/puppetmaster.local/g' >/tmp/config.cli",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      returns => ["0","1",],
    }->
    exec { "config_$app":
      command => "/opt/jboss/bin/jboss-cli.sh --connect --controller=localhost:$mgmtPort < /tmp/config.cli; rm -f /opt/jboss-instances/$app/config.cli",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      #returns => ["0","1",],
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
  }
}
