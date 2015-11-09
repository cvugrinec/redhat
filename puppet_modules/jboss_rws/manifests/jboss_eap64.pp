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
    $filesToCopy = ["start.sh","stop.sh","properties","minimal.tar"]
    $filesToCopy.each |String $fileToCopy| {
      file { "/opt/jboss-instances/$app/$fileToCopy":
        mode => '0750',
        owner => 'jboss',
        group => 'jboss',
        source => "puppet:///modules/jboss_rws/jboss/$fileToCopy",
      }
    }
    exec { "extract_tar_file_$app":
      command => "cd /opt/jboss-instances/$app; tar -xvf minimal.tar; rm -f minimal.tar",
      path => '/usr/local/bin:/bin/:/sbin', 
    }->
    exec { "setting_offset_for_$app":
      command => "cat /opt/jboss-instances/$app/properties | sed -e 's/offset=100/offset=$offset/' > /tmp/properties.tmp; mv -f /tmp/properties.tmp /opt/jboss-instances/$app/properties",
      path => '/usr/local/bin:/bin/:/sbin',
    }->
    exec { "starting_$app":
      command => "/opt/jboss-instances/$app/start.sh",
      unless => "pgrep -fc '/bin/sh /opt/jboss/bin/standalone.sh -Djboss.server.base.dir=/opt/jboss-instances/$app'",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    }->
    exec { "waitfor_starting_$app":
      command => "sleep 5",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    }->
    exec { "config_$app":
      command => "/opt/jboss/bin/jboss-cli.sh --connect --controller=localhost:$mgmtPort '/interface=management:write-attribute(name=inet-address,value=puppetmaster.local)'",
      user => 'jboss',
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      #returns => ["0","1",],
    }
  }
}
