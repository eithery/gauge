# Eithery Lab., 2014.
# Gauge::Logger specs.
require 'spec_helper'

module Gauge
  describe Logger do
    let(:logger) { Helper.new }
    let(:formatter) do
        formatter = double('formatter')
        logger.stub(:formatters).and_return([formatter, formatter, formatter])
        formatter
    end

    subject { logger }

    it { should respond_to :log, :with_log }
    it { should respond_to :error, :warning, :info, :ok }


    describe '#log' do
      it "delegates #log calls to registered formatters" do
        formatter.should_receive(:log).with('message', hash_including(severity: :error)).exactly(3).times
        logger.log 'message', severity: :error
      end
    end


    describe '#with_log' do
      it "delegates #with_log calls to registered formatters" do
        formatter.should_receive(:with_log).with('message', hash_including(severity: :error)).exactly(3).times
        logger.with_log 'message', { severity: :error } {  }
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
  end
end
