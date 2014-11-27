# Data table definition file.
# dbo.repOutsideInsuranceBusiness
# Contains outside insurance business information for reps.

table :repOutsideInsuranceBusiness do
  col :repId, :ref => :primaryReps, required: true
  col :insuranceTypeId, :ref => :insuranceTypes, required: true
  col :approximateAnnualIncome, type: :money
  col :notes, len: :max
end
