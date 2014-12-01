# Data table definition file.
# at.snapshots
# Contains audit trail snapshots.

table :snapshots, sql_schema: :at do
  col id: true, identity: true
  col :operation, required: true
  col :object_id, type: :long, required: true
  col :object_type, len: 128, required: true
  col :object_code, required: true
  col :modified, type: :datetime, required: true, default: { function: :getdate }
  col :modified_by, required: true
  col :client_host, required: true, default: { function: :host_name }
  col :snapshot, type: :xml, required: true
  col :hash, type: :binary, len: 16, required: true
end
