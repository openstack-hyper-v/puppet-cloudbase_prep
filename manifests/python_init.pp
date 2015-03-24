#
class cloudbase_prep::python_init (
  $python_archive   = 'http://10.21.7.214/python27.tar.gz',
  $python_dir       = 'C:\Python27',
  $get_pip_location = 'https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py',
  $pip_whl_location = 'https://pypi.python.org/packages/py2.py3/p/pip/pip-6.0.8-py2.py3-none-any.whl'
) {

  windows_common::remote_file { 'python_archive':
    source      => $python_archive,
    destination => "${python_dir}.tar.gz",
  }

  Exec {
    path => 'c:\windows;c:\windows\system32',
  }

  exec { 'clean_existing_python':
    command     => "Remove-Item -Force ${python_dir} >null 2>&1",
    refreshonly => true,
    returns     => [0,1],
    subscribe   => Windows_common::Remote_file['python_archive'],
    provider    => powershell,
  }

  windows_7zip::extract_file {'python_gzip-to-tar':
    file        => "${python_dir}.tar.gz",
    destination => "c:/",
    subscribe   => Exec['clean_existing_python'],
  }
  windows_7zip::extract_file {'python_tar-to-dir':
    file        => "${python_dir}.tar",
    destination => "c:/",
    subscribe   => Windows_7zip::Extract_file['python_gzip-to-tar'],
  }
  file { "${python_dir}.tar":
    ensure  => absent,
    require => Windows_7zip::Extract_file['python_tar-to-dir'],
  }
#  exec { 'place_new_python':
#    cwd         => 'c:/',
#    command     => "C:\\mingw-get\\msys\\1.0\\bin\\tar.exe -xvzf ${python_dir}.tar.gz",
#    refreshonly => true,
#    subscribe   => Exec['clean_existing_python'],
#  }
#  file { $python_dir: 
#    ensure  => directory,
#    require => Exec['place_new_python'],
#    before  => Exec['install_python_wmi'],
#  }
  exec { 'install_python_wmi':
    command    => "${python_dir}\\scripts\\pip.exe install wmi",
    refreshonly => true,
    subscribe  => Windows_7zip::Extract_file['python_tar-to-dir'],
  }
  exec { 'install_python_virtualenv':
    command    => "${python_dir}\\scripts\\pip.exe install virtualenv",
    refreshonly => true,
    subscribe  => Exec['install_python_wmi'],
  }

  exec { 'pywin32-postinstall-script':
    command     => "${python_dir}\\python.exe ${python_dir}/Scripts/pywin32_postinstall.py -install",
    refreshonly => true,
    subscribe   => Exec['install_python_virtualenv'],
  }

  windows_common::remote_file { 'fetch_get-pip.py':
    source      => $get_pip_location,
    destination => "${python_dir}/get-pip.py",
    require     => File["${python_dir}.tar"],
  }

  exec { 'run_get-pip.py':
    command     => "${python_dir}\\python.exe ${python_dir}\\get-pip.py",
    refreshonly => true,
    subscribe   => Windows_common::Remote_file['fetch_get-pip.py'],
  }

  exec { 'clean_pip_whl_in_virtualenv':
    command     => "Remove-Item -Force C:\Python27\Lib\site-packages\virtualenv_support\pip* >null 2>&1",
    refreshonly => true,
    returns     => [0,1],
    provider    => powershell,
    subscribe   => Exec['run_get-pip.py'],
  }

#  file { "${python_dir}\\Lib\\site-packages":
#    ensure  => directory,
#    before  => File["${python_dir}\\Lib\\site-packages\\virtualenv_support"],
#  }
#  file { "${python_dir}\\Lib\\site-packages\\virtualenv_support":
#    ensure  => directory,
#    before  => Windows_common::Remote_file['get_new_pip_whl_for_virtualenv'],
#  }

  windows_common::remote_file { 'get_new_pip_whl_for_virtualenv':
    source      => $pip_whl_location,
    destination => "${python_dir}/Lib/site-packages/virtualenv_support/pip-6.0.8-py2.py3-none-any.whl",
    require     => Exec['clean_pip_whl_in_virtualenv'],
  }
 
  File["${python_dir}.tar"] -> Class['mingw']

  if !defined(Class['mingw']){
    class { 'mingw': }
  }

}
