class cloudbase_prep {

  class {'openstack_hyper_v::nova_dependencies':}

  class { 'openstack_hyper_v::openstack::folders': 
    require => Class['openstack_hyper_v::nova_dependencies'],
  }

  file {'C:/Openstack/bin':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///extra_files/bin',
    require => Class['openstack_hyper_v::openstack::folders'],
  }

  windows_common::remote_file{'CBS_prep_WSMan_script':
# updated on 4-24-2014, per Octavian
#    source      => 'https://raw2.github.com/cloudbase/unattended-setup-scripts/master/SetupWinRMAccess.ps1',
    source      => 'https://raw.githubusercontent.com/cloudbase/unattended-setup-scripts/master/SetupWinRMAccessSelfSigned.ps1',
    destination => 'c:/SetupWinRMAccess.ps1',
  }
  exec {'CBS_prep_WSMan':
    command => "cmd.exe /c powershell -executionpolicy Unrestricted -File c:/SetupWinRMAccess.ps1",
    path    => "${systemdrive}\\windows\\system32;${systemdrive}\\windows\\system32\\WindowsPowerShell\\v1.0",
	creates => "c:/OpenSSL-Win32/CA/certs/cert.pfx",
	require => Windows_common::Remote_file['CBS_prep_WSMan_script'],
  }

  vcsrepo {'cloudbase_scripts':
    ensure      => 'latest',
    revision    => 'origin/HEAD',
    path        => 'C:/ProgramData/ci-overcloud-init-scripts',
    source      => 'https://github.com/cloudbase/ci-overcloud-init-scripts',
    provider    => 'git',
  }
#  file {'C:/Openstack':
#    ensure  => directory,
#  }
  file {'C:/Openstack/devstack':
    ensure  => link,
    target  => 'C:/ProgramData/ci-overcloud-init-scripts/scripts/HyperV/',
    require => [Vcsrepo["cloudbase_scripts"],Class['openstack_hyper_v::openstack::folders']],
  }

}

