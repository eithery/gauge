# Data table definition file.
# dbo.splitItems
# Contains rep splits participants.

table :splitItems do
  col :repSplitDetailId, :ref => :repSplitDetails, required: true
  col :repId, :ref => :reps, required: true
  col :rate, type: :percent, required: true, check: 0..100
  col :seq, type: :int, required: true

  index [:repSpltDetailId, :seq], unique: true
end
