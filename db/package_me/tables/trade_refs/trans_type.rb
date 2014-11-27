# Data table definition file.
# dbo.trans_type
# Contains available trade types.

table :trans_type do
  col :code, len: 18, id: true, business_id: true
  col :tr_type, len: 18, required: true
  col :tr_type_code, len: 2, required: true
  col :display_name
  col :blotter, len: 2
  col :bs_code, type: :char, len: 1
  col :seq, type: :int, required: true
  col :haircut, type: :percent, required: true, default: 1.0
  col :allowMultipleTradeAllocations, type: :bool, required: true
  col :zeroAmount, type: :enum, required: true, check: 0..3
  col :tag, len: 2
  col :stp_support, type: :bool, required: true
  col :stp_ordinal, type: :int
  col :is_trackable_trade, required: true, default: true
end
