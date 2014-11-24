# Data table definition file.
# [dbo].[primary_reps]
# Contains primary reps.

table :primaryReps do
  col :rr2CodeId, :ref => :rr2Codes
  col :employeeId, :ref => :employees, required: true
  col :repContractTypeId, :ref => :repContractTypes, required: true
  col :teamId, :ref => :teams
  col :alternatePayeeId, :ref => :primaryReps
  col :paymentTypeId, :ref => :paymentTypes
  col :crdNumber, len: 10
  col :carryDeficit, type: :bool, required: true
  col :balanceForward, type: :bool, required: true
  col :affiliationDate, required: true
  col :status, type: :byte, function: { name: :get_rep_status, params: [:id, 'getdate()'] }
end
