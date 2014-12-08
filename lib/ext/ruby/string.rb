# Eithery Lab., 2014.
# Class String
# Extends functionality of Ruby String class.
# Supports colorization for console messages.
require 'gauge'

class String
  def colorize(severity)
    color color_for(severity)
  end

private

  def color_for(severity)
    case severity
      when :error   then :red
      when :warning then :yellow
      when :success then :green
      when :info    then :cyan
    end
  end
end
