# Data table definition file.
# dbo.rep_bd_affiliations
# Contains broker/dealer affiliations for the rep.

table :rep_bd_affiliations do
  col :rep_id, :ref => :primaryReps, required: true
  col :broker_dealer_id, :ref => :offices, required: true
  col :start_date
  col :end_date

  timestamps dates: :short
end
