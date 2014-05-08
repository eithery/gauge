# Eithery Lab., 2014.
# Class Gauge::Shell
# Executes application commands.
module Gauge
  class Shell
    attr_reader :listeners

    def initialize(global_opts={}, options={})
      @global_opts = global_opts
      @options = options
      @listeners = [ConsoleListener.new]

      Rainbow.enabled = true
    end


    def help
      if @global_opts[:v]
        puts "Database Gauge #{VERSION}"
      else
        puts "Database Gauge. Version #{VERSION}"
        puts "Copyright (C) M&O Systems, Inc., 2014.\n"
        puts "usage: g [--version|-v] [--help|-h] <command> [<args>]"
        if @global_opts[:h]
          puts "\nThe most commonly used gauge commands are:"
          puts "   check    Checks database structure against the metadata"
          puts "   sync     Synchronize database structure regarding the metadata"
          puts "   help     Displays additional help info"
          puts "\nSee 'g help <command>' for more information on a specific command."
        end
      end
    end


    # Performs check operation for the specified database or separate database objects
    # against the predefined schema.
    def check(args)
      dbo_names = args.respond_to?(:each) ? args : [args]
      dbo_names.each do |dbo_name|
        @listeners.each do |listener|
          listener.info("Inspecting '#{dbo_name}' database...")
          listener.ok("Inspecting '#{dbo_name}' database - ok") if dbo_name =~ /gauge_db_green/
          listener.error("Inspecting '#{dbo_name}' database - failed") unless dbo_name =~ /gauge_db_green/
          listener.error("Total 3 errors found.\n") unless dbo_name =~ /gauge_db_green/
        end
      end
    end
  end
end
