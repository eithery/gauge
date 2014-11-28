# Data table definition file.
# ref.investment_purposes
# Defines metadata for master account investment purposes fields.

table :investment_purposes, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :suffix, len: 16
  col :description, len: :max
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :has_comment, required: true
end
