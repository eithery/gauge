# Data table definition file.
# [dbo].[repOutsideBusiness]
# Contains outside business information for reps.

table :repOutsideBusiness do
  col :repId, :ref => :primaryReps
  col :businessName, required: true
  col :startDate
  col :endDate
  col :verified, type: :datetime
  col :verifiedBy
  col :notes, len: :max
end
