# Data table definition file.
# at.transactions
# Contains audit trail transactions.

table :transactions, sql_schema: :at do
  col :transaction_id, id: true, index: true
  col :operation, required: true
  col :user_id, len: 32, required: true
  col :modified_at, required: true
  col :processed_at, index: { clustered: true }
end
