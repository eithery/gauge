# Data table definition file.
# dbo.rep_conversation_activities
# Contains rep conversation activities.

table :rep_conversation_activities do
  col :ref => :employees, business_id: true
  col :ref => :conversation_activity_types, required: true
  col :subject, required: true
  col :content, len: :max, required: true
  col :contacted, type: :datetime, required: true
  col :contacted_by, required: true
  col :created, type: :datetime, business_id: true
  col :created_by, required: true
  col :modified, type: :datetime, required: true
  col :modified_by, required: true
end
