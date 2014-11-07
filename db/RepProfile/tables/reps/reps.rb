# Data table definition file.
# [dbo].[reps]
# Contains all reps.

table :reps do
  col :code, len: 10 { required; unique; business_id }
  col :name
  col :officeId, :ref => :offices { required }
  col :description

  timestamps casing: :camel
end
