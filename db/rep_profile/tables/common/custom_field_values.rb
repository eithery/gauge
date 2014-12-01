# Data table definition file.
# dbo.customFieldValues
# Contains custom fields values offices and reps.

table :customFieldValues do
  col :objectId, type: :long, required: true
  col :fieldValue
  col :customFieldId, :ref => :customFields, required: true
end
