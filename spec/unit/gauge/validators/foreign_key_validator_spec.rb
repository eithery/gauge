# Eithery Lab., 2015.
# Gauge::Validators::ForeignKeyValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe ForeignKeyValidator do
      let(:validator) { ForeignKeyValidator.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
      end
    end
  end
end
