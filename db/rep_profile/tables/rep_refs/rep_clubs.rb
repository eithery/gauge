# Data table definition file.
# dbo.repClubs
# Contains rep clubs and awards records.

table :repClubs do
  col :repId, :ref => :primaryReps
  col :clubId, :ref => :clubs, required: true
  col :year, type: :int, required: true
  col :start_date
  col :end_date
  col :description, len: :max
end
