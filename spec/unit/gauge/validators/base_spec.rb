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


      describe '#check' do
        before do
          @dbo_schema = double('dbo_schema')
          @dba = double('dba')
        end

        it "performs preliminary check before main validation stage" do
          validator.should_receive(:do_check_before).with(@dbo_schema, @dba)
          validator.check @dbo_schema, @dba
        end


        context "when preliminary check is passed successfully" do
          before { validator.stub(:do_check_before).and_return(true) }

          it "performs validation check with all inner validators" do
            validator.stub(:do_check)
            validator.should_receive(:do_check_all).with(@dbo_schema, @dba)
            validator.check @dbo_schema, @dba
          end

          it "performs validation check with additional registered validators" do
            validator.stub(:do_check_all)
            validator.should_receive(:do_check).with(@dbo_schema, @dba)
            validator.check @dbo_schema, @dba
          end
        end


        context "when preliminary check is failed" do
          before { validator.stub(:do_check_before).and_return(false) }
          specify "no main validation stage performed" do
            validator.should_not_receive(:do_check_all)
            validator.should_not_receive(:do_check)
            validator.check @dbo_schema, @dba
          end
        end
      end
    end
  end
end
