# Eithery Lab., 2014.
# Gauge::DB::Connection specs.
require 'spec_helper'

module Gauge
  module DB
    describe Connection do
      subject { Connection }

      it { should respond_to :configure }
      it { should respond_to :server, :user, :password }

      describe '#configure' do
        it "configures database connection settings" do
          Connection.configure(server: 'local\SQL2012', user: 'admin', password: 'secret')
          Connection.server.should == 'local\SQL2012'
          Connection.user.should == 'admin'
          Connection.password.should == 'secret'
        end
      end
    end
  end
end
