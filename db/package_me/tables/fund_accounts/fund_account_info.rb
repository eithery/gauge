# Data table definition file.
# dbo.fund_account_info
# Contains fund account records.

table :fund_account_info do
  col id: true, default: :uid
  col :fund_account_number, len: 20, business_id: true
  col :cusip, len: 9, business_id: true, index: true

  col :division_id, len: 10
  col :office_id, len: 10, index: true
  col :rep_id, len: 10, index: true

  col :cust_account, len: 20, index: true
  col :source_firm_code, len: 10
  col :isMaster, required: true, default: true
  col :reg_type, len: 6
  col :stateOfSale, type: :us_state

  col :status, type: :short, required: true, check: -1..1, default: 1
  col :statusChanged, type: :datetime
  col :statusChangedBy
  col :changeStatusReasonId, :ref => :accountActivationReasons
  col :purgeDate

  col :network_status, type: :char
  col :network_status_date
  col :network_command, type: :char
  col :network_command_date
  col :network_command_source, len: 10
  col :far_command, len: 3
  col :far_command_source
  col :far_command_date

  col :householdId, :ref => :households
  col :account_aum, type: :money
  col :options, type: :bool
  col :discretion, type: :bool
  col :closed, type: :date

  col :group_plan_name, len: 40
  col :group_plan_alpha, len: 20
  col :group_plan_ssn, len: 20

  col :last_position_value, type: :money
  col :last_position_date
  col :last_position_source, len: 10
  col :last_commission_date

  col :fat_established, type: :datetime
  col :lives_credit_date
  col :comment, len: :max

  col :created_date
  col :update_date
  col :update_user, len: 32
end
