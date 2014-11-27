# Data table definition file.
# dbo.br_title_rule
# Defines rules for master account title autogeneration.

table :br_title_rule do
  col :title_rule_id, id: true
  col :registration_id, :ref => :br_registration
  col :sequence, type: :int, required: true, unique: true
  col :is_mandatory, required: true, default: true
  col :prefix, len: 128
  col :suffix, len: 128
  col :repeat_prefix, len: 128
  col :title_rule_element_id, :ref => :br_title_rule_element
  col :end_line, type: :int
  col :end_line_repeat, type: :int
end
