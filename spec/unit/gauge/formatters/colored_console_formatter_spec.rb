# Eithery Lab., 2017.
# Gauge::Formatters::ColoredConsoleFormatter specs.

require 'spec_helper'

module Gauge
  module Formatters
    describe ColoredConsoleFormatter do
      let(:formatter) { ColoredConsoleFormatter.new }

      it { should respond_to :log }


      describe '#log' do
        it "displays the message in console" do
          expect { formatter.log 'error message', severity: :error }.to output(/error message/).to_stdout
        end

        it "displays a non-colored message when severity is not specified" do
          expect { formatter.log 'some message' }.to output(/some message/).to_stdout
        end
      end
    end
  end
end
