# Data table definition file.
# [dbo].[repStatusHistory]
# Contains rep status history records.

table :repStatusHistory do
  col :repId, :ref => :primaryReps, index: true
  col :status, :ref => :repStatuses, required: true, check: 1..255
  col :startDate
  col :endDate
  col :stopPaymentDate
  col :changeReason, :ref => :repTerminateReasons
  col :changeDate
  col :notes, len: :max
  col :updated, type: :datetime
  col :updatedBy
end
