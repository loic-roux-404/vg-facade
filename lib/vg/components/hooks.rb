# Hooks class
# Run specific configurable tasks during vagrant process
# Now with single yaml you can add :
# - shell scripts
class Hooks < Component
  DEFAULT_HOOK = {'privileged': true, 'env': {}}

  def initialize(cnf, hooks = [])
    return if !hooks

    @hooks = hooks.map { |hook| hook.merge(DEFAULT_HOOK) }.to_struct

    super(cnf)

    @hooks.each do |hook|
      @hook = hook
      self.dispatch(hook.type)
    end
  end

  def hooks_shell
    if @hook.path
      $vagrant.vm.provision :shell,
        path: @hook.path,
        env: @hook.env,
        privileged: @hook.privileged
    elsif @hook.inline
      $vagrant.vm.provision :shell,
        inline: @hook.inline,
        env: @hook.env,
        privileged: @hook.privileged
    end
  end

  def requirements
    return false if not @hooks
    return false if not @hooks.kind_of?(Array) or @hooks.length < 1

    i = 1
    @hooks.each do |hook|
      if !self.is_valid_type(hook.type)
        raise ConfigError.new(
          ["hooks[#{i}]"], # options concerned
          self.type_list_str("\n - "), # suggest option
          'missing'
        )
      end

      if not 'path' in hook and not 'inline' in hook
        raise ConfigError.new("Error: missing required field inline or path for hook #{i}")
      end

      i += 1
    end

    return true
  end
end
