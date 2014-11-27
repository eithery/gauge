# Data table definition file.
# dbo.correctReasons
# Contains reasons used to perform cancel/correct direct trade operations.

table :correctReasons do
  col id: true, identity: true
  col :code, len: 2, required: true, unique: true
  col :description
end
