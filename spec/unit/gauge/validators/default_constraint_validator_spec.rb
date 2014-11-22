# Eithery Lab., 2014.
# Gauge::Validators::DefaultConstraintValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DefaultConstraintValidator do
      let(:validator) { DefaultConstraintValidator.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"
    end
  end
end
