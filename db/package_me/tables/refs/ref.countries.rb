# Data table definition file.
# ref.countries
# Contains available countries.

table :countries, sql_schema: :ref do
  col id: true, type: :int, identity: true
  col :code, len: 2, required: true, unique: true
  col :name, required: true  
end
