# Eithery Lab., 2014.
# Gauge::Validators::Base specs.
require 'spec_helper'

module Gauge
  module Validators
    describe Base do
      class BaseStub < Base
      end

      let(:validator) { BaseStub.new }

      it_behaves_like "any database object validator"


      describe '.check_all' do
        it "defines 'do_check_all' instance method" do
          expect { BaseStub.check_all(:data_tables) }
            .to change { validator.respond_to? :do_check_all }.from(false).to(true)
        end
      end


      describe '.check_before' do
        it "defines 'do_check_before' instance method" do
          expect { BaseStub.check_before(:data_tables) }
            .to change { validator.respond_to? :do_check_before }.from(false).to(true)
        end
      end


      describe '.check' do
        it "defines 'do_check' instance method" do
          expect { BaseStub.check(:data_tables, :data_columns) }
            .to change { validator.respond_to? :do_check }.from(false).to(true)
        end
      end


      describe '.validate' do
        it "defines 'do_validate' instance method" do
          expect { BaseStub.validate }.to change { validator.respond_to? :do_validate }.from(false).to(true)
        end
      end
    end
  end
end
