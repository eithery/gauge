# Data table definition file.
# [dbo].[insuranceTypes]
# Contains available rep insurance types.

table :insuranceTypes do
  col :code, len: 10, required: true, business_id: true
  col :name, required: true
  col :description, len: :max
end
