# Eithery Lab., 2014.
# Gauge::Helper specs.
require 'spec_helper'

module Gauge
  describe Helper do
    it { should respond_to :application_info }

    shared_examples_for "displaying application header" do
      it "displays name, version and copyright info" do
        helper.should_receive(:info).with(/^Database Gauge. Version \d\.\d\.\d/)
        helper.should_receive(:info).with(/^Eithery Labs\., 2017\./)
        helper.should_receive(:info).with(/usage: gauge \[\-v\|\-\-version\] \[\-h\|\-\-help\]/)
        helper.should_receive(:info).with(/<command> \[<args>\] \[<command options>\]/)
        helper.application_info
      end
    end


    describe '#initialize' do
      it "performs configuring logging infrastructure" do
        global_options = { colored: true }
        Logger.should_receive(:configure).with(global_options)
        Helper.new(global_options)
      end
    end


    describe '#application_info' do
      let(:helper) { Helper.new(@global_options).as_null_object }

      context "with default global options" do
        before { @global_options = {} }
        it_behaves_like "displaying application header"
      end


      context "when short version info requested" do
        before { @global_options = {v: true} }
        it "displays only one-line version info" do
          helper.should_receive(:info).with(/Database Gauge \d\.\d\.\d$/).once
          helper.application_info
        end
      end


      context "when help requested" do
        before { @global_options = {h: true} }
        it_behaves_like "displaying application header"

        it "displays additional detail help information" do
          helper.should_receive(:info).with(/The most commonly used gauge commands are:/)
          helper.should_receive(:info).with(/check/)
          helper.should_receive(:info).with(/help/)
          helper.should_receive(:info).with(/See 'g help <command>' for more information on a specific command.$/)
          helper.application_info
        end
      end
    end
  end
end
