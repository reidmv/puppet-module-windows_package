require 'facter'
if Facter.value('osfamily') == 'windows'
module Puppet::Util::WindowsPackage
  if Puppet::Util::Platform.windows?
    # these reference platform specific gems
    require 'puppet/util/windows_package/error'
    require 'puppet/util/windows_package/sid'
    require 'puppet/util/windows_package/security'
    require 'puppet/util/windows_package/user'
    require 'puppet/util/windows_package/process'
    require 'puppet/util/windows_package/file'
  end
  require 'puppet/util/windows_package/registry'
end
end
