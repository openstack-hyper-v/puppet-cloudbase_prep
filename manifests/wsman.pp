# == Class: cloudbase_prep::wsman
class cloudbase_prep::wsman {
  windows_common::remote_file{'CBS_prep_WSMan_script':
    source      => 'https://raw.githubusercontent.com/cloudbase/unattended-setup-scripts/master/SetupWinRMAccessSelfSigned.ps1',
    destination => 'c:/SetupWinRMAccess.ps1',
  }
  exec {'CBS_prep_WSMan':
    command => 'cmd.exe /c powershell -executionpolicy Unrestricted -File c:/SetupWinRMAccess.ps1',
    path    => "${::systemdrive}\\windows\\system32;${::systemdrive}\\windows\\system32\\WindowsPowerShell\\v1.0",
#    creates => "c:/OpenSSL-Win32/WinRM.touch",
    unless  => 'powershell "$key = (gi HKLM:\software\cloudbase); exit (1 - $key.GetValue(\"WinRMAccess\"))"',
    require => Windows_common::Remote_file['CBS_prep_WSMan_script'],
  }
}
