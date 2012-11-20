module Puppet::Util::WPackage
  if Puppet::Util::Platform.windows?
    # these reference platform specific gems
    require 'puppet/util/wpackage/error'
    require 'puppet/util/wpackage/sid'
    require 'puppet/util/wpackage/security'
    require 'puppet/util/wpackage/user'
    require 'puppet/util/wpackage/process'
    require 'puppet/util/wpackage/file'
  end
  require 'puppet/util/wpackage/registry'
end
