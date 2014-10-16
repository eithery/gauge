# Eithery Lab., 2014.
# Gauge::Schema::DataColumnSchema specs.
require 'spec_helper'

module Gauge
  module Schema
    describe DataColumnSchema do
      let(:column) { DataColumnSchema.new('reps', name: 'rep_code', type: :string, required: true) }
      subject { column }

      it { should respond_to :table_name, :column_name, :column_type, :data_type }
      it { should respond_to :allow_null? }
      it { should respond_to :to_key }
    end
  end
end
