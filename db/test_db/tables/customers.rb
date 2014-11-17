table :customers do
  col :first_name
  col :last_name, required: true
  timestamps casing: :camel
end
