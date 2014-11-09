# Eithery Lab., 2014.
# Gauge::Schema::MetadataRepo specs.
require 'spec_helper'

module Gauge
  module Schema
    describe MetadataRepo do
      subject { MetadataRepo }

      it { should respond_to :databases, :metadata_home }

      describe 'databases' do
        subject { MetadataRepo.databases }

        context "when no database metadata defined" do
          it { should be_empty }
        end

        context "when any database metadata defined" do
          before { MetadataRepo.databases[:rep_profile] = double('rep_profile_metadata') }

          it { should_not be_empty }
          specify { MetadataRepo.databases.should include(:rep_profile) }
        end
      end


      describe 'metadata_home' do
        it "points to the folder containing metadata files" do
          MetadataRepo.metadata_home.should =~ /gauge\/db\z/
        end
      end
    end
  end
end
