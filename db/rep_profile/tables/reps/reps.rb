# Data table definition file.
# [dbo].[reps]
# Contains all reps.

table :reps do
  col :code, len: 10              { required; unique; business_id }
  col :name, {}                   { index }
  col :officeId, :ref => :offices { required }
  col :description, len: :max

  timestamps casing: :camel
end
