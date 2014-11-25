# Data table definition file.
# [dbo].[rep_attributes_map]
# Contains many-to-many relationships for primary reps and its attributes.

table :rep_attributes_map do
  col :primary_rep_id, :ref => :primaryReps, required: true, id: true
  col :ref => :rep_attributes, required: true, id: true
  col :start_date, type: :date
  col :end_date, type: :date
end
