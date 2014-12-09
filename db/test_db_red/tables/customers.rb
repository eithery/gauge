table :customers, sql_schema: :test do
  col :code, len: 10, required: true
  col :first_name
  col :middle_name
  col :last_name, required: true
  col :status, type: :enum, required: true, default: 4
  col :is_active, required: true
  col :comments
end
