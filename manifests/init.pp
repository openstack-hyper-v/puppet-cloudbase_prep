class cloudbase_prep {
  windows_common::remote_file{'CBS_prep_WSMan_script':
    source      => 'https://raw2.github.com/cloudbase/unattended-setup-scripts/master/SetupWinRMAccess.ps1',
    destination => 'c:/SetupWinRMAccess.ps1',
  }
  exec {'CBS_prep_WSMan':
    command => "cmd.exe /c powershell -executionpolicy Unrestricted -File c:/SetupWinRMAccess.ps1",
	creates => "c:/OpenSSL-Win32/CA/certs/cert.pfx",
	require => Windows_common::Remote_file['CBS_prep_WSMan_script'],
  }

  vcsrepo {'cloudbase_scripts':
    ensure      => 'latest',
    path        => 'C:/ProgramData/ci-overcloud-init-scripts',
    source      => 'https://github.com/cloudbase/ci-overcloud-init-scripts',
    provider    => 'git',
  }
  file {'C:/Openstack':
    ensure  => directory,
  }
  file {'C:/Openstack/devstack':
    ensure  => link,
    target  => 'C:/ProgramData/ci-overcloud-init-scripts/scripts/HyperV/',
    require => [Vcsrepo["cloudbase_scripts"],File['C:/Openstack']],
  }

}

