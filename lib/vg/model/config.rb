require_relative '../collection'
require 'yaml'

# Class Config : interface with config files
class Config
  DEFAULT_CONFIG = '/.manala.yaml'
  CONFIG_OBJECT_KEY = 'vagrant'
  USER_CONFIG = '/config.yaml'
  HELPER_MSG = <<-HELPER
# Override original config in #{DEFAULT_CONFIG }
# Useful to pass ansible extra vars or add RAM to VM
---
#{CONFIG_OBJECT_KEY}:
HELPER

  def initialize(config_factory)
    @config = config_factory ? config_factory : DEFAULT_CONFIG
    self.check_confs_file
    @default = YAML.load_file("#{$__dir__}#{@config}")[CONFIG_OBJECT_KEY]
    @user_config = YAML.load_file("#{$__dir__}#{USER_CONFIG}") or self.get_empty_cnf
    @config = @default.deep_merge(@user_config)
  end

  # Request a config by index
  def get(index = '')
    begin
      return gen_base(@config).to_struct if not index

      return nil if !@config[index.to_s]

      return @config[index.to_s] if !@config[index.to_s].is_a?(Hash)

      return @config[index.to_s].to_struct
    rescue ArgumentError => e
      raise StandardError.new "Vm probabbly not correctly linked"
    end
  end

  # Create base from config.json root
  def gen_base(config_factory)
    res = {}
    config_factory.each do |key, value|
      !value.is_a?(Hash) && !value.is_a?(Array) ? res[key] = value : nil
    end
    res
  end

  # Create missing user config if needed
  def check_confs_file
    begin
      File.read($__dir__ + USER_CONFIG)
    rescue StandardError
      puts 'Creating missing config'
      user_config_file = File.open($__dir__ + USER_CONFIG, 'w+')
      user_config_file.puts HELPER_MSG
      user_config_file.close
    end

    begin
      File.read($__dir__ + @config)
    rescue IOError
      raise ConfigError.new("Need to create a config file #{@config}")
    end
  end

  def get_empty_cnf
    res = {}
    res[CONFIG_OBJECT_KEY] = {}

    return res
  end
end
