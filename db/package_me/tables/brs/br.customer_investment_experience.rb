# Data table definition file.
# br.customer_investment_experience
# Contains customer investment experience values.

table :customer_investment_experience, sql_schema: :br do
  col :customer_id, :ref => :br_natural_owner, business_id: true
  col :ref => 'ref.investment_experience', business_id: true
  col :experience_level_id, :ref => 'ref.investment_experience_levels'
  col :years_level_id, :ref => 'ref.experience_years_levels'
  col :years_amount, type: :byte, check: '> 0'
  col :transactions_level_id, :ref => 'ref.transactions_per_year_levels'
  col :comment
end
