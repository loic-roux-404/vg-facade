require "vg/facade/version"
# Include ruby tweaks
require 'vg/collection'
# Models
require "vg/model/config"
require "vg/model/component"
require "vg/model/errors"

module Vg
  module Facade
        # Singleton to dispatch all plugin actions
    class Bootstrap < Vagrant.plugin("2")
      name "vg-facade"
      # Map Components more configs to components
      COMPONENT_CONFIGS = {
        Base: false, # false give flat config object without nested
        Provider: [:project_name],
        Network: [:domain],
        Ansible: [:git],
        Fs: [:paths],
        Hooks: [:hooks]
      }

      # Passing to each module vagrant object and part of the config struct
      def initialize(vagrant, dir, config = nil)
        $vagrant = vagrant # Vagrant object
        $__dir__ = dir # Keep Vagrantfile dir
        config_factory = Config.new(config) # instanciate a config factory

        COMPONENT_CONFIGS.each do |plugin, cnfs|
          require_relative "components/#{plugin.downcase}"
          # Dependency injection system
          configs_arg = [config_factory.get(cnfs ? plugin.downcase : nil)]
          cnfs ? cnfs.each { |inject_param| configs_arg.push(config_factory.get(inject_param)) } : nil
          Object.const_get(plugin).new(*configs_arg)
        end
      end
      # end class VagrantBootstrap
    end

    # Add common fixes depending on actuals vagrant issues
    # vagrant/vbox dhcp error (v2.2.7)
    # class VagrantPlugins::ProviderVirtualBox::Action::Network
    #   def dhcp_server_matches_config?(dhcp_server, config)
    #     true
    #   end
    # end

  end
end
