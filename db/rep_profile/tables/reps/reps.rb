# Data table definition file.
# [dbo].[reps]
# Contains all reps.

table :reps do
  col :code, len: 10, required: true, unique: true, business_id: true
  col :name, index: true
  col :officeId, :ref => :offices, required: true
  col :description, len: :max

  timestamps casing: :camel
end
