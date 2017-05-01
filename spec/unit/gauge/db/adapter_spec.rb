# Eithery Lab, 2017
# Gauge::DB::Adapter specs

require 'spec_helper'

module Gauge
  module DB
    describe Adapter do
      let(:db_schema) { double('db_schema', database_name: 'test_db') }
      let(:database) { double('database', test_connection: nil) }
      subject { Adapter }

      it { should respond_to :session }
      it { should respond_to :database }


      describe '.session' do
        it "uses tinyTDS database adapter" do
          expect(Sequel).to receive(:tinytds).with hash_including(database: 'test_db')
          Adapter.session(db_schema)
        end

        it "performs preliminary check of database connection" do
          Sequel::TinyTDS::Database.any_instance.should_receive(:test_connection).once
          Adapter.session(db_schema) { |dba| }
        end
      end


      describe '.database' do
        context "within an active session context" do
          before do
            Sequel.stub(:tinytds) { |*args, &block| block.call database }
          end

          it "returns the current open database instance" do
            expect(Adapter.database).to be nil
            Adapter.session db_schema do |db|
              expect(Adapter.database).to_not be nil
              expect(Adapter.database).to be db
              expect(Adapter.database).to be database
            end
            expect(Adapter.database).to be nil
          end
        end

        it "returns nil out of session context" do
          expect(Adapter.database).to be nil
        end
      end
    end
  end
end
