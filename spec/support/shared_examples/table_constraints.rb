# Eithery Lab., 2015.
# Shared examples for Gauge::DB::Constraints related specs.

module Gauge
  module DB
    module Constraints
      shared_examples_for "a data table constraint" do |options={}|
        it { expect(subject.name).to eq options[:name] }
        it { expect(subject.table).to eq options[:table] }
        if options.include? :columns
          it { expect(subject.columns).to have(options[:columns].count).columns }
          it { expect(subject.columns).to eq options[:columns] }
          it { is_expected.to be_composite }
        else
          it { expect(subject.columns).to have(1).column }
          it { expect(subject.columns).to include(options[:column]) }
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
        it { expect(subject.ref_table).to eq options[:ref_table] }
        if options.include? :columns
          it { expect(subject.ref_columns).to have(options[:ref_columns].count).columns }
          it { expect(subject.ref_columns).to eq options[:ref_columns] }
        else
          it { expect(subject.ref_columns).to have(1).column }
          it { expect(subject.ref_columns).to include options[:ref_column] }
        end
      end
    end
  end
end
