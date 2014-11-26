# Data table definition file.
# dbo.br_natural_owner_type
# Defines available customer (natural owner) types.

table :br_natural_owner_type do
  col :natural_owner_type_id, id: true
  col :name, len: 64, required: true
end
