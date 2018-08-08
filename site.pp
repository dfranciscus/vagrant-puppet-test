node 'puppetagent-win' {
 include chocolatey

 exec { 'Set-PSGalleryTrusted':
  command   => 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted',
  provider  => 'powershell',
} ->

 exec { 'xPSDesiredStateConfiguration-Install':
  command   => 'Install-Module -Name xPSDesiredStateConfiguration -Force',
  provider  => 'powershell',
} ->

exec { 'cSNNP-Install':
  command   => 'Install-Module -Name cSNMP -Force',
  provider  => 'powershell',
} ->

dsc {'SNMP-Service':
  resource_name => 'WindowsFeature',
  module        => {
    name    => 'PSDesiredStateConfiguration',
  #  version => '1.1'
  },
  properties => {
    ensure => 'present',
    name   => 'SNMP-Service',
  }
} ->

dsc {'SNMP-Community':
  resource_name => 'cSNMPCommunity',
  module        => {
    name    => 'cSNMP',
  },
  properties => {
    ensure => 'present',
    Community   => 'Test',
    Right => 'ReadOnly',
  }
