# Eithery Lab., 2014.
# Gauge::Logger specs.
require 'spec_helper'

module Gauge
  describe Logger do
    let(:logger) { Helper.new }
    let(:formatter) do
        formatter = double('formatter')
        Logger.stub(:formatters).and_return([formatter, formatter, formatter])
        formatter
    end

    subject { logger }

    it { should respond_to :log }
    it { should respond_to :error, :warning, :info, :ok }
    specify { Logger.should respond_to :formatters, :configure }


    describe '#log' do
      it "delegates #log calls to registered formatters" do
        formatter.should_receive(:log).with('message', hash_including(severity: :error)).exactly(3).times
        logger.log 'message', severity: :error
      end
    end


    describe '#error' do
      it "calls #log with :error severity" do
        logger.should_receive(:log).with('message', hash_including(severity: :error))
        logger.error 'message'
      end
    end


    describe '#warning' do
      it "calls #log with :warning severity" do
        logger.should_receive(:log).with('message', hash_including(severity: :warning))
        logger.warning 'message'
      end
    end


    describe '#info' do
      it "calls #log with :info severity" do
        logger.should_receive(:log).with('message', hash_including(severity: :info))
        logger.info 'message'
      end
    end


    describe '#ok' do
      it "calls #log with :success severity" do
        logger.should_receive(:log).with('message', hash_including(severity: :success))
        logger.ok 'message'
      end
    end


    describe '.configure' do
      context "with :colored option" do
        before { Logger.configure(colored: true) }

        it "setups colored console formatter" do
          Logger.formatters.should include(Formatters::ColoredConsoleFormatter)
        end
      end

      context "without :colored option" do
        before { Logger.configure }

        it "setups simple console formatter" do
          Logger.formatters.should include(Formatters::ConsoleFormatter)
        end
      end
    end


    describe '.formatters' do
      subject { Logger.formatters }
      it { should have(1).formatter }
    end
  end
end
