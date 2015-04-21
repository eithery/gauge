# Eithery Lab., 2015.
# Shared examples for Gauge::DB::Constraints related specs.

module Gauge
  module DB
    module Constraints
      shared_examples_for "a data table constraint" do |options={}|
        its(:name) { should == options[:name] }
        its(:table) { should == options[:table] }
        if options.include? :columns
          its(:columns) { should have(options[:columns].count).columns }
          its(:columns) { should == options[:columns] }
          it { is_expected.to be_composite }
        else
          its(:columns) { should have(1).column }
          its(:columns) { should include(options[:column]) }
          it { is_expected.not_to be_composite }
        end
      end


      shared_examples_for "a primary key" do |options={}|
        it { is_expected.to be_a PrimaryKeyConstraint }
        it_behaves_like "a data table constraint", options
      end


      shared_examples_for "an index" do |options={}|
        it { is_expected.to be_a Gauge::DB::Index }
        it_behaves_like "a data table constraint", options
      end


      shared_examples_for "a unique constraint" do |options={}|
        it { is_expected.to be_a UniqueConstraint }
        it_behaves_like "a data table constraint", options
      end


      shared_examples_for "a foreign key constraint" do |options={}|
        it { is_expected.to be_a ForeignKeyConstraint }
        it_behaves_like "a data table constraint", options
        its(:ref_table) { should == options[:ref_table] }
        if options.include? :columns
          its(:ref_columns) { should have(options[:ref_columns].count).columns }
          its(:ref_columns) { should == options[:ref_columns] }
        else
          its(:ref_columns) { should have(1).column }
          its(:ref_columns) { should include(options[:ref_column]) }
        end
      end
    end
  end
end
