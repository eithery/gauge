# Data table definition file.
# [dbo].[officeRoleAssignments]
# Contains office role assignments.

table :officeRoleAssignments do
  col :name
  col :description, len: :max
  col :primaryRepId, :ref => :primaryReps
  col :officeRoleId, :ref => :officeRoles, required: true
  col :officeId, :ref => :offices, required: true
  col :startDate, required: true
  col :endDate
  col :is_default, required: true
end
