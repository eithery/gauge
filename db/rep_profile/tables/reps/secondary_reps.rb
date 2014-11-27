# Data table definition file.
# dbo.secondaryReps
# Contains secondary rep codes for reps.

table :secondaryReps do
  col :primaryRepId, :ref => :primaryReps, required: true
  col :terminated, type: :datetime
  col :is_main, required: true
end
