# Data table definition file.
# dbo.validationRules
# Contains validation rules metadata.

table :validationRules do
  col :code, business_id: true
  col :description, len: :max
  col :message, required: true
  col :severity, type: :enum, required: true, check: 0..4, default: 3
  col :isEnabled, required: true, default: true
  col :tag
end
