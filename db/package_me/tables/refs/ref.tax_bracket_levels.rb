# Data table definition file.
# ref.tax_bracket_levels
# Contains available values for customer tax bracket levels.

table :tax_bracket_levels, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :export_value
end
