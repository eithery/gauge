# Data table definition file.
# dbo.batchLocking
# Supports pessimistic locking for batches.
# Contains records for locked batches.

table :batchLocking do
  col id: true, identity: true
  col :batchId, len: 20, required: true
  col :userLogin, len: 32, required: true
  col :workDate, required: true
  col :actionCode, len: 64, required: true
end
