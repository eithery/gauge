# Data table definition file.
# dbo.officeSeminars
# Contains office seminars records.

table :officeSeminars do
  col :officeId, :ref => :offices
  col :leaderRepId, :ref => :primaryReps
  col :seminarName
  col :seminarDate
  col :notes, len: :max
end
