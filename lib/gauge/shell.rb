# Eithery, 2020
# CLI application shell
# frozen_string_literal: true

module Gauge
  class Shell
    def initialize(options)
      @global_options = GlobalOptions.new(options)
      Rainbow.enabled = true if @global_options.colored?
    end

    def app_info
      if @global_options.help?
        AppInfo.help
      elsif @global_options.version?
        AppInfo.version
      else
        AppInfo.greeting
      end
    end

    def check(options, args)
      Inspector.new(options).check args
    end
  end
end
