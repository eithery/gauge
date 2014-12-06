# Data table definition file.
# at.object_snapshot_links
# Contains links between object snapshots.

table :object_snapshot_links, sql_schema: :at do
  col id: true, identity: true
  col :code, len: 32, required: true
  col :parent_snapshot_id, :ref => 'at.object_snapshots', required: true
  col :child_snapshot_id, :ref => 'at.object_snapshots', required: true
  col :ordinal, type: :byte
  col :status, type: :byte, required: true
  col :modified_at, required: true, default: { function: :getdate }, index: { clustered: true }
  col :modified_by, required: true
  col :transaction_id, type: :long, required: true, index: true
end
