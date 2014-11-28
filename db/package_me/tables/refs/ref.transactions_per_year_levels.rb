# Data table definition file.
# ref.transaction_per_year_levels
# Contains available values for customer transactions per year levels.

table :transactions_per_year_levels, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :export_value
end
