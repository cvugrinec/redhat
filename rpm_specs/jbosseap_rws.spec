##
## RPM spec file to generate the jbossas RPM package for the Platform Release 
## This package provides base JBoss Enterprise Application Platform
##
## Author: Juergen Hoffmann <jhoffmann@redhat.com>
## modified by:  Chris Vugrinec <cvugrinec@redhat.com>
##
##
%define projectName EAP-6.4.0

%define pkg_name jboss_rws
%define pkg_version 6.4
%define pkg_release 2
%define pkg_root /opt
%define pkg_basedir /opt/jboss
%define java_version 1:1.8.0
%define bindir /data/drivers/jboss
%define patchfile jboss-eap-6.4.4-patch.zip

#### Define user and group for the installed files.
%define runas_user jboss
%define runas_group jboss
%define runas_user_uid jboss
%define runas_group_gid jboss 

Name:      %{pkg_name}
Version:   %{pkg_version}
Release:   %{pkg_release}
Epoch:     0
Summary:   Custom JBoss EAP Build
Vendor:    Red Hat
BuildArch: x86_64
Packager:  Chris Vugrinec (cvugrinec@redhat.com)

Group:     Applications/Internet
License:   GPL v3
URL:       http://support.redhat.com/
Source0:   %{projectName}.tar
BuildRoot: %{_topdir}/buildroot/%{name}-%{version}

## Turn off for safety reasons.
AutoReq: off

# Do not provide too much stuff and screw up other dependencies
AutoProv: off
Provides: %{name} = %{version}
Requires: apr, java = %{java_version}

%description
Base JBoss Enterprise Application Platform version %{version} 

%prep
%setup -n %{projectName}

%install
mkdir -p %{bindir}
cp ../../SOURCES/%{patchfile} %{bindir}
mkdir -p $RPM_BUILD_ROOT%{pkg_basedir}
cp -r * $RPM_BUILD_ROOT%{pkg_basedir}
%{__rm} -rf %{_tmppath}/jboss-eap-base.filelist
find $RPM_BUILD_ROOT%{pkg_basedir} -type d | sed '{s#'${RPM_BUILD_ROOT}'##;}' | sed '{s#\(^.*$\)#%dir "\1"#g;}' >>%{_tmppath}/jboss-eap-base.filelist
find $RPM_BUILD_ROOT%{pkg_basedir} -type f | sed '{s#'${RPM_BUILD_ROOT}'##;}' | sed '{s#\(^.*$\)#"\1"#g;}' >>%{_tmppath}/jboss-eap-base.filelist



%preun
if [ $1 = 0 ]; then
  if [ -d %{pkg_basedir} ]; then 
    rm -rf %{pkg_basedir}
  fi
#  rm -f %{bindir}/%{patchfile}
fi


%pre
# Add the "jboss" user
getent group %{runas_group} >/dev/null || groupadd %{runas_group_gid} 
getent passwd %{runas_user} >/dev/null || \
  /usr/sbin/useradd -g %{runas_group} -s /sbin/nologin -d %{pkg_basedir} -c "JBoss System user" %{runas_user}


%post
## This condition is true during first installation of package.
if [ $1 -eq 1 ]; then
  ## Put a profile specific init symlink in /etc/init.d/
  chmod 755 %{pkg_basedir}/bin/standalone.sh
  chmod 755 %{pkg_basedir}/bin/domain.sh
  chown -R %{runas_user}:%{runas_group} %{pkg_basedir}
  chown -R %{runas_user}:%{runas_group} %{bindir}
fi
# install patch
kill -9 $(ps -ef | grep -i jboss | grep -v grep | grep -v yum | awk ' { print $2 } ')
/opt/jboss/bin/standalone.sh &
sleep 5
/opt/jboss/bin/jboss-cli.sh --connect "patch apply --override-all %{bindir}/%{patchfile}"

%clean
# Clean up the RPM build root directory.
%{__rm} -rf $RPM_BUILD_ROOT
%{__rm} -rf %{_tmppath}/jboss-eap-base.filelist


#### Files for main jbossas package.
%files -f %{_tmppath}/jboss-eap-base.filelist
%dir %{pkg_basedir}
%defattr(-,%{runas_user},%{runas_group},-)

%changelog
* Sat Nov 07 2015 Chris Vugrinec <cvugrinec@redhat.com> - 0:5.0.1-2
* Thu Nov 08 2012 Juergen Hoffmann <jhoffmann@redhat.com> - 0:5.0.1-2
- initial RPM spec file
