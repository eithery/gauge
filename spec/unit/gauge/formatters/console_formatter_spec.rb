# Eithery Lab., 2014.
# Gauge::Formatters::ConsoleFormatter specs.
require 'spec_helper'

module Gauge
  module Formatters
    describe ConsoleFormatter do
      let(:formatter) { ConsoleFormatter.new }

      it { should respond_to :log }


      describe '#log' do
        it "displays the message in console" do
          expect { formatter.log 'error message' }.to output(/error message/).to_stdout
        end

        it "removes html tags from displayed messages" do
          expect { formatter.log 'Column <b>account</b> does <b>NOT</b> exist' }
            .to output(/Column account does NOT exist/).to_stdout
        end
      end
    end
  end
end
