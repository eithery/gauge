# Eithery Lab., 2014.
# Gauge::Validators::Base specs.
require 'spec_helper'

module Gauge
  module Validators
    describe Base do
      let(:validator) { Base.new }

      it_behaves_like "any database object validator"


      describe '.check_all' do
      end


      describe '#check' do
      end
    end
  end
end
