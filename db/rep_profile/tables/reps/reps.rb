# Data table definition file.
# dbo.reps
# Contains all reps.
# Represents the base data table for primary reps and secondary reps.

table :reps do
  col :code, len: 10, business_id: true
  col :name, index: true
  col :officeId, :ref => :offices, required: true
  col :description, len: :max

  timestamps naming: :camel, dates: :short
end
