# Data table definition file.
# at.fields_categories
# Contains info about fields for audit trail reports.

table :fields_categories, sql_schema: :at do
  col id: true, identity: true
  col :field_name, required: true
  col :ref => 'at.categories', required: true
end
