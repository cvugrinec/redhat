# Class: jboss_rws
# ===========================
#
# Full description of class jboss_rws here.
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
# Author Name <cvugrinec@redhat.com>
#
# Copyright
# ---------
#
# Copyright 2015 Chris Vugrinec, Red Hat
#
class jboss_rws {

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

      include jboss_rws::jboss_eap64
#     include jboss_rws::jboss_eap64_patch
}
