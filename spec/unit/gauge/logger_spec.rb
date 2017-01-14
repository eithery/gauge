# Eithery Lab, 2017
# Gauge::Logger specs

require 'spec_helper'

module Gauge
  describe Logger do
    class LoggerMock
      include Logger
    end

    let(:logger) { LoggerMock.new }
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
        expect(formatter).to receive(:log).with('message', kind: :error).exactly(3).times
        logger.log 'message', kind: :error
      end
    end


    describe '#error' do
      it "logs an error message" do
        expect(logger).to receive(:log).with('message', kind: :error)
        logger.error 'message'
      end
    end


    describe '#warning' do
      it "logs a warning message" do
        expect(logger).to receive(:log).with('message', kind: :warning)
        logger.warning 'message'
      end
    end


    describe '#info' do
      it "logs an info message" do
        expect(logger).to receive(:log).with('message', kind: :info)
        logger.info 'message'
      end
    end


    describe '#ok' do
      it "logs a success message" do
        expect(logger).to receive(:log).with('message', kind: :success)
        logger.ok 'message'
      end
    end


    describe '.configure' do
      context "with :colored option" do
        before { Logger.configure(colored: true) }

        it "configures a colored console formatter" do
          expect(Logger.formatters).to include Formatters::ColoredConsoleFormatter
          expect(Logger.formatters).to have(1).formatter
        end
      end

      context "without :colored option" do
        before { Logger.configure }

        it "configures a simple console formatter" do
          expect(Logger.formatters).to include Formatters::ConsoleFormatter
          expect(Logger.formatters).not_to include Formatters::ColoredConsoleFormatter
        end
      end
    end


    describe '.formatters' do
      subject { Logger.formatters }
      it { is_expected.to have(1).formatter }
    end
  end
end
