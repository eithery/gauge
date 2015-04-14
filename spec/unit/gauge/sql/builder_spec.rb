# Eithery Lab., 2015.
# Gauge::SQL::Builder specs.

require 'spec_helper'

module Gauge
  module SQL
    describe Builder do
      let(:builder) { Builder.new }
      let(:database_schema) { double('database', sql_name: 'books_n_records') }
      let(:table_schema) { Schema::DataTableSchema.new(:customers, sql_schema: :bnr, database: database_schema) }
      let(:column_schema) { Schema::DataColumnSchema.new(:account_number).in_table table_schema }
      let(:sql_script) do
        "alter table [bnr].[customers]\n\n" +
        "add [account_number] nvarchar(256) null;\n\n" +
        "go"
      end

      subject { builder }

      it { should respond_to :build_sql }
      it { should respond_to :alter_table, :add_column, :alter_column }


      describe '#build_sql' do
        before { File.stub(:open) }

        it "creates SQL home folder if it does not exist" do
          File.stub(:exists? => false)
          Dir.should_receive(:mkdir).with(/\/sql/).exactly(3).times
          build_add_column_sql
        end

        it "creates database folder if it does not exist" do
          File.stub(:exists?).and_return(true, false)
          Dir.should_receive(:mkdir).with(/\/sql\/books_n_records/).exactly(2).times
          build_add_column_sql
        end

        it "creates tables folder if it does not exist" do
          File.stub(:exists?).and_return(true, true, false)
          Dir.should_receive(:mkdir).with(/\/sql\/books_n_records\/tables/).once
          build_add_column_sql
        end

        context "creating migration script file" do
          before { File.stub(:exists?).and_return(true, true, true) }

          context "to create missing data table" do
            it "builds the script file name using 'create' clause and table name combination" do
              File.should_receive(:open).with(/create_bnr_customers.sql/, 'a').once
              builder.build_sql(:create_table, table_schema) do |sql|
              end
            end
          end

          context "to alter existing data table" do
            it "builds the script file name using 'alter' clause and table name combination" do
              File.should_receive(:open).with(/alter_bnr_customers.sql/, 'a').once
              build_add_column_sql
            end
          end
        end

        context "builds correct SQL script" do
          before do
            @file = double('migration_file', puts: nil)
            File.stub(:exists? => true)
            File.stub(:open) do |arg, arg2, &block|
              block.call(@file)
            end
          end

          it "and returns generated script" do
            build_add_column_sql.should == sql_script
          end

          it "and saves SQL script into the file" do
            @file.should_receive(:puts).with(sql_script)
            build_add_column_sql
          end
        end
      end


      describe '#alter_table' do
        it "creates ALTER TABLE SQL clause" do
          builder.alter_table(table_schema).should == ["alter table [bnr].[customers]"]
        end
      end


      describe '#add_column' do
        it "creates SQL statement to add the new data column" do
          (columns + columns_with_defaults).each do |col|
            schema = Schema::DataColumnSchema.new(col[0][0], col[0][1]).in_table table_schema
            Builder.new.add_column(schema).should == ["add #{col[1]}"]
          end
        end
      end


      describe '#alter_column' do
        it "creates SQL statement altering existing data column" do
          columns.each do |col|
            schema = Schema::DataColumnSchema.new(col[0][0], col[0][1]).in_table table_schema
            Builder.new.alter_column(schema).should == ["alter column #{col[1]}"]
          end
        end
      end

  private
  
      def build_add_column_sql
        builder.build_sql(:add_column, column_schema) do |b|
          b.alter_table table_schema
          b.add_column column_schema
        end
      end


      def columns
        [
          [[:last_name, {}],                                        '[last_name] nvarchar(256) null;'],
          [[:rep_code, {len: 10}],                                  '[rep_code] nvarchar(10) null;'],
          [[:description, {len: :max}],                             '[description] nvarchar(max) null;'],
          [[:total_amount, {type: :money}],                         '[total_amount] decimal(18,2) null;'],
          [[:rate, {type: :percent, required: true}],               '[rate] decimal(18,4) not null;'],
          [[:state_code, {type: :us_state}],                        '[state_code] nchar(2) null;'],
          [[:country, {type: :country, required: true}],            '[country] nchar(2) not null;'],
          [[:service_flag, {type: :char}],                          '[service_flag] nchar(1) null;'],
          [[:account_id, {id: true}],                               '[account_id] bigint not null;'],
          [[:total_years, {type: :int, required: true}],            '[total_years] int not null;'],
          [[nil, {id: true}],                                       '[id] bigint not null;'],
          [[nil, {:ref => :primary_reps}],                          '[primary_rep_id] bigint null;'],
          [[:created_at, {}],                                       '[created_at] datetime null;'],
          [[:created_on, {required: true}],                         '[created_on] date not null;'],
          [[:snapshot, {type: :xml}],                               '[snapshot] xml null;'],
          [[:photo, {type: :blob, required: true}],                 '[photo] varbinary(max) not null;'],
          [[:hash_code, {type: :binary, len: 10, required: true}],  '[hash_code] binary(10) not null;'],
          [[:is_active, {}],                                        '[is_active] tinyint null;'],
          [[:status, {type: :short, required: true}],               '[status] smallint not null;'],
          [[:risk_tolerance, {type: :enum, required: true}],        '[risk_tolerance] tinyint not null;']
        ]
      end


      def columns_with_defaults
        [
          [[:is_active, {required: true}], '[is_active] tinyint not null default 0;'],
          [[:status, {type: :short, required: true, default: -1}], '[status] smallint not null default -1;'],
          [[:has_dependents, {required: true, default: true}], '[has_dependents] tinyint not null default 1;'],
          [[:created_on, {required: true, default: {function: :getdate}}],
            '[created_on] date not null default current_timestamp;'],
          [[:rate, {type: :percent, required: true, default: 100.01}],
            '[rate] decimal(18,4) not null default 100.01;'],
          [[:risk_tolerance, {type: :enum, required: true, default: 1}],
            '[risk_tolerance] tinyint not null default 1;'],
          [[:account_number, len: 20, required: true, default: 'A0001'],
            "[account_number] nvarchar(20) not null default 'A0001';"],
          [[:trade_id, {id: true, default: :uid}],
            "[trade_id] bigint not null default abs(convert(bigint,convert(varbinary,newid())));"]
        ]
      end
    end
  end
end
