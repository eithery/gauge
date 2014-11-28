# Data table definition file.
# ref.investment_time_horizon
# Contains available values for master account investment time horizon levels.

table :investment_time_horizon, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :export_value
end
