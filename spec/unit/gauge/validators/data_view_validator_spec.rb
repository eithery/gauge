# Eithery Lab., 2015.
# Gauge::Validators::DataViewValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe DataViewValidator do
      let(:validator) { DataViewValidator.new }

      it_behaves_like "any database object validator"
    end
  end
end
