# Data table definition file.
# dbo.addresses
# Contains address records for offices and reps.

table :addresses do
  col :city
  col :street
  col :streetExt
  col :zip, len: 20
  col :state, type: :us_state
  col :country, type: :country
end
