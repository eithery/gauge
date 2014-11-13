# Eithery Lab., 2014.
# Gauge::Helper specs.
require 'spec_helper'

module Gauge
  describe Helper do
    it { should respond_to :application_info }


    shared_examples_for "displaying application header" do
      it "displays name, version and copyright info" do
        helper.should_receive(:info).with(/^Database Gauge. Version \d\.\d\.\d/)
        helper.should_receive(:info).with(/Copyright \(C\) M&O Systems, Inc\., 2014\./)
        helper.should_receive(:info).with(/usage: gauge \[\-\-version\|\-v\] \[\-\-help\|\-h\] <command> \[<args>\]/)
        helper.application_info
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
