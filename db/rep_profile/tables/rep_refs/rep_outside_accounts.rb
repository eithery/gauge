# Data table definition file.
# dbo.repOutsideAccounts
# Contains outside accounts for reps.

table :repOutsideAccounts do
  col :repId, :ref => :primaryReps
  col :accountNumber, len: 20, required: true
  col :opened, type: :datetime
  col :closed, type: :datetime
  col :brokerName
  col :brokerAttentionName
  col :brokerAddressId, :ref => :addresses
  col :notes, len: :max
  col :registration
  col :registrationExt
  col :letterCreated, type: :datetime
  col :letterCreatedBy
  col :letterSent, type: :datetime
  col :letterNotes, len: :max
  col :updated, type: :datetime
  col :updatedBy
end
