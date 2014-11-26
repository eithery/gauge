# Data table definition file.
# dbo.br_registration_prototype
# Defines prototypes for master account registration types.

table :br_registration_prototype do
  col :registration_id, :ref => :br_registration, id: true
  col :ordinal, type: :int, id: true, check: '> 0'
  col :registration_role_id, :ref => :br_registration_role, required: true
  col :natural_owner_type_id, :ref => :br_natural_owner_type, required: true
  col :min_count, type: :int, required: true
  col :max_count, type: :int, required: true
  col :identification_code, type: :byte, required: true, check: 0..2
end
