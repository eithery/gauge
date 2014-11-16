# Eithery Lab., 2014.
# Class Object
# Extends functionality of Ruby Object class.
# Used as a helper supporting Ruby based DSL for database metadata definitions.
require 'gauge'

class Object
  def database(*args, &block)
    Gauge::Schema::Repo.define_database(*args, &block)
  end


  def table(*args, &block)
    Gauge::Schema::Repo.define_table(*args, &block)
  end
end
