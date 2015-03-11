# Eithery Lab., 2015.
# Class Gauge::Helpers::NameParser specs.

require 'spec_helper'

module Gauge
  module Helpers
    describe NameParser do
      subject { NameParser }

      it { should respond_to :local_name }
      it { should respond_to :sql_schema }
      it { should respond_to :dbo_key }


      describe '.local_name' do
        it "extracts the local part of a database object name" do
          (dbo_default_names + dbo_custom_names).each do |dbo_name|
            NameParser.local_name(dbo_name.downcase).should == 'reps'
          end
        end
      end


      describe '.sql_schema' do
        context "for default SQL schema (dbo)" do
          it "returns 'dbo' as SQL schema" do
            dbo_default_names.each { |dbo_name| NameParser.sql_schema(dbo_name).should == 'dbo' }
          end
        end

        context "for custom SQL schema" do
          it "extracts SQL schema part from a database object name" do
            dbo_custom_names.each { |dbo_name| NameParser.sql_schema(dbo_name.downcase).should == 'bnr' }
          end
        end
      end


      describe '.dbo_key' do
        context "for default SQL schema (dbo)" do
          it "returns a database object name with 'dbo' SQL schema converted to symbol" do
            dbo_default_names.each { |dbo_name| NameParser.dbo_key(dbo_name).should == :dbo_reps }
          end
        end

        context "for custom SQL schema" do
          it "returns a database object name with custom SQL schema converted to symbol" do
            dbo_custom_names.each { |dbo_name| NameParser.dbo_key(dbo_name).should == :bnr_reps }
          end
        end
      end

  private

      def dbo_default_names
        ['REPS', 'dbo.reps', '"dbo"."reps"', '[dbo].[reps]', '[reps]', '[rep_profile].[dbo].[reps]', :reps,
          'rep_profile..reps']
      end


      def dbo_custom_names
        ['Bnr.RepS', '"bnr"."reps"', '[bnr].[reps]', '[rep_profile].[bnr].[reps]', 'rep_profile.bnr.reps']
      end
    end
  end
end
