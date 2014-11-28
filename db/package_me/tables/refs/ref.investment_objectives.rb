# Data table definition file.
# ref.investment_objectives
# Defines metadata for master account investment objectives fields.

table :investment_objectives, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :suffix, len: 16
  col :description, len: :max
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :has_comment, required: true
end
