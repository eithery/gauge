# Eithery Lab., 2017
# Gauge::DB::Connection specs

require 'spec_helper'

module Gauge
  module DB
    describe Connection do
      subject { Connection }

      it { should respond_to :configure }
      it { should respond_to :server, :user, :password }


      describe '#configure' do
        it "configures database connection settings" do
          Connection.configure(server: 'local\SQLDEV', user: 'admin', password: 'secret')

          expect(Connection.server).to eq 'local\SQLDEV'
          expect(Connection.user).to eq 'admin'
          expect(Connection.password).to eq 'secret'
        end
      end
    end
  end
end
