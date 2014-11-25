# Data table definition file.
# [dbo].[rep_attributes]
# Contains additional custom attributes for reps.

table :rep_attributes do
  col :name, required: true, unique: true
  col :description, len: :max
  col :ordinal, type: :int, required: true, check: '>0', unique: true
end
