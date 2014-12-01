# Data table definition file.
# dbo.fieldTypes
# Contains available custom fields types.

table :fieldTypes do
  col :name, required: true
  col :description, len: :max
  col :fieldTypeManagerType, required: true
end
