# Data table definition file.
# [dbo].[repStatuses]
# Contains available rep statuses.

table :repStatuses do
  col :name, required: true
  col :display_name, required: true
  col :is_enabled, required: true, default: true
  col :order, type: :int, required: true, default: 0
  col :metadata, type: :xml
end
