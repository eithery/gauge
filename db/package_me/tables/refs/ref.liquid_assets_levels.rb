# Data table definition file.
# ref.liquid_assets_levels
# Contains available values for customer liquid assets levels.

table :liquid_assets_levels, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :export_value
  col :min_value, type: :money
  col :max_value, type: :money
end
