# Data table definition file.
# dbo.product
# Contains financial products.

table :product do
  col :prod_id, type: :int, id: true, identity: true
  col :carrier_id, len: 6, :ref => :carrier, required: true
  col :type_id, len: 12
  col :symbol, len: 12, required: true
  col :cusip, len: 9, required: true, unique: true
  col :pr_short_name, len: 10
  col :desc1, len: 128
  col :desc2, len: 128
  col :desc3, len: 128
  col :issuer_id, len: 10
  col :cusip, len: 9
  col :fund_id, len: 10
  col :service_level, type: :char, required: true, default: 'N'
  col :share_class, type: :char
  col :daily_accrual_ind, type: :char
  col :fund_objective_id, len: 2
  col :prod_status, type: :char, check: %w(L S N Y)
  col :client_prod_type, len: 12
  col :updated, type: :datetime, default: { function: :getdate }
  col :user_id, len: 32
  col :data_source_id, len: 8
  col :load_type, type: :char
  col :bonus_annuity_ind, type: :char
  col :is_proprietary, required: true
  col :ntf_eligibility_ind, type: :bool, required: true
  col :benefit_payout, type: :bool, required: true
  col :notes
end
