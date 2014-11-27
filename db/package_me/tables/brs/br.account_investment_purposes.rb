# Data table definition file.
# br.account_investment_purposes
# Contains investment purposes values for master accounts.

table :account_investment_purposes, sql_schema: :br do
  col :master_account_id, :ref => :br_master_account, business_id: true
  col :ref => 'ref.investment_purposes', business_id: true
  col :rank, type: :byte, required: true, check: '> 0'
  col :comment

  index [:master_account_id, :rank], unique: true
end
