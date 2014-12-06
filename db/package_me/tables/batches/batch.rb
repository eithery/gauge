# Data table definition file.
# dbo.batch
# Contains batch info.

table :batch do
  col :batch_num, type: :int, id: true, identity: true
  col :batch_id, len: 20, required: true
  col :source, len: 10
  col :company, len: 3
  col :carrier_id, :ref => :carrier, len: 6, required: true
  col :status, len: 10

  col :check_no, len: 18
  col :check_date
  col :check_amt, type: :money
  col :batch_amt, type: :money
  col :rep_commission_total, type: :money
  col :fund_check_amount, type: :money
  col :user_id, len: 32
  col :manager_id, len: 32

  col :closed, type: :datetime
  col :released, type: :datetime
  col :wire_ind, type: :short
  col :batch_wire_date
  col :deposit_date
  col :statement_begin_date
  col :statement_end_date
  col :batch_cycle_date
  col :match_date
  col :match_fat_date
  col :ips_consolidated, type: :datetime

  col :export_rec, type: :int
  col :export_rec_user, len: 32
  col :export_rec_time, type: :datetime
  col :comment, len: :max

  timestamps dates: :short
end
