require 'puppet/util/wpackage'

# represents an error resulting from a Win32 error code
class Puppet::Util::WPackage::Error < Puppet::Error
  require 'windows/error'
  include ::Windows::Error

  attr_reader :code

  def initialize(message, code = GetLastError.call)
    super(message + ":  #{get_last_error(code)}")

    @code = code
  end
end

