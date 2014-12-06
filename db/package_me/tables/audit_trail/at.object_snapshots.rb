# Data table definition file.
# at.object_snapshots
# Contains object snapshots.

table :object_snapshots, sql_schema: :at do
  col id: true, identity: true
  col :operation, required: true
  col :object_id, type: :long, required: true, index: true
  col :complementary_object_id, type: :long, index: true
  col :object_type, len: 128, required: true
  col :object_code
  col :modified_at, required: true, default: { function: :getdate }, index: { clustered: true }
  col :modified_by, required: true
  col :client_host, required: true, default: { function: :host_name }
  col :source, len: 64
  col :snapshot, type: :xml, required: true
  col :hash, type: :binary, len: 16, required: true
  col :transaction_id, type: :long, required: true, index: true
end
