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

  class { 'cloudbase_prep::wsman': }

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

