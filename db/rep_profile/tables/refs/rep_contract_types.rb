# Data table definition file.
# [dbo].[repContractTypes]
# Contains available rep contract types.

table :repContractTypes do
  col :code, len: 10, required: true, unique: true
  col :name, required: true
  col :description, len: :max
end
