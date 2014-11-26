# Data table definition file.
# dbo.br_address
# Contains address info for master account owners, customers, and interested parties.

table :br_address do
  col :address_id, id: true
  col :street, len: 96
  col :street2, len: 96
  col :city, len: 64
  col :state_code, type: :us_state
  col :postal_code, len: 16
  col :country_code, type: :country, default: 'US'
end
