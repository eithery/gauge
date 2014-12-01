# Data table definition file.
# dbo.contacts
# Contains contact info records for reps.

table :contacts do
  col :businessPhone, len: 32
  col :businessPhoneExt, len: 4
  col :additionalPhone, len: 32
  col :additionalPhoneExt, len: 4
  col :cellPhone, len: 32
  col :cellPhoneExt, len: 4
  col :homePhone, len: 32
  col :homePhoneExt, len: 4
  col :fax, len: 32
  col :faxExt, len: 4
  col :imAddress
  col :email
  col :web
  col :primary_phone, type: :enum, required: true, check: 0..4, default: 0
end
