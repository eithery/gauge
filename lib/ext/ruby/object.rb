# Eithery Lab, 2017
# Class Object
# Extends functionality of Ruby Object class.
# Used as a helper supporting Ruby based DSL for database metadata definitions.

require 'gauge'

class Object

private

  def table(*args, &block)
    Gauge::Schema::DatabaseSchema.current.table(*args, &block)
  end


  def view(*args, &block)
    Gauge::Schema::DatabaseSchema.current.view(*args, &block)
  end
end
