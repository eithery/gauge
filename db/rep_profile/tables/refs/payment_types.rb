# Data table definition file.
# dbo.paymentTypes
# Contains available payment types for reps.

table :paymentTypes do
  col :code, len: 1, required: true
  col :name, required: true
  col :description, len: :max
end
