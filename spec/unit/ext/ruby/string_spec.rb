# Eithery Lab., 2017
# String extension specs

require 'spec_helper'

describe String do
  it { should respond_to :colorize }

  describe '#colorize' do
    it "colorizes the specified string" do
      str = "sample string"
      expect(str).to receive(:color).with(:red).and_return(str)
      str.colorize(:error)
    end
  end
end
