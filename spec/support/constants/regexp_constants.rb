# Eithery Lab., 2017
# Module Gauge::Constants
# Defines the set of constants used in specs with regular expressions.

module Gauge
  module Constants

    # Color escape codes
    module ESC
      RED = '\e\[31m'
      YELLOW = '\e\[33m'
      BOLD = '\e\[1m'
      RESET = '\e\[0m'
      BRIGHT_RED = RED + BOLD
    end

    CRLF = '\r?\n'
  end
end
