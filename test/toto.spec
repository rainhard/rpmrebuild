# Initial spec file created by autospec ver. 0.8 with rpm 3 compatibility
Summary: toto
# The Summary: line should be expanded to about here -----^
#Summary(fr): (translated summary goes here)
Name: toto
Version: 0.1
Release: 1
#Group: unknown
#Group(fr): (translated group goes here)
License: foo
Source: toto-%{version}-bin.tar.gz
#NoSource: 0
BuildRoot: %{_tmppath}/%{name}-root
# Following are optional fields
#URL: http://www.example.net/toto/
#Distribution: Red Hat Contrib-Net
#Prefix: /
#BuildArch: noarch
#Requires: 
#Obsoletes: 
#BuildRequires: 

%description
toto version 0.1

#%description -l fr
#(translated description goes here)

%prep
%setup -c 'toto-%{version}'
#%patch

%install
%__cp -a . "${RPM_BUILD_ROOT-/}"

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf "$RPM_BUILD_ROOT"

%files
%defattr(-,root,root)
/tmp/toto/

%changelog
* Tue Jul 17 2012 GERBIER Eric <gerbier@lxcti1>
- Initial spec file created by autospec ver. 0.8 with rpm 3 compatibility
