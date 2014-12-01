# Data table definition file.
# dbo.customFields
# Contains custom fields metadata for offices and reps.

table :customFields do
  col :name, required: true
  col :displayName, required: true
  col :isVisible, required: true, default: true
  col :isRequired, required: true
  col :objectType, required: true
  col :fieldTypeId, :ref => :fieldTypes, required: true
  col :fieldTypeManagerParameters, len: :max, required: true
  col :order, type: :int, required: true
end
