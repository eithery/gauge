# Data table definition file.
# dbo.officeAudit
# Contains office audit records.

table :officeAudit do
  col :officeId, :ref => :offices
  col :repId, :ref => :primaryReps
  col :auditDate, required: true
  col :auditCompleteDate
  col :auditSentDate
  col :responseDate
  col :notes, len: :max
end
