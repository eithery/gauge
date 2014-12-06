# Data table definition file.
# dbo.comm_load
# Contains loaded commision records.

table :comm_load do
  col :load_id, type: :int, id: true, identity: true
  col :trade_id, type: :int
  col :batch_id, len: 20

  col :carrier_id, len: 6
  col :product_cusip, len: 9
  col :product_name, len: 30
  col :pr_type_code, len: 5
  col :fund_account, len: 20, index: true
  col :fund_account_original, len: 20
  col :bin, len: 20
  col :cust_ssn, len: 15
  col :cust_name, len: 80
  col :cust_fname, len: 25
  col :cust_dob, type: :datetime
  col :cust_state, type: :us_state
  col :source_id, type: :int
  col :source, len: 4
  col :state_sale, type: :us_state
  col :social_code, len: 2

  col :branch_code, len: 10
  col :rep_code, len: 100
  col :rep_name

  col :load_date
  col :trade_date
  col :settle_date
  col :issue_date, type: :datetime

  col :gross_amount, type: :money
  col :comm_rate, type: :percent
  col :dealer_comm, type: :money
  col :rep_comm, type: :money
  col :account_aum, type: :money
  col :household_aum, type: :money
  col :proration_ratio, type: :percent
  col :pay_rep_of_order, type: :bool, required: true
  col :auto_match_exception, len: :max

  col :service_start_date
  col :service_end_date

  col :account_ind, type: :char
  col :purchase_code, type: :char
  col :quantity, type: :money
  col :comm_type_old, len: 2
  col :file_id, type: :int
  col :fund_process_date
  col :settle_test_flag, type: :char
  col :cust_alast, len: 35
  col :cust_afirst, len: 25
  col :cust_assn, len: 9
  col :cust_adob, type: :datetime
  col :comm_type, len: 3
  col :rec_comm_amount, type: :money
  col :rec_comm_perc, type: :money
  col :mno_load_date, required: true, default: { function: :getdate }
  col :network_ind, type: :char
  col :associated_firm, len: 4
end
