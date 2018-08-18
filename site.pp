node 'puppetagent-win' {
 include chocolatey

 exec { 'Set-NuGetProvider':
  command   => 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force',
  unless => 'if (!(Get-PackageProvider -Name nuget)){exit 1}',
  provider  => 'powershell',
 } ->

 exec { 'Set-PSGalleryTrusted':
  command   => 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted',
  unless => 'if ((Get-PSRepository -Name PSGallery | Select-Object -ExpandProperty InstallationPolicy) -ne "Trusted"){exit 1}',
  provider  => 'powershell',
 } ->

 exec { 'xPSDesiredStateConfiguration-Install':
  command   => 'Install-Module -Name xPSDesiredStateConfiguration -Repository PSGallery -Force',
  unless => 'if (!(Get-Module -listavailable xPSDesiredStateConfiguration)){exit 1}',
  provider  => 'powershell',
} ->

exec { 'cSNNP-Install':
  command   => 'Install-Module -Name cSNMP -Repository PSGallery -Force',
  unless => 'if (!(Get-Module -listavailable cSNMP)){exit 1}',
  provider  => 'powershell',
} ->

dsc {'SNMP-Service':
  resource_name => 'WindowsFeature',
  module        => {
    name    => 'PSDesiredStateConfiguration',
    version => '1.1'
  },
  properties => {
    ensure => 'present',
    name   => 'SNMP-Service',
  }
} ->

dsc {'SNMP-RSAT':
  resource_name => 'WindowsFeature',
  module        => {
    name    => 'PSDesiredStateConfiguration',
    version => '1.1'
  },
  properties => {
    ensure => 'present',
    name   => 'RSAT-SNMP',
  }
} ->

dsc {'SNMP-Community':
  resource_name => 'cSNMPCommunity',
  module        => {
    name    => 'cSNMP',
    version => '1.0.33',
  },
  properties => {
    ensure => 'present',
    community   => 'Test',
    right => 'ReadOnly',
  }
}
}