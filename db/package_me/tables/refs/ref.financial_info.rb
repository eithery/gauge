# Data table definition file.
# ref.financial_info
# Defines metadata for customer financial info fields.

table :financial_info, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :description, len: :max
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :has_comment, required: true
  col :has_amount, required: true, default: true
  col :has_percent, required: true
  col :has_levels, required: true, default: true
  col :source, len: 64
  col :validation_level, type: :enum, check: 0..4
end
