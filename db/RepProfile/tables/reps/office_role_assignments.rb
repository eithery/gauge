# Data table definition file.
# [dbo].[officeRoleAssignments]
# Contains office role assignments.

table :officeRoleAssignments do
  col :name
  col :description, len: :max
  col :primaryRepId, :ref => :primaryReps
  col :officeRoleId, :ref => :officeRoles { required }
  col :officeId, :ref => :offices { required }
  col :startDate { required }
  col :endDate
  col :is_default { required }
end
