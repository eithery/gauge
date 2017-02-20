# Eithery Lab, 2017
# Gauge::ApplicationHelper specs

require 'spec_helper'

module Gauge
  describe ApplicationHelper do
    let(:root_path) { File.expand_path('../../../../../', __FILE__) }

    it { expect(ApplicationHelper).to respond_to :root_path, :db_home, :sql_home }


    describe '.root_path' do
      it "returns an absolute application root path" do
        expect(ApplicationHelper.root_path).to eq root_path
        expect(ApplicationHelper.root_path).to match /\/gauge\z/
      end
    end


    describe '.db_home' do
      it "returns a default path for database metadata" do
        expect(ApplicationHelper.db_home).to eq root_path + '/db'
        expect(ApplicationHelper.db_home).to match /\/gauge\/db\z/
      end
    end


    describe '.sql_home' do
      it "returns a default path for generated SQL code" do
        expect(ApplicationHelper.sql_home).to eq root_path + '/sql'
        expect(ApplicationHelper.sql_home).to match /\/gauge\/sql\z/
      end
    end
  end
end
