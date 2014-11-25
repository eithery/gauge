# Data table definition file.
# [dbo].[conversation_activity_types]
# Contains available rep conversation activity types.

table :conversation_activity_types do
  col :name, required: true
  col :description, len: :max
  col :ordinal, type: :int, required: true, check: '>0'
  col :is_enabled, required: true, default: true
  col :icon, type: :blob
end
