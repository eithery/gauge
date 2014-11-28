# Data table definition file.
# ref.investment_experience
# Defines metadata for customer investment experience fields.

table :investment_experience, sql_schema: :ref do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :suffix, len: 16
  col :description, len: :max
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_enabled, required: true, default: true
  col :has_comment, required: true
  col :has_experience_levels, required: true, default: true
  col :has_years_levels, required: true, default: true
  col :has_years_amount, required: true
  col :has_transaction_levels, required: true, default: true
end
