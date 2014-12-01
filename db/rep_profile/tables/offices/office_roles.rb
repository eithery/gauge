# Data table definition file.
# dbo.officeRoles
# Contains available office roles.

table :officeRoles do
  col :code, len: 10, required: true
  col :name, required: true
  col :description, len: :max
  col :roleType, type: :enum, required: true, check: 0..3, default: 0
  col :ref => 'msh.supervision_types'
  col :clientCode, len: 10
end
