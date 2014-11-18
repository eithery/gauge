# Eithery Lab., 2014.
# Gauge::Validators::Base specs.
require 'spec_helper'

module Gauge
  module Validators
    class BaseStub < Base
    end

    describe Base do
      let(:validator) { BaseStub.new }

      it_behaves_like "any database object validator"
=begin

      describe '.check_all' do
        it "defines 'check_all' instance method" do
          expect { Base.check_all(:data_tables) }.to change { validator.respond_to? :check_all }.from(false).to(true)
        end
      end


      describe '.check_before' do
        it "defines 'check_before' instance method" do
          expect { Base.check_before(:data_tables) }
            .to change { validator.respond_to? :check_before }.from(false).to(true)
        end
      end


      describe '.check' do
        it "defines 'check_for' instance method" do
          expect { Base.check(:data_tables, :data_columns) }
            .to change { validator.respond_to? :check_for }.from(false).to(true)
        end
      end


      describe '.validate' do
        it "defines 'validate' instance method" do
          expect { Base.validate }.to change { validator.respond_to? :validate }.from(false).to(true)
        end
      end


      describe '#check' do
        before do
          @dbo_schema = double('dbo_schema')
          @dba = double('dba')
        end

        context "when preliminary validation check (check_before method) is defined" do
          it "should be called" do
            validator.should_receive(:check_before)
            validator.check(@dbo_schema, @dba)
          end

          context "and passed successfully" do
          end

          context "and failed" do
          end
        end


        context "when no preliminary validation checks defined" do
          it "should not be called" do
#            validator.should_not_receive(:check_before)
#            validator.check(@dbo_schema, @dba)
          end
        end


        context "when no child validation checks (check_all method) defined" do
        end


        context "wnen no validation checks for specified validators (check for method) defined" do
        end
      end
=end
    end
  end
end
