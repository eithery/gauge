# Data table definition file.
# at.categories
# Contains field category values for audit trail reports.

table :categories, sql_schema: :at do
  col id: true, identity: true
  col :name, required: true
end
