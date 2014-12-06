# Data table definition file.
# dbo.br_registration_role
# Defines registration roles for master account owners.

table :br_registration_role do
  col :registration_role_id, id: true
  col :registration_role_code, type: :char, required: true, check: %w(G B T M C O N)
  col :name, len: 64, required: true
  col :displayName, len: 50
  col :description, len: :max
  col :is_primary, required: true
  col :licenseCheckEnabled, type: :bool, required: true, default: true
  col :cipEnabled, type: :bool, required: true, default: true
  col :customerRoleId, len: 5
  col :rapRecipientEnabled, type: :bool, required: true, default: true
  col :isSuitabilityRequired, required: true
  col :isMaritalStatusValidated, required: true, default: true
  col :isPersonalIdValidated, required: true, default: true
  col :isEmploymentValidated, required: true, default: true
  col :isAffiliationValidated, required: true, default: true
  col :isGenericSuitabilityValidated, required: true, default: true
  col :isAnnualIncomeValidated, required: true, default: true
  col :isSignatureNeeded, required: true
  col :suitability_validation_level, type: :enum, check: 0..3
end
