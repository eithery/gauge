# Eithery Lab., 2014.
# Gauge::DatabaseInspector specs.
require 'spec_helper'

module Gauge
  describe DatabaseInspector do
    let(:inspector) { DatabaseInspector.new({}, {}, ['accounts_db', 'reps_db']) }
    subject { inspector }

    it { should respond_to :check }


    describe '#initialize' do
      it "performs configuring of connection settings" do
        global_options = { server: 'local\SQL2012', user: 'admin' }
        DB::Connection.should_receive(:configure).with(hash_including(global_options)).once
        DatabaseInspector.new(global_options, {}, [])
      end
    end


    describe '#check' do
      it "performs validation for each data object passed as an argument" do
        repo = Repo.new
        Repo.stub(:new).and_return(repo)
        repo.should_receive(:validate).with(/accounts_db|reps_db/).twice
        inspector.check
      end

      it "displays an error when no arguments specified" do
        inspector = DatabaseInspector.new({}, {}, [])
        inspector.should_receive(:error).with(/no database objects specified/i)
        inspector.check
      end
    end
  end
end
