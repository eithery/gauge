# Data table definition file.
# at.join_metadata
# Defines metadata for domain object associations.

table :join_metadata, sql_schema: :at do
  col :domain_object, len: 128, required: true, id: true
  col :join_type, len: 8, required: true
  col :table_name, len: 128, required: true, id: true
  col :table_alias, len: 32, required: true, id: true
  col :predicate
  col :order_by
  col :order, type: :int, required: true
end
