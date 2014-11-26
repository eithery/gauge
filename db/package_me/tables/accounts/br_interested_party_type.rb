# Data table definition file.
# dbo.br_interested_party_type
# Defines available master account interested party types.

table :br_interested_party_type do
  col :interested_party_type_id, id: true
  col :name, required: true
  col :description, len: :max
  col :tax_id_required_level, type: :short, required: true, check: -1..1
  col :birth_date_required_level, type: :short, required: true, check: -1..1
  col :name_required_level, type: :short, required: true, check: -1..1
  col :address_required_level, type: :short, required: true, check: -1..1
  col :title_required_level, type: :short, required: true, check: -1..1
  col :disclosures_required_level, type: :short, required: true, check: -1..1
  col :has_legal_age_required_level, type: :short, required: true, check: -1..1
  col :interested_party_metadata, type: :xml
end
