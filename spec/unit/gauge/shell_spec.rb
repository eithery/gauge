# Eithery Lab, 2017
# Gauge::Shell specs

require 'spec_helper'

module Gauge
  describe Shell do
    let(:options) {{ v: true, server: 'local\SQLDEV' }}
    subject(:shell) { Shell.new }

    it { should respond_to :help, :check }


    describe '#initialize' do
      it "colorizes console output" do
        expect(Rainbow).to receive(:enabled=).with(true)
        Shell.new
      end
    end


    describe '#help' do
      it "delegates call to Helper instance" do
        helper = Helper.new(options)
        helper.stub(:info)

        expect(Helper).to receive(:new).with(options).and_return(helper)
        expect(helper).to receive(:application_info)
        shell.help(options)
      end
    end


    describe '#check' do
      let(:args) { ['data_table_name'] }

      it "delegates calls to database inspector instance" do
        inspector = Inspector.new(options)
        inspector.stub(:check)

        expect(Inspector).to receive(:new).with(options).and_return(inspector)
        expect(inspector).to receive(:check).with(args)
        shell.check(options, args)
      end
    end
  end
end
