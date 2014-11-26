# Data table definition file.
# dbo.br_registration
# Defines master account registration types.

table :br_registration do
  col :registration_id, id: true
  col :registration_code, len: 32, business_id: true
  col :name, len: 64, required: true, unique: true
  col :is_account_suitability_required, required: true, default: true
  col :nscc_social_code, type: :byte, required: true, check: '> 0'
  col :is_networking_eligible, required: true
  col :description, len: :max
  col :mml_code, type: :byte, check: '> 0'
  col :orderIndex, type: :int, required: true
  col :isShell, required: true
  col :isSystem, required: true
  col :is2821ruleChecked, required: true
  col :groupId, :ref => :br_registration_type_groups
  col :isUnique, required: true, default: true
  col :stp_support, type: :int, check: -1..2
  col :isTrustNameRequired, required: true
  col :is_enabled, required: true, default: true
  col :is_erisa_enabled, required: true
  col :validation_level, type: :enum, check: 0..4
end
