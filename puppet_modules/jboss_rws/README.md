# jboss_rws

#### Table of Contents

1. [Overview](#overview)

## Overview

please configure the following properties for this module

jboss_rws:
  jboss_rpm: jboss_rws-6.4-2.x86_64
  patchfile: jboss-eap-6.4.3-patch.zip

applications:
  - someapp1
  - someapp2

applications_data:
  someapp1:
    offset: 100
    listaddr: puppetmaster.local
  someapp2:
    offset: 200
    listaddr: puppetmaster.local
