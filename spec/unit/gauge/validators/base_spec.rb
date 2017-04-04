# Eithery Lab, 2017.
# Gauge::Validators::Base specs

require 'spec_helper'

module Gauge
  module Validators

    class DummyTableValidator < Validators::Base; end
    class BaseMock < Validators::Base
      check_all :dummy_tables, with_schema: ->db {[]}
    end


    describe Base do
      let(:validator) { BaseMock.new }

      it_behaves_like "any database object validator"

      describe '.check_all' do
        it "defines 'check_all_<validator_name>' instance method" do
          [:data_tables, :data_views, :data_columns].each do |target|
            expect { BaseMock.check_all(target, with_schema: ->db {[]}) }
              .to change { validator.respond_to? "check_all_#{target}" }.from(false).to(true)
          end
        end
      end


      describe '.check_before' do
        it "defines 'do_check_before' instance method" do
          expect { BaseMock.check_before(:missing_table) }
            .to change { validator.respond_to? :do_check_before }.from(false).to(true)
        end
      end


      describe '.check' do
        it "defines 'do_check' instance method" do
          expect { BaseMock.check(:primary_key, :foreign_keys) }
            .to change { validator.respond_to? :do_check }.from(false).to(true)
        end
      end


      describe '.validate' do
        it "defines 'do_validate' instance method" do
          expect { BaseMock.validate }.to change { validator.respond_to? :do_validate }.from(false).to(true)
        end
      end


      describe '#errors' do
        it { expect(BaseMock.new.errors).to be_empty }
      end


      describe '#check' do
        let(:schema) { double(' schema') }
        let(:dbo) { double('dbo') }
        let(:sql) { double('sql') }

        it "performs a preliminary check before main validation stage" do
          expect(validator).to receive(:do_check_before).with(schema, dbo, sql)
          validate
        end

        context "when a preliminary check is passed successfully" do
          before { validator.stub(:do_check_before).and_return(true) }

          it "performs a validation check with all inner validators" do
            validator.stub(:do_check)
            expect(validator).to receive(:check_all_dummy_tables).with(schema, dbo, sql)
            validate
          end

          it "performs a validation check with additional registered validators" do
            validator.stub(:do_check_all)
            expect(validator).to receive(:do_check).with(schema, dbo, sql)
            validate
          end
        end

        context "when a preliminary check is failed" do
          before { validator.stub(:do_check_before).and_return(false) }

          it "is no main validation stage performed" do
            expect(validator).to_not receive(:check_all_dummy_tables)
            expect(validator).to_not receive(:do_check)
            validate
          end
        end
      end


  private

      def validate
        validator.check schema, dbo, sql
      end
    end
  end
end
