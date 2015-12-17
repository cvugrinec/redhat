# Class: jenkins_rws
# ===========================
#
# Full description of class jenkins here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'jenkins':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class jenkins_rws {

    $jenkins_version= hiera("jenkins.jenkins_version")
    $java_version= hiera("jenkins.java_version")
    $msg = "Installing jenkins version: $jenkins_version: "
    notify{ $msg: }

    # make sure the required binaries are installed
    package { "java-$java_version-openjdk":
      ensure => installed,
      # install_options => ['--nopgpcheck'],
      provider => 'yum',
    }->
    exec { "jenkins_repo":
      command => "wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo; rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
      unless => "/usr/bin/test -e '/etc/yum.repos.d/jenkins.repo'",
      path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    }->
    package { "jenkins-$jenkins_version":
      ensure => installed,
      provider => 'yum',
    }
}
