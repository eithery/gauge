# Eithery Lab, 2017
# Gauge::SQL::Builder specs

require 'spec_helper'

module Gauge
  module SQL
    describe Builder do
      let(:builder) { Builder.new }
      let(:table_schema) { Schema::DataTableSchema.new(:customers, sql_schema: :bnr, db: :test_db) }
      let(:column_schema) { Schema::DataColumnSchema.new(:account_number).in_table table_schema }

      it { should respond_to :cleanup }
      it { should respond_to :create_table }
      it { should respond_to :add_column, :alter_column }
      it { should respond_to :drop_constraint }
      it { should respond_to :add_primary_key }
      it { should respond_to :add_foreign_key }
      it { should respond_to :add_unique_constraint }
      it { should respond_to :create_index, :drop_index }
      it { should respond_to :build_sql }
      it { should respond_to :sql_home }


      describe '#sql_home' do
        it "returns a default path for generated SQL code" do
          expect(builder.sql_home).to eq ApplicationHelper.sql_home
        end

        context "when SQL home folder does not exist" do
          before { File.stub(:exists?).and_return false }

          it "creates a folder" do
            expect(Dir).to receive(:mkdir).with(ApplicationHelper.sql_home)
            builder.sql_home
          end
        end

        context "when SQL home folder exists" do
          before { File.stub(:exists?).and_return true }

          it "does not create a folder" do
            expect(Dir).to_not receive(:mkdir).with(ApplicationHelper.sql_home)
            builder.sql_home
          end
        end
      end


      describe '#cleanup' do
        before { Dir.stub(:mkdir) }

        it "delegates delete SQL files operation to a schema" do
          schema = double('schema')
          expect(schema).to receive(:cleanup_sql_files).with(builder.sql_home)
          builder.cleanup(schema)
        end
      end


      describe "(SQL generation methods)" do
        before do
          Dir.stub(:mkdir)
          File.stub(:open)
        end

        describe '#create_table' do
          it "builds SQL statement creating a new data table" do
            builder.create_table table_schema
            sql = builder.build_sql table_schema
            expect(sql).to eq "create table bnr.customers\n(\n);\ngo\n"
          end
        end


        describe '#add_column' do
          it "builds SQL statement adding a new data column" do
            all_columns.each { |col| builder.add_column(column_schema(col, table_schema)) }
            sql = builder.build_sql table_schema
            all_columns.each { |col| expect(sql).to include("alter table bnr.customers\nadd #{col[1]}\ngo\n") }
          end
        end


        describe '#alter_column' do
          it "builds SQL statement altering an existing data column" do
            columns.each { |col| builder.alter_column(column_schema(col, table_schema)) }
            sql = builder.build_sql table_schema
            columns.each { |col| expect(sql).to include("alter table bnr.customers\nalter column #{col[1]}\ngo\n") }
          end
        end


        describe '#drop_constraint' do
          let(:constraint) { double('constraint', name: 'PK_customers_id', to_sym: :pk_customers_id) }

          it "builds SQL statement dropping DB constraint on data table" do
            builder.drop_constraint constraint
            sql = builder.build_sql table_schema
            expect(sql).to eq "alter table bnr.customers\ndrop constraint PK_customers_id;\ngo\n"
          end
        end


        describe '#add_primary_key' do
          context "for a clustered primary key" do
            let(:primary_key) do
              Gauge::DB::Constraints::PrimaryKeyConstraint.new('PK_customers_id', table: 'bnr.customers', columns: :id)
            end
            it "builds SQL statement creating a primary key" do
              expect(target_sql).to eq "alter table bnr.customers\nadd primary key (id);\ngo\n"
            end
          end

          context "for a nonclustered primary key" do
            let(:primary_key) do
              Gauge::DB::Constraints::PrimaryKeyConstraint.new('PK_customers_id',
                table: 'bnr.customers', columns: :id, clustered: false)
            end
            it "builds SQL statement creating a primary key" do
              expect(target_sql).to eq "alter table bnr.customers\nadd primary key nonclustered (id);\ngo\n"
            end
          end

          context "for a composite primary key" do
            let(:primary_key) do
              Gauge::DB::Constraints::PrimaryKeyConstraint.new('PK_customers_id',
                table: 'bnr.customers', columns: [:fund_account_number, :cusip])
            end
            it "builds SQL statement creating a primary key" do
              expect(target_sql).to eq "alter table bnr.customers\nadd primary key (fund_account_number, cusip);\ngo\n"
            end
          end

          def target_sql
            builder.add_primary_key primary_key
            sql = builder.build_sql table_schema
          end
        end


        describe '#add_foreign_key' do
          let(:foreign_key) do
            Gauge::DB::Constraints::ForeignKeyConstraint.new('FK_dbo_accounts_rep_code',
              table: 'bnr.customers', columns: :rep_code, ref_table: 'bnr.reps', ref_columns: :code)
          end
          it "builds SQL creating a new foreign key" do
            builder.add_foreign_key foreign_key
            sql = builder.build_sql table_schema
            expect(sql).to eq "alter table bnr.customers with check\n" +
              "add foreign key (rep_code) references bnr.reps (code);\ngo\n"
          end
        end


        describe '#add_unique_constraint' do
          context "for a regular (one column) unique constraint" do
            let(:unique_constraint) do
              Gauge::DB::Constraints::UniqueConstraint.new('UK_bnr_customers',
                table: 'bnr.customers', columns: :CRD_number)
            end
            it "builds SQL creating a new unique constraint" do
              builder.add_unique_constraint unique_constraint
              sql = builder.build_sql table_schema
              expect(sql).to eq "alter table bnr.customers\nadd unique (crd_number);\ngo\n"
            end
          end

          context "for a composite unique constraint" do
            let(:unique_constraint) do
              Gauge::DB::Constraints::UniqueConstraint.new('UK_bnr_customers',
                table: 'bnr.customers', columns: [:tax_ID, :tax_id_type])
            end
            it "builds SQL creating a new unique constraint" do
              builder.add_unique_constraint unique_constraint
              sql = builder.build_sql table_schema
              expect(sql).to eq "alter table bnr.customers\nadd unique (tax_id, tax_id_type);\ngo\n"
            end
          end
        end


        describe '#create_index' do
          context "for a regular not unique index" do
            let(:index) { Gauge::DB::Index.new('IDX_bnr_customers_tax_id', table: 'bnr.customers', columns: :tax_ID) }

            it "builds SQL creating a new index" do
              expect(target_sql).to eq "create index IDX_bnr_customers_tax_id on bnr.customers (tax_id);\ngo\n"
            end
          end

          context "for a clustered index" do
            let(:index) do
              Gauge::DB::Index.new('idx_bnr_customers_tax_id', table: 'bnr.customers',
                columns: :tax_ID, clustered: true)
            end

            it "builds SQL creating a new unique clustered index" do
              expect(target_sql).to eq "create unique clustered index idx_bnr_customers_tax_id " +
                "on bnr.customers (tax_id);\ngo\n"
            end
          end

          context "for an unique index" do
            let(:index) do
              Gauge::DB::Index.new('idx_bnr_customers_tax_id', table: 'bnr.customers',
                columns: :tax_ID, unique: true)
            end

            it "builds SQL creating a new unique index" do
              expect(target_sql).to eq "create unique index idx_bnr_customers_tax_id " +
                "on bnr.customers (tax_id);\ngo\n"
            end
          end

          context "for a composite index" do
            let(:index) do
              Gauge::DB::Index.new('idx_bnr_customers_tax_id', table: 'bnr.customers',
                columns: [:tax_ID, :tax_id_type])
            end

            it "builds SQL creating a new composite index" do
              expect(target_sql).to eq "create index idx_bnr_customers_tax_id on bnr.customers " +
                "(tax_id, tax_id_type);\ngo\n"
            end
          end

          def target_sql
            builder.create_index index
            sql = builder.build_sql table_schema
          end
        end


        describe '#drop_index' do
          let(:index) { Gauge::DB::Index.new('IDX_bnr_customers_tax_id', table: 'bnr.customers', columns: :tax_ID) }

          it "builds SQL droping an index" do
            builder.drop_index index
            sql = builder.build_sql table_schema
            expect(sql).to eq "drop index IDX_bnr_customers_tax_id on bnr.customers;\ngo\n"
          end
        end


        def column_schema(col, table_schema)
          Schema::DataColumnSchema.new(col[0][0], col[0][1]).in_table table_schema
        end
      end


      describe '#build_sql' do
        before { File.stub(:open) }

        context "determining a target folder for SQL script" do
          before { builder.add_column column_schema }

          it "creates SQL home folder if it does not exist" do
            File.stub(:exists? => false)
            expect(Dir).to receive(:mkdir).with(/\/sql/).exactly(3).times
            builder.build_sql table_schema
          end

          it "creates a database folder if it does not exist" do
            File.stub(:exists?).and_return(true, false)
            expect(Dir).to receive(:mkdir).with(/\/sql\/test_db/).exactly(2).times
            builder.build_sql table_schema
          end

          it "creates a tables folder if it does not exist" do
            File.stub(:exists?).and_return(true, true, false)
            expect(Dir).to receive(:mkdir).with(/\/sql\/test_db\/tables/).once
            builder.build_sql table_schema
          end
        end


        context "creating a migration script file" do
          before { File.stub(:exists?).and_return(true, true, true) }

          context "for a missing data table" do
            before { builder.create_table table_schema }

            it "builds a script file name using 'create' clause and table name combination" do
              expect(File).to receive(:open).with(/create_bnr_customers.sql/, 'a').once
              builder.build_sql table_schema
            end
          end

          context "for an existing data table" do
            before { builder.add_column column_schema }

            it "builds a script file name using 'alter' clause and table name combination" do
             expect(File).to receive(:open).with(/alter_bnr_customers.sql/, 'a').once
              builder.build_sql table_schema
            end
          end
        end

        context "builds a correct SQL script" do
          let!(:file) do
            file = double('sql_file', puts: nil)
            File.stub(:exists? => true)
            File.stub(:open) do |arg, arg2, &block|
              block.call(file)
            end
            builder.add_column column_schema
            file
          end

          it "and returns a generated script" do
            expect(builder.build_sql(table_schema)).to eq sql_script
          end

          it "and saves SQL script into a file" do
            expect(file).to receive(:puts).with(sql_script)
            builder.build_sql table_schema
          end

          def sql_script
            "alter table bnr.customers\n" +
            "add account_number nvarchar(255) null;\n" +
            "go\n"
          end
        end
      end


  private

      def all_columns
        columns + columns_with_defaults
      end


      def columns
        [
          [[:last_name, {}],                                          'last_name nvarchar(255) null;'],
          [[:rep_code, { len: 10 }],                                  'rep_code nvarchar(10) null;'],
          [[:description, { len: :max }],                             'description nvarchar(max) null;'],
          [[:total_amount, { type: :money }],                         'total_amount decimal(18,2) null;'],
          [[:rep_rate, { type: :percent, required: true }],           'rep_rate decimal(18,4) not null;'],
          [[:state_code, { type: :us_state }],                        'state_code nchar(2) null;'],
          [[:country, { type: :country, required: true }],            'country nchar(2) not null;'],
          [[:service_flag, { type: :char }],                          'service_flag nchar(1) null;'],
          [[:account_id, { id: true }],                               'account_id bigint not null;'],
          [[:total_years, { type: :int, required: true }],            'total_years int not null;'],
          [[nil, { id: true }],                                       'id bigint not null;'],
          [[nil, { :ref => :primary_reps }],                          'primary_rep_id bigint null;'],
          [[:created_at, {}],                                         'created_at datetime null;'],
          [[:created_on, { required: true }],                         'created_on date not null;'],
          [[:snapshot, { type: :xml }],                               'snapshot xml null;'],
          [[:photo, { type: :blob, required: true }],                 'photo varbinary(max) not null;'],
          [[:hash_code, { type: :binary, len: 10, required: true }],  'hash_code binary(10) not null;'],
          [[:is_enabled, {}],                                         'is_enabled tinyint null;'],
          [[:batch_state, { type: :short, required: true }],          'batch_state smallint not null;'],
          [[:time_horizon, { type: :enum, required: true }],          'time_horizon tinyint not null;']
        ]
      end


      def columns_with_defaults
        [
          [[:is_active, { required: true }], 'is_active tinyint not null default 0;'],
          [[:status, { type: :short, required: true, default: -1 }], 'status smallint not null default -1;'],
          [[:has_dependents, { required: true, default: true }], 'has_dependents tinyint not null default 1;'],
          [[:updated_on, { required: true, default: { function: :getdate }}],
            'updated_on date not null default current_timestamp;'],
          [[:rate, { type: :percent, required: true, default: 100.01 }],
            'rate decimal(18,4) not null default 100.01;'],
          [[:risk_tolerance, { type: :enum, required: true, default: 1 }],
            'risk_tolerance tinyint not null default 1;'],
          [[:account_number, len: 20, required: true, default: 'A0001'],
            "account_number nvarchar(20) not null default 'A0001';"],
          [[:trade_id, { id: true, default: :uid }],
            "trade_id bigint not null default abs(convert(bigint,convert(varbinary,newid())));"]
        ]
      end
    end
  end
end
