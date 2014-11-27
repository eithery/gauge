# Data table definition file.
# br.customer_financial_info
# Contains customer financial info values.

table :customer_financial_info, sql_schema: :br do
  col :customer_id, :ref => :br_natural_owner, business_id: true
  col :ref => 'ref.financial_info', business_id: true
  col :level_value, type: :int, check: '>= 0'
  col :percent_value, type: :percent, check: '>= 0'
  col :amount_value, type: :money
  col :comment
end
