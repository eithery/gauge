# Eithery Lab, 2017
# Gauge::ApplicationHelper specs

require 'spec_helper'

module Gauge
  describe ApplicationHelper do
    let(:root_path) { File.expand_path(File.dirname(__FILE__) + '/../../../../') }

    it { expect(ApplicationHelper).to respond_to :root_path, :db_path }


    describe '.root_path' do
      it "returns the absolute application root path" do
        expect(ApplicationHelper.root_path).to eq root_path
      end
    end


    describe '.db_path' do
      it "returns a default database metadata path" do
        expect(ApplicationHelper.db_path).to eq root_path + '/db'
      end
    end
  end
end
