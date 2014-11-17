table :accounts do
  col :account_number, len: 20, required: true
  col :title
  col :rep_code, len: 10, required: true
  col :comments, len: :max
  col :total_amount, type: :money
  timestamps
end
