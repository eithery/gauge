# Data table definition file.
# dbo.repSplitDetails
# Contains detail info of rep splits.

table :repSplitDetails do
  col :repSplitId, :ref => :repSplits, required: true
  col :startDate
  col :endDate
  col :productTypeId, :ref => :productTypeCategories
  col :accountNumber, len: 20
  col :baseCode, len: 10
  col :description, len: :max
end
