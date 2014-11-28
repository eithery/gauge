# Data table definition file.
# ref.risk_tolerance
# Contains available values for master account risk tolerance levels.

table :risk_tolerance, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :export_value
end
