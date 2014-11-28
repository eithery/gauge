# Data table definition file.
# dbo.direct_trade
# Contains direct trade commision records.

table :direct_trade do
  col :id, type: :long, required: true, default: :uid, unique: true
  col :trade_id, type: :int, id: true, business_id: true, identity: { seed: 200 }
  col :tran_type, :ref => :trans_type, len: 18, required: true
  col :account_num, len: 20, required: true
  col :ref => :source_firms
  col :source_firm_code, computed: { function: :getSourceFirmCode, params: :source_firm_id }

  col :batch_id, len: 20, index: true
  col :load_id, type: :int, index: true

  col :rep_id, len: 10, required: true
  col :off_id, len: 10
  col :div_id, len: 10

  col :prod_id, type: :int, :ref => :product, required: true
  col :policy_no, len: 20
  col :policy_date
  col :state_of_sale, type: :us_state
  col :trade_date, required: true
  col :settle_date

  col :price, type: :money
  col :quantity, type: :money
  col :principal, type: :money
  col :bank_rate, type: :percent
  col :rep_rate, type: :percent
  col :expected_bank_comm, type: :money
  col :expected_rep_comm, type: :money
  col :bank_comm, type: :money
  col :rep_comm, type: :money

  col :outside_money, type: :money
  col :account_aum, type: :money
  col :aum_amount, type: :money
  col :householdId, :ref => :households
  col :household_aum, type: :money
  col :roaloi_amount, type: :money
  col :roaloi_date
  col :wire_date

  col :status, len: 6, required: true
  col :org_trade_id, type: :int
  col :cxl_trade_id, type: :int
  col :rbl_trade_id, type: :int
  col :reason_id, :ref => :correctReasons
  col :source_of_funds_id, :ref => 'ref.sources_of_funds'
  col :entered, type: :datetime, required: true
  col :processed, type: :datetime
  col :cancelled, type: :datetime
  col :surrendered, type: :datetime
  col :mergedFromAccount, len: 20

  col :cust_check, len: 18
  col :nav, type: :char, len: 1
  col :buy_sell, len: 8
  col :proration_ratio, type: :percent
  col :skip_license, type: :short
  col :trailer_flag, type: :bool
  col :pay_while_open, type: :bool
  col :advance_ind, type: :bool
  col :is_part_of_investment_strategy

  col :stp_app_id
  col :stp_load_id, type: :long
  col :comments, len: :max

  col :created, type: :datetime
  col :createdBy
  col :modified, type: :datetime
  col :modifiedBy
  col :version, type: :long, required: true, default: 0

  index [:batch_id, :bank_comm]
  index [:batch_id, :rep_comm]
end
