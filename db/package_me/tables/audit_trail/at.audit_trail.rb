# Data table definition file.
# at.audit_trail
# Contains the history of changes by fields.

table :audit_trail, sql_schema: :at do
  col id: true, identity: true
  col :object_id, type: :long, required: true, index: true
  col :ref => 'at.categories'
  col :field_name, required: true
  col :new_data, len: 1024
  col :prior_data, len: 1024
  col :source_system, len: 64
  col :update_type, len: 32
  col :user_id, len: 32, required: true
  col :modified_at, required: true, index: { clustered: true }
  col :transaction_id, type: :long, required: true
  col :processed_at, default: { function: :getdate }
end
