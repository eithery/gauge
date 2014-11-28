# Data table definition file.
# ref.experience_years_levels
# Contains available values for customer investment experience in the number of years levels.

table :experience_years_levels, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :export_value
end
