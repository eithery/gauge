# Eithery Lab., 2014.
# String extension specs.
# Covers some monkey patches for String class.
require 'spec_helper'

describe String do
  it { should respond_to :colorize }

  describe '#colorize' do
    it "colorizes the specified string" do
      str = "sample string"
      str.should_receive(:color).with(:red).and_return(str)
      str.colorize(:error)
    end
  end
end
