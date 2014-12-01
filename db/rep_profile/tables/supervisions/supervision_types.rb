# Data table definition file.
# msh.supervision_types
# Contains available supervision types.

table :supervision_types, sql_schema: :msh do
  col :name, required: true, unique: true
  col :description, len: :max
  col :ordinal, type: :int, required: true, check: '> 0', unique: true
  col :is_default, required: true
  col :is_enabled, required: true, default: true
end
