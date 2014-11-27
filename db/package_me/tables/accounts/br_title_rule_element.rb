# Data table definition file.
# dbo.br_title_rule_element
# Defines metadata elements for master account title rules.

table :br_title_rule_element do
  col :title_rule_element_id, id: true
  col :registration_role_id, :ref => :br_registration_role
  col :interested_party_type_id, :ref => :br_interested_party_type
  col :expression, required: true, default: 'DisplayName'
  col :description, len: :max, required: true
end
