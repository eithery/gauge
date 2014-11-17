table :primary_reps do
  col :rep_id, id: true
  col :rep_code, len: 10, required: true
  col :office_code, len: 10
  col :ref => :contract_types, required: true
end
