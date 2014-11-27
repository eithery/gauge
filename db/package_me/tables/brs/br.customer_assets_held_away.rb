# Data table definition file.
# br.customer_assets_held_away
# Contains customer assets held away values.

table :customer_assets_held_away, sql_schema: :br do
  col :customer_id, :ref => :br_natural_owner, business_id: true
  col :assets_held_away_id, :ref => 'ref.assets_held_away', business_id: true
  col :asset_value, type: :percent, required: true, check: '>= 0'
  col :comment
end
