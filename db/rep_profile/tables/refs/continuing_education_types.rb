# Data table definition file.
# dbo.continuingEducationTypes
# Contains available rep continuing education types.

table :continuingEducationTypes do
  col :code, len: 20, required: true
  col :name, required: true
  col :description, len: :max
end
