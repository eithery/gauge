# Data table definition file.
# dbo.br_registration_interested_party_prototype
# Contains interested party metadata for master account registration types.

table :br_registration_interested_party_prototype do
  col :registration_id, :ref => :br_registration, required: true
  col :interested_party_type_id, :ref => :br_interested_party_type, required: true
  col :min_count, type: :byte, required: true, check: '0..max_count'
  col :max_count, type: :byte, required: true, check: '< 8'
end
