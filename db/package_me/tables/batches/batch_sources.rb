# Data table definition file.
# dbo.batch_sources
# Contains available batch sources.

table :batch_sources do
  col :code, len: 10, business_id: true
  col :name
  col :description, len: :max
  col :is_auto, required: true
  col :is_visible, required: true, default: true
  col :allow_delete_batch, required: true
  col :batch_number_generator
end
