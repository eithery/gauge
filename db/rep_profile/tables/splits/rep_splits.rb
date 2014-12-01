# Data table definition file.
# dbo.repSplits
# Contains rep splits.

table :repSplits do
  col :splitCode, len: 10, required: true, business_id: true
  col :name
  col :officeId, :ref => :offices, required: true
  col :rr2codeId, :ref => :rr2codes
  col :description, len: :max

  timestamps naming: :camel, dates: :short

  index :rr2codeId, unique: true, not_null: true
end
