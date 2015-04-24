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

      subject { builder }

      it { should respond_to :cleanup }
      it { should respond_to :create_table }
      it { should respond_to :add_column, :alter_column }
      it { should respond_to :drop_constraint }
      it { should respond_to :add_primary_key }
      it { should respond_to :add_foreign_key }
      it { should respond_to :add_unique_constraint }
      it { should respond_to :create_index, :drop_index }
      it { should respond_to :build_sql }


      describe '#cleanup' do
        before do
          Dir.stub(:mkdir)
          @database = Gauge::Schema::DatabaseSchema.new('rep_profile')
        end

        context "before database validation check" do
          it "deletes all SQL migration files belong to the database to be checked" do
            FileUtils.should_receive(:remove_dir).once.with(/\/sql\/rep_profile/, hash_including(force: true))
            builder.cleanup @database
          end
        end

        context "before data table validation check" do
          before { @data_table = Gauge::Schema::DataTableSchema.new(:reps, database: @database) }

          it "deletes all SQL migration files belong to the data table to be checked" do
            FileUtils.should_receive(:remove_file).with(/\/sql\/rep_profile\/tables\/create_dbo_reps.sql/,
              hash_including(force: true)).once
            FileUtils.should_receive(:remove_file).with(/\/sql\/rep_profile\/tables\/alter_dbo_reps.sql/,
              hash_including(force: true)).once
            builder.cleanup @data_table
          end
        end
      end


      describe "(SQL generation methods)" do
        before do
          Dir.stub(:mkdir)
          File.stub(:open)
        end

        describe '#create_table' do
          it "builds SQL statement creating the new data table" do
            builder.create_table table_schema
            sql = builder.build_sql table_schema
            sql.should == "create table bnr.customers\n(\n);\ngo\n"
          end
        end


        describe '#add_column' do
          it "builds SQL statement adding the new data column" do
            all_columns.each { |col| builder.add_column(column_schema(col, table_schema)) }
            sql = builder.build_sql table_schema
            all_columns.each { |col| sql.should include("alter table bnr.customers\nadd #{col[1]}\ngo\n") }
          end
        end


        describe '#alter_column' do
          it "builds SQL statement altering existing data column" do
            columns.each { |col| builder.alter_column(column_schema(col, table_schema)) }
            sql = builder.build_sql table_schema
            columns.each { |col| sql.should include("alter table bnr.customers\nalter column #{col[1]}\ngo\n") }
          end
        end


        describe '#drop_constraint' do
          before { @constraint = double('constraint', name: 'PK_customers_id', to_sym: :pk_customers_id) }

          it "builds SQL statement dropping DB constraint on data table" do
            builder.drop_constraint @constraint
            sql = builder.build_sql table_schema
            sql.should == "alter table bnr.customers\ndrop constraint PK_customers_id;\ngo\n"
          end
        end


        describe '#add_primary_key' do
          context "for clustered primary key" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('PK_customers_id', 'bnr.customers', :id)
            end
            it "builds correct SQL statement creating the primary key" do
              target_sql.should == "alter table bnr.customers\nadd primary key (id);\ngo\n"
            end
          end

          context "for nonclustered primary key" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('PK_customers_id',
                'bnr.customers', :id, clustered: false)
            end
            it "builds correct SQL statement creating the primary key" do
              target_sql.should == "alter table bnr.customers\nadd primary key nonclustered (id);\ngo\n"
            end
          end

          context "for composite primary key" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('PK_customers_id',
                'bnr.customers', [:fund_account_number, :cusip])
            end
            it "builds correct SQL statement creating the primary key" do
              target_sql.should == "alter table bnr.customers\nadd primary key (fund_account_number, cusip);\ngo\n"
            end
          end

          def target_sql
            builder.add_primary_key @primary_key
            sql = builder.build_sql table_schema
          end
        end


        describe '#add_foreign_key' do
          before do
            @foreign_key = Gauge::DB::Constraints::ForeignKeyConstraint.new('FK_dbo_accounts_rep_code',
              'bnr.customers', :rep_code, 'bnr.reps', :code)
          end
          it "builds SQL creating new foreign key" do
            builder.add_foreign_key @foreign_key
            sql = builder.build_sql table_schema
            sql.should == "alter table bnr.customers with check\n" +
              "add foreign key (rep_code) references bnr.reps (code);\ngo\n"
          end
        end


        describe '#add_unique_constraint' do
          context "for regular (one column) unique constraint" do
            before do
              @unique_constraint = Gauge::DB::Constraints::UniqueConstraint.new('UK_bnr_customers',
                'bnr.customers', :CRD_number)
            end
            it "builds SQL creating new unique constraint" do
              builder.add_unique_constraint @unique_constraint
              sql = builder.build_sql table_schema
              sql.should == "alter table bnr.customers\nadd unique (crd_number);\ngo\n"
            end
          end

          context "for composite unique constraint" do
            before do
              @unique_constraint = Gauge::DB::Constraints::UniqueConstraint.new('UK_bnr_customers',
                'bnr.customers', [:tax_ID, :tax_id_type])
            end
            it "builds SQL creating new unique constraint" do
              builder.add_unique_constraint @unique_constraint
              sql = builder.build_sql table_schema
              sql.should == "alter table bnr.customers\nadd unique (tax_id, tax_id_type);\ngo\n"
            end
          end
        end


        describe '#create_index' do
          context "for regular not unique index" do
            before { @index = Gauge::DB::Index.new('IDX_bnr_customers_tax_id', 'bnr.customers', :tax_ID) }

            it "builds SQL creating new index" do
              target_sql.should == "create index IDX_bnr_customers_tax_id on bnr.customers (tax_id);\ngo\n"
            end
          end

          context "for clustered index" do
            before do
              @index = Gauge::DB::Index.new('idx_bnr_customers_tax_id', 'bnr.customers', :tax_ID, clustered: true)
            end

            it "builds SQL creating new unique clustered index" do
              target_sql.should == "create unique clustered index idx_bnr_customers_tax_id " +
                "on bnr.customers (tax_id);\ngo\n"
            end
          end

          context "for unique index" do
            before do
              @index = Gauge::DB::Index.new('idx_bnr_customers_tax_id', 'bnr.customers', :tax_ID, unique: true)
            end

            it "builds SQL creating new unique index" do
              target_sql.should == "create unique index idx_bnr_customers_tax_id " +
                "on bnr.customers (tax_id);\ngo\n"
            end
          end

          context "for composite index" do
            before do
              @index = Gauge::DB::Index.new('idx_bnr_customers_tax_id', 'bnr.customers', [:tax_ID, :tax_id_type])
            end

            it "builds SQL creating new composite index" do
              target_sql.should == "create index idx_bnr_customers_tax_id on bnr.customers " +
                "(tax_id, tax_id_type);\ngo\n"
            end
          end

          def target_sql
            builder.create_index @index
            sql = builder.build_sql table_schema
          end
        end


        describe '#drop_index' do
          before { @index = Gauge::DB::Index.new('IDX_bnr_customers_tax_id', 'bnr.customers', :tax_ID) }

          it "builds SQL droping index" do
            builder.drop_index @index
            sql = builder.build_sql table_schema
            sql.should == "drop index IDX_bnr_customers_tax_id on bnr.customers;\ngo\n"
          end
        end


        def column_schema(col, table_schema)
          Schema::DataColumnSchema.new(col[0][0], col[0][1]).in_table table_schema
        end
      end


      describe '#build_sql' do
        before { File.stub(:open) }

        context "determining the target folder for SQL script" do
          before { builder.add_column column_schema }

          it "creates SQL home folder if it does not exist" do
            File.stub(:exists? => false)
            Dir.should_receive(:mkdir).with(/\/sql/).exactly(3).times
            builder.build_sql table_schema
          end

          it "creates database folder if it does not exist" do
            File.stub(:exists?).and_return(true, false)
            Dir.should_receive(:mkdir).with(/\/sql\/books_n_records/).exactly(2).times
            builder.build_sql table_schema
          end

          it "creates tables folder if it does not exist" do
            File.stub(:exists?).and_return(true, true, false)
            Dir.should_receive(:mkdir).with(/\/sql\/books_n_records\/tables/).once
            builder.build_sql table_schema
          end
        end


        context "creating migration script file" do
          before { File.stub(:exists?).and_return(true, true, true) }

          context "for missing data table" do
            before { builder.create_table table_schema }

            it "builds the script file name using 'create' clause and table name combination" do
              File.should_receive(:open).with(/create_bnr_customers.sql/, 'a').once
              builder.build_sql table_schema
            end
          end

          context "for existing data table" do
            before { builder.add_column column_schema }

            it "builds the script file name using 'alter' clause and table name combination" do
              File.should_receive(:open).with(/alter_bnr_customers.sql/, 'a').once
              builder.build_sql table_schema
            end
          end
        end

        context "builds correct SQL script" do
          before do
            @file = double('sql_file', puts: nil)
            File.stub(:exists? => true)
            File.stub(:open) do |arg, arg2, &block|
              block.call(@file)
            end
            builder.add_column column_schema
          end

          it "and returns generated script" do
            builder.build_sql(table_schema).should == sql_script
          end

          it "and saves SQL script into the file" do
            @file.should_receive(:puts).with(sql_script)
            builder.build_sql table_schema
          end

          def sql_script
            "alter table bnr.customers\n" +
            "add account_number nvarchar(256) null;\n" +
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
          [[:last_name, {}],                                        'last_name nvarchar(256) null;'],
          [[:rep_code, {len: 10}],                                  'rep_code nvarchar(10) null;'],
          [[:description, {len: :max}],                             'description nvarchar(max) null;'],
          [[:total_amount, {type: :money}],                         'total_amount decimal(18,2) null;'],
          [[:rep_rate, {type: :percent, required: true}],           'rep_rate decimal(18,4) not null;'],
          [[:state_code, {type: :us_state}],                        'state_code nchar(2) null;'],
          [[:country, {type: :country, required: true}],            'country nchar(2) not null;'],
          [[:service_flag, {type: :char}],                          'service_flag nchar(1) null;'],
          [[:account_id, {id: true}],                               'account_id bigint not null;'],
          [[:total_years, {type: :int, required: true}],            'total_years int not null;'],
          [[nil, {id: true}],                                       'id bigint not null;'],
          [[nil, {:ref => :primary_reps}],                          'primary_rep_id bigint null;'],
          [[:created_at, {}],                                       'created_at datetime null;'],
          [[:created_on, {required: true}],                         'created_on date not null;'],
          [[:snapshot, {type: :xml}],                               'snapshot xml null;'],
          [[:photo, {type: :blob, required: true}],                 'photo varbinary(max) not null;'],
          [[:hash_code, {type: :binary, len: 10, required: true}],  'hash_code binary(10) not null;'],
          [[:is_enabled, {}],                                       'is_enabled tinyint null;'],
          [[:batch_state, {type: :short, required: true}],          'batch_state smallint not null;'],
          [[:time_horizon, {type: :enum, required: true}],          'time_horizon tinyint not null;']
        ]
      end


      def columns_with_defaults
        [
          [[:is_active, {required: true}], 'is_active tinyint not null default 0;'],
          [[:status, {type: :short, required: true, default: -1}], 'status smallint not null default -1;'],
          [[:has_dependents, {required: true, default: true}], 'has_dependents tinyint not null default 1;'],
          [[:updated_on, {required: true, default: {function: :getdate}}],
            'updated_on date not null default current_timestamp;'],
          [[:rate, {type: :percent, required: true, default: 100.01}],
            'rate decimal(18,4) not null default 100.01;'],
          [[:risk_tolerance, {type: :enum, required: true, default: 1}],
            'risk_tolerance tinyint not null default 1;'],
          [[:account_number, len: 20, required: true, default: 'A0001'],
            "account_number nvarchar(20) not null default 'A0001';"],
          [[:trade_id, {id: true, default: :uid}],
            "trade_id bigint not null default abs(convert(bigint,convert(varbinary,newid())));"]
        ]
      end
    end
  end
end
