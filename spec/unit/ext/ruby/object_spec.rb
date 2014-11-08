# Eithery Lab., 2014.
# Object extension specs.
# Covers some monkey patches for Object class.
require 'spec_helper'

describe Object do
  it { should respond_to :database, :table }
end
