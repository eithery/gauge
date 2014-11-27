# Data table definition file.
# dbo.restrictionReasons
# Contains reasons used to mark master accounts as restricted.

table :restrictionReasons do
  col :name, required: true, unique: true
  col :ordinal, type: :int, required: true
end
