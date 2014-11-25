# Data table definition file.
# [dbo].[rep_attributes_rules]
# Contains many-to-many relationships between rep attributes and contract types.
# Defines rules which rep attributes are available for contract types.

table :rep_attributes_rules do
  col :ref => :rep_attributes,  check: { sql: 'rep_attribute_id is not null or contract_type_id is not null' }
  col :rep_attribute_name, function: { name: :get_rep_attribute, params: :rep_attribute_id }
  col :contract_type_id, :ref => :repContractTypes
  col :contract_type_name, function: { name: :get_contract_type, param: :contract_type_id }
  col :is_enabled, required: true
end
