# Data table definition file.
# at.object_snapshot_queries
# Contains parts of queries to build object snapshots.

table :object_snapshot_queries, sql_schema: :at do
  col id: true, identity: true
  col :domain_object, len: 128
  col :query, len: :max  
end
