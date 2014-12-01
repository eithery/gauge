# Data table definition file.
# dbo.fund_account_registration
# Contains additional information related to fund accounts.

table :fund_account_registration do
  col :fund_account_number, len: 20, id: true
  col :cusip, len: 9, id: true

  col :fi_regType, len: 6
  col :fi_cust_name
  col :fi_cust_short_name, len: 20
  col :fi_cust_ssn, len: 15
  col :fi_state, type: :us_state

  col :fi_office_id, len: 10
  col :fi_rep_id, len: 10
  col :fi_rep_name, len: 20

  col :fi_registration_1, len: 50
  col :fi_registration_2, len: 50
  col :fi_registration_3, len: 50
  col :fi_registration_4, len: 50
  col :fi_registration_5, len: 50
  col :fi_registration_6, len: 50
  col :fi_registration_7, len: 50

  col :fi_update_date
  col :fi_source, len: 5
end
