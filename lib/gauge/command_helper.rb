# Eithery, 2020
# Application command helper
# frozen_string_literal: true

module Gauge
  module CommandHelper
    def help_option
      method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    end

    def command(name, *aliases, &block)
      help_option
      define_method(name) do
        if options[:help]
          invoke :help, [name]
        else
          block.call
        end
      end
      map Array(aliases).map(&:to_s) => name if aliases
    end
  end
end
