# Data table definition file.
# ref.special_expenses_timeframes
# Contains available values for special expenses timeframe levels.

table :special_expenses_timeframes, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :export_value
end
