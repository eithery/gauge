# Eithery Lab., 2014.
# Gauge::Schema::MetadataFactory specs.
require 'spec_helper'

module Gauge
  module Schema
    describe MetadataFactory do
      subject { MetadataFactory }

      it { should respond_to :define_database }

      describe 'define_database' do
        before { Repo.databases.clear }

        it "creates database metadata" do
          DatabaseSchema.should_receive(:new).with(:rep_profile, hash_including(:sql_name))
          MetadataFactory.define_database(:rep_profile, sql_name: 'RepProfile')
        end

        it "register database metadata in the repository" do
          MetadataFactory.define_database(:rep_profile, sql_name: 'RepProfile')
          Repo.databases.should include(:rep_profile)
        end
      end
    end
  end
end
