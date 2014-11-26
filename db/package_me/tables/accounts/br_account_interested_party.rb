# Data table definition file.
# dbo.br_account_interested_party
# Contains interested party info for master accounts.

table :br_account_interested_party do
  col :master_account_id, :ref => :br_master_account, required: true
  col :interested_party_type_id, :ref => :br_interested_party_type, required: true
  col :ordinal, type: :byte, required: true
  col :tax_id, len: 16
  col :tax_id_type, type: :enum, check: 0..5
  col :birth_date, type: :date
  col :first_name
  col :middle_name
  col :last_name, index: true
  col :designation, len: 16
  col :title
  col :is_finra_member
  col :is_senior_political_figure
  col :has_legal_age
  col :address_id, :ref => :br_address

  timestamps
end
