# Data table definition file.
# [dbo].[primary_reps]
# Contains primary reps.

table :primary_reps do
  col :rr2CodeId, :ref => :rr2Codes
  col :employeeId, :ref => :employees                { required }
  col :repContractTypeId, :ref => :repContractTypes  { required }
  col :teamId, :ref => :teams
  col :alternatePayeeId, :ref => :primaryReps
  col :paymentTypeId, :ref => :paymentTypes
  col :crdNumber, len: 10
  col :carryDeficit, type: :bool                     { required }
  col :balanceForward, type: :bool                   { required }
  col :affiliationDate                               { required }
  col :status, type: :byte, function: :get_rep_status, params: [:id, getdate()]
end
