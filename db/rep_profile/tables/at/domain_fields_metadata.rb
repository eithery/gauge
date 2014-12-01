# Data table definition file.
# at.domain_fields_metadata
# Defines fields metadata for rep business domain objects.

table :domain_fields_metadata, sql_schema: :at do
  col id: true, identity: true
  col :domain_object, len: 128, required: true
  col :column_name, len: 128, required: true
  col :xpath, required: true
  col :order, type: :int, required: true
  col :ref_domain_object, len: 128
  col :ref_column_name, len: 128
  col :is_visible, required: true, default: true
end
