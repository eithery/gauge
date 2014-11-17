table :contract_types, sql_schema: :ref do
  col :name, required: true
  col :description, len: :max
end
