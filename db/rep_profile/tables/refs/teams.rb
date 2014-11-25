# Data table definition file.
# [dbo].[teams]
# Contains available rep teams.

table :teams do
  col :code, len: 10, required: true, business_id: true
  col :name, required: true
  col :description, len: :max
end
