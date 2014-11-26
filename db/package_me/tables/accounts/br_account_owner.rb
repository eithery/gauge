# Data table definition file.
# dbo.br_account_owner
# Cross reference data table providing many-to-many relationship between
# master accounts and customers (natural owners).

table :br_account_owner do
  col :master_account_id, :ref => :br_master_account, id: true
  col :natural_owner_id, :ref => :br_natural_owner, id: true
  col :registration_role_id, :ref => :br_registration_role, required: true
  col :ordinal, type: :byte, required: true, check: '> 0'
  col :address_id, :ref => :br_address
  col :last_rap_at
  col :last_nap_at
  col :last_bnr_at
  col :next_bnr_due, type: :datetime

  timestamps dates: :short
end
