# Data table definition file.
# dbo.carrier
# Contains product carriers.

table :carrier do
  col :carrier_id, len: 6, id: true
  col :super_carrier_id, len: 6, :ref => :carrier
  col :carrier_name, len: 35, required: true
  col :carrier_mail_addr1, len: 35
  col :carrier_mail_addr2, len: 35
  col :carrier_mail_city, len: 15
  col :carrier_mail_state, type: :us_state
  col :carrier_mail_zip, len: 10
  col :alternate_addr1, len: 30
  col :alternate_addr2, len: 30
  col :alternate_city, len: 15
  col :alternate_state, type: :us_state
  col :alternate_zip, len: 10
  col :carrier_dealer_phone, len: 15
  col :carrier_order_phone, len: 15
  col :carrier_comment, len: 150
  col :carrier_network_ind, type: :enum, check: 0..3, default: 0
  col :carrier_commserv_ips, type: :char
  col :carrier_electronic_ind, type: :char
  col :carrier_trail_cycle, type: :char
  col :carrier_comm_cycle, type: :char
  col :carrier_service_level, type: :char, required: true, default: 'N'
  col :carrier_account_length, type: :int
  col :carrier_aadb_code, type: :char
  col :carrier_mml_dealer_id, len: 15
  col :carrier_old_id, len: 15
  col :carrier_updated, type: :datetime, default: { function: :getdate }
  col :carrier_user_id, len: 32
  col :selling_start_date
  col :selling_end_date
  col :isStrategicPartnership, required: true
  col :isCria, required: true
  col :contactName, len: 50
  col :proprietary, type: :enum, required: true, check: 0..2, default: 0
  col :explicitOrder, type: :int
  col :process_confirm_trans, type: :bool, required: true
  col :far_eligibility_level, type: :enum, required: true, check: 0..3, default: 0
end
