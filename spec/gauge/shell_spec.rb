# Eithery Lab., 2014.
# Gauge::Shell specs.
require 'spec_helper'

module Gauge
  describe Shell do
    let(:global_options) { {v: true, server: 'local\SQL2012'} }
    let(:options) { {} }
    let(:args) { ['database_name', 'data_table_name'] }

    before { @shell = Shell.new }


    describe '#initialize' do
      it "setups colorful console output" do
        Rainbow.should_receive(:enabled=).with(true)
        Shell.new
      end
    end


    describe '#help' do
      it "delegates call to Helper instance" do
        Helper.any_instance.stub(:puts)
        helper = Helper.new(global_options)
        Helper.should_receive(:new).with(global_options).and_return(helper)
        @shell.help(global_options)
      end
    end


    describe '#check' do
      it "delegates call to DatabaseInspector instance" do
        Repo.any_instance.stub(:puts)
        db_inspector = DatabaseInspector.new(global_options, options, args)
        DatabaseInspector.should_receive(:new).with(global_options, options, args).and_return(db_inspector)
        @shell.check(global_options, options, args)
      end
    end
  end
end
