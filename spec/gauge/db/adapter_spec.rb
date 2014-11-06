# Eithery Lab., 2014.
# Gauge::DB::Adapter specs.
require 'spec_helper'

module Gauge
  module DB
    describe Adapter do
      subject { Adapter }

      it { should respond_to :session }

      describe '#session' do
        before { stub_db_adapter }

        it "uses tinyTDS database adapter" do
          Sequel.should_receive(:tinytds).with hash_including(database: 'accounts_db')
          Adapter.session('accounts_db')
        end

        it "performs preliminary check of database connection" do
          Sequel::TinyTDS::Database.any_instance.should_receive(:test_connection)
          Adapter.session('accounts_db') { |dba| }
        end
      end
    end
  end
end
