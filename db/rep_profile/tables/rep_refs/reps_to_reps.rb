# Data table definition file.
# dbo.reps2Reps
# Represents many-to-many relationships between reps related to reporting visibility purposes.

table :reps2Reps do
  col :masterRepId, :ref => :primaryReps, business_id: true
  col :dependentRepId, :ref => :primaryReps, business_id: true
  col :accessType, type: :byte, required: true, default: 0
end
