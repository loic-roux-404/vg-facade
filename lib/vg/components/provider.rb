require_relative '../lib/system'

# Vm provider component
class Provider < Component

  utility_bin = 'vagrant-vmware-utility'

  def initialize(cnf, project_name = '')
    @name = project_name
    super(cnf)

    ENV['VAGRANT_DEFAULT_PROVIDER'] = cnf.type
    self.send('req_'+type)
    self.dispatch(cnf.type)
  end

  # create virtualbox config with VboxManage settings
  def provider_virtualbox
    $vagrant.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, "--name", @name]
      @cnf.opts.each_pair do |param_id, value|
        # Convert booleans to virtualbox modifyvm params
        value = value.to_s != 'false' ? value : "off"
        value = value.to_s != 'true' ? value : "on"
        vb.customize ['modifyvm', :id, "--#{param_id}", value]
      end
    end
  end

  def provider_libvirt
    non_supported
  end

  def provider_vmware
    # TODO fix network errors with private nets and port forwarding
    # TODO use vmware-utility, no choice
    # TODO use utility to fix port forwarding
    # https://www.vagrantup.com/vmware/downloads
    # https://www.vagrantup.com/docs/providers/vmware/vagrant-vmware-utility
    $vagrant.vm.provider 'vmware_desktop' do |v|
      @cnf.opts.each do |attr_name, attr_value|
        v[attr_name] = attr_value
        if attr_name == 'allowlist_verified'
          v[attr_name] = @cnf.opts.allowlist_verified#, :disable_warning => true
        end
        if attr_name == 'vmx'
          attr_value.each do |k, v|
            v.vmx[k] = v
          end
        end
      end
    end
  end

  def req_vmware
    system('vagrant plugin install vagrant-vmware-desktop')
    if Vagrant::Util::Platform.mac? then
      command('brew') ? system("brew install #{utility_bin}") : StandardError.new("Need brew to install #{utility_bin}")
      system("/opt/vagrant-vmware-desktop/bin/vagrant-vmware-utility service install")
    elsif Vagrant::Util::Platform.mac?
      puts "vagrant-vmware-utility should be necessary <https://www.vagrantup.com/vmware/downloads>"
    end
  end

  def provider_parallels
    non_supported
  end

  def provider_docker
    non_supported
  end

  def requirements
    if !self.is_valid_type(@cnf.type)
      raise ConfigError.new(
        ['provider.type'], # options concerned
        self.type_list_str("\n - "), # suggest for option
        'missing'
      )
    end
    self.req_vmware
    # Set @valid to true (component is ok)
    return true
  end

  def non_supported
    puts @cnf.type+" isn't supported for now"
    exit
  end
# end Class Provider#
end
