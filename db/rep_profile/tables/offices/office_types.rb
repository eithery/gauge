# Data table definition file.
# dbo.office_types
# Contains available office types.

table :office_types do
  col :name, required: true, unique: true
  col :display_name, required: true
  col :description, len: :max
  col :is_bank_branch, required: true
  col :allow_primary_reps, required: true, default: true
  col :allow_secondary_reps, required: true, default: true
  col :allow_roles, required: true, default: true
  col :allow_splits, required: true, default: true
  col :allowed_suboffices, type: :xml, required: true
end
