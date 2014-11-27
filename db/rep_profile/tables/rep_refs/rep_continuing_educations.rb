# Data table definition file.
# dbo.repContinuingEducations
# Contains continuing education records for reps.

table :repContinuingEducations do
  col :repId, :ref => :primaryReps
  col :typeId, :ref => :continuingEducationTypes, required: true
  col :officeId, :ref => :offices
  col :year, type: :int
  col :requirement, type: :bool
  col :session_type
  col :session_status, type: :enum, check: 0..2
  col :window_start, type: :datetime
  col :window_end, type: :datetime
  col :scheduled, type: :datetime
  col :first_noticed, type: :datetime
  col :second_noticed, type: :datetime
  col :third_noticed, type: :datetime
  col :continuingDate
  col :inactiveDate
  col :terminated, type: :datetime
  col :notes, len: :max
end
