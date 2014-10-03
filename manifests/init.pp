class cloudbase_prep (
  $nova_test = false,
){

  if $nova_test {
    $nova_class = ['openstack_hyper_v_stub::nova_dependencies']
  } else {
    $nova_class = ['openstack_hyper_v::nova_dependencies']
  }
  class {$nova_class: before => Class['openstack_hyper_v::openstack::folders'],}

  class { 'openstack_hyper_v::openstack::folders': 
#    require => Class[nova_class],
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
    revision    => 'master',
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

