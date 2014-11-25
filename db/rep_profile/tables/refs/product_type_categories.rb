# Data table definition file.
# [dbo].[productTypeCategories]
# Contains available product type categories for rep splits.

table :productTypeCategories do
  col :code, len: 3, required: true
  col :name, required: true
  col :description, len: :max
end
