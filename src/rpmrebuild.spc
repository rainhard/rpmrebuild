# get rpm version
%define rpm_ver %( rpm -q --queryformat='%{VERSION}' rpm | cut -f 1 -d.)
# test for an rpm version
%define test_ver() %(if test %1 == %2; then echo 1; else echo 0;fi )
# define binary flags
%define is_rpm3 %test_ver %rpm_ver 3
%define is_rpm4 %test_ver %rpm_ver 4
%define is_rpm5 %test_ver %rpm_ver 5

# The Summary: line should be expanded to about here -----^
Summary: A tool to build rpm file from rpm database
Summary(fr): Un outil pour construire un package depuis une base rpm
Name: rpmrebuild
License: GPL
Group: Development/Tools
BuildRoot: %{_topdir}/installroots/%{name}-%{version}-%{release}
Source: rpmrebuild.tar.gz
# Following are optional fields
Url: http://rpmrebuild.sourceforge.net
Packager: Eric Gerbier <gerbier@users.sourceforge.net>
#Distribution: 
BuildArchitectures: noarch
Requires: bash
Requires: cpio
Requires: sed

# mkdir 
# sort
%if %is_rpm5
# rpm v5
Requires: rpm >= 5.0, /usr/bin/rpmbuild
Requires: coreutils
%define release_suffix rpm5
%else
%if %is_rpm4
# rpm v4
Requires: rpm >= 4.0, /usr/bin/rpmbuild
Requires: coreutils
%define release_suffix rpm4
%else
%if %is_rpm3
# rpm v3
Requires: rpm < 4.0
Requires: fileutils
Requires: textutils
%define release_suffix rpm3
%endif
%endif
%endif

Release: %{release}%{release_suffix}

# compatibility with old digest format
%global _binary_filedigest_algorithm 1
%global _source_filedigest_algorithm 1

%description
rpmrebuild allow to build an rpm file from an installed rpm, or from
another rpm file, with or without changes (batch or interactive).
It can be extended by a plugin system.
A typical use is to easy repackage a software after some configuration's
change.

%description -l fr
rpmbuild permet de fabriquer un package rpm à partir d'un 
package installé ou d'un fichier rpm, avec ou sans modifications 
(interactives ou batch).
Un système de plugin permet d'étendre ses fonctionnalités.
Une utilisation typique est la fabrication d'un package suite à des modifications
de configuration.

%prep
%setup -c rpmrebuild

%build
make

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf "$RPM_BUILD_ROOT"
make DESTDIR="$RPM_BUILD_ROOT" install

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf "$RPM_BUILD_ROOT"

%files -f rpmrebuild.files

%post
if [ -f /usr/lib/rpmrebuild/rpmrebuild_rpmqf.src ]
then
	rm /usr/lib/rpmrebuild/rpmrebuild_rpmqf.src
fi
%if %is_rpm3
ln -s /usr/lib/rpmrebuild/rpmrebuild_rpmqf4.src /usr/lib/rpmrebuild/rpmrebuild_rpmqf.src
%endif
%if %is_rpm4
ln -s /usr/lib/rpmrebuild/rpmrebuild_rpmqf4.src /usr/lib/rpmrebuild/rpmrebuild_rpmqf.src
%endif
%if %is_rpm5
ln -s /usr/lib/rpmrebuild/rpmrebuild_rpmqf5.src /usr/lib/rpmrebuild/rpmrebuild_rpmqf.src
%endif
if [ -f /usr/lib/rpmrebuild/rpmrebuild.usedtags ]
then
	rm /usr/lib/rpmrebuild/rpmrebuild.usedtags
fi
#echo "build rpmrebuild.usedtags"
/usr/lib/rpmrebuild/rpmrebuild_extract_tags.sh /usr/lib/rpmrebuild/rpmrebuild_rpmqf.src > /usr/lib/rpmrebuild/rpmrebuild.usedtags

%postun
if [ "$1" = "0" ]
then
	# last uninstall
	#echo "delete rpmrebuild.usedtags and rpmrebuild_rpmqf.src"
	rm /usr/lib/rpmrebuild/rpmrebuild_rpmqf.src
	rm /usr/lib/rpmrebuild/rpmrebuild.usedtags
fi
