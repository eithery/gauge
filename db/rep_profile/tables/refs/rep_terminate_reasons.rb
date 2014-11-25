# Data table definition file.
# [dbo].[repTerminateReasons]
# Contains available rep termination reasons.

table :repTerminateReasons do
  col :name, required: true
  col :display_name, required: true
  col :is_enabled, required: true
  col :order, type: :int, required: true
end
