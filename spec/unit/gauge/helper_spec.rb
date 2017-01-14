# Eithery Lab, 2017
# Gauge::Helper specs

require 'spec_helper'

module Gauge
  describe Helper do
    let(:helper) { Helper.new(@options).as_null_object }

    it { should respond_to :application_info }

    shared_examples_for "displaying application header" do
      it "displays name, version, and usage info" do
        expect(helper).to receive(:info).with(/Gauge. Version/) do |message|
          expect(message).to match /\AGauge. Version \d\.\d\.\d/
          expect(message).to match /^SQL server database command line tool/
          expect(message).to match /^Eithery Labs\., 2017/
          expect(message).to match /^usage: gauge \[\-v\|\-\-version\] \[\-h\|\-\-help\]/
          expect(message).to match /<command> \[<args>\] \[<command options>\]/
        end
        helper.application_info
      end
    end


    describe '#initialize' do
      it "configures logging infrastructure" do
        expect(Logger).to receive(:configure).with(colored: true)
        Helper.new(colored: true)
      end
    end


    describe '#application_info' do
      context "with default global options" do
        before { @options = {} }
        it_behaves_like "displaying application header"
      end


      context "when short version info requested" do
        before { @options = { v: true }}

        it "displays one-line version info" do
          expect(helper).to receive(:info).with(/\AGauge \d\.\d\.\d\z/).once
          helper.application_info
        end
      end


      context "when help requested" do
        before { @options = { h: true }}

        it_behaves_like "displaying application header"

        it "displays additional help detail information" do
          expect(helper).to receive(:info).with(/gauge commands/) do |message|
            expect(message).to match /^The most commonly used gauge commands are:/
            expect(message).to match /check/
            expect(message).to match /help/
            expect(message).to match /^See 'gauge help <command>' for more information on a specific command.$/
          end
          helper.application_info
        end
      end
    end
  end
end
