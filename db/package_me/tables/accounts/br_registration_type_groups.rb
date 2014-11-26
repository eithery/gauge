# Data table definition file.
# dbo.br_registration_type_groups
# Defines master account registration type groups.

table :br_registration_type_groups do
  col :name, len: 64, required: true
  col :description, len: :max
end
