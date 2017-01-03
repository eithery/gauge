# Eithery Lab., 2017
# Gauge::Formatters::ConsoleFormatter specs

require 'spec_helper'

module Gauge
  module Formatters
    include Gauge::Constants

    describe ConsoleFormatter do
      let(:formatter) { ConsoleFormatter.new }

      it { should respond_to :log }
      it { should respond_to :error, :warning, :success, :info }


      describe '#log' do
        it "displays the message in console" do
          expect { formatter.log 'error message' }.to output(/\Aerror message#{CRLF}\z/).to_stdout
        end

        it "removes html tags from displayed messages" do
          expect { formatter.log 'Column <b>account</b> does <b>NOT</b> exist' }
            .to output(/\AColumn account does NOT exist#{CRLF}\z/).to_stdout
        end
      end


      describe '#error' do
        it "displays an error message" do
          formatter.should_receive(:log).with('some message', kind: :error)
          formatter.error 'some message'
        end
      end


      describe '#warning' do
        it "displays a warning message" do
          formatter.should_receive(:log).with('some message', kind: :warning)
          formatter.warning 'some message'
        end
      end


      describe '#success' do
        it "displays a success message" do
          formatter.should_receive(:log).with('some message', kind: :success)
          formatter.success 'some message'
        end
      end


      describe '#info' do
        it "displays an info message" do
          formatter.should_receive(:log).with('some message', kind: :info)
          formatter.info 'some message'
        end
      end
    end
  end
end
