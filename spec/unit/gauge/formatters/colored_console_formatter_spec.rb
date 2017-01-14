# Eithery Lab, 2017
# Gauge::Formatters::ColoredConsoleFormatter specs

require 'spec_helper'

module Gauge
  module Formatters
    include Gauge::Constants

    describe ColoredConsoleFormatter do
      let(:formatter) { ColoredConsoleFormatter.new }

      it { should respond_to :log }
      it { should respond_to :error, :warning, :success, :info }


      describe '#log' do
        it "displays the message in console" do
          expect { formatter.log 'error message', kind: :error }.to output(/error message/).to_stdout
        end

        it "displays a non-colored message when severity is not specified" do
          expect { formatter.log 'some message' }.to output(/\Asome message#{CRLF}\z/).to_stdout
        end

        it "displays a colored message when severity is specified" do
          expect { formatter.log 'warning message', kind: :warning }
            .to output(/\A#{ESC::YELLOW}warning message#{ESC::RESET}#{CRLF}\z/).to_stdout
        end


        it "displays a hightlighted text within <b> tags" do
          HIGHLIGHTED_TEXT_REGEXP = "#{ESC::RESET}#{ESC::BRIGHT_RED}highlighted#{ESC::RESET}#{ESC::RED}"

          expect { formatter.log "this is a <b>highlighted</b> text", kind: :error }
            .to output(/\A#{ESC::RED}this is a #{HIGHLIGHTED_TEXT_REGEXP} text#{ESC::RESET}#{CRLF}\z/)
            .to_stdout
        end
      end
    end
  end
end
