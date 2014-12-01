# Data table definition file.
# dbo.emails
# Contains email address records.

table :emails do
  col :parent_id, :ref => :primaryReps, required: true
  col :email, required: true
  col :start_date, required: true
  col :end_date
  col :is_primary, required: true
end
