# Eithery Lab, 2017
# Class String
# Extends functionality of Ruby String class.
# Supports string colorization for console messages.
# Depends on rainbow gem.

require 'gauge'

class String
  def colorize(severity)
    displayed_color = color_for(severity)
    return self.color displayed_color unless displayed_color.nil?
    self
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
