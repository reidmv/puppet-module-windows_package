require 'puppet/util/windows_package'

class Puppet::Provider::Package::WindowsPackage
  class Package
    extend Enumerable
    extend Puppet::Util::Errors

    include Puppet::Util::WindowsPackage::Registry
    extend Puppet::Util::WindowsPackage::Registry

    attr_reader :name, :version

    # Enumerate each package. The appropriate package subclass
    # will be yielded.
    def self.each(&block)
      with_key do |key, values|
        name = key.name.match(/^.+\\([^\\]+)$/).captures[0]

        [MsiPackage, ExePackage].find do |klass|
          if pkg = klass.from_registry(name, values)
            yield pkg
          end
        end
      end
    end

    # Yield each registry key and its values associated with an
    # installed package. This searches both per-machine and current
    # user contexts, as well as packages associated with 64 and
    # 32-bit installers.
    def self.with_key(&block)
      %w[HKEY_LOCAL_MACHINE HKEY_CURRENT_USER].each do |hive|
        [KEY64, KEY32].each do |mode|
          mode |= KEY_READ
          begin
            open(hive, 'Software\Microsoft\Windows\CurrentVersion\Uninstall', mode) do |uninstall|
              uninstall.each_key do |name, wtime|
                open(hive, "#{uninstall.keyname}\\#{name}", mode) do |key|
                  yield key, values(key)
                end
              end
            end
          rescue Puppet::Util::WindowsPackage::Error => e
            raise e unless e.code == Windows::Error::ERROR_FILE_NOT_FOUND
          end
        end
      end
    end

    # Get the class that knows how to install this resource
    def self.installer_class(resource)
      fail("The source parameter is required when using the Windows provider.") unless resource[:source]

      case resource[:source]
      when /\.msi"?\Z/i
        # REMIND: can we install from URL?
        # REMIND: what about msp, etc
        MsiPackage
      when /\.exe"?\Z/i
        fail("The source does not exist: '#{resource[:source]}'") unless File.exists?(resource[:source])
        ExePackage
      else
        fail("Don't know how to install '#{resource[:source]}'")
      end
    end

    def self.quote(value)
      value.include?(' ') ? %Q["#{value.gsub(/"/, '\"')}"] : value
    end

    def initialize(name, version)
      @name = name
      @version = version
    end
  end
end

require 'puppet/provider/windows_package/windows_package/msi_package'
require 'puppet/provider/windows_package/windows_package/exe_package'
