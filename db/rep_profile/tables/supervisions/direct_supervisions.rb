# Data table definition file.
# msh.direct_supervisions
# Defines direct supervisor-subordinate relationships.

table :direct_supervisions, sql_schema: :msh do
  col :subordinate_id, :ref => :primaryReps, business_id: true
  col :supervisor_id, :ref => :officeRoleAssignments, business_id: true
  col :ref => 'msh.supervision_types', required: true
end
