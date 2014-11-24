# Data table definition file.
# [dbo].[br_natural_owner]
# Contains customer info (individuals and corporations).

table :br_natural_owner do
	col :natural_owner_id, id: true
	col :natural_owner_type_id, :ref => :br_natural_owner_type, required: true
	col :alpha_code, len: 25
	col :display_name, sql: "case when natural_owner_type_id = 1 then dba else (last_name + ' ' + first_name) end",
		persisted: true, len: 321, index: true

	col :tax_id, len: 16, business_id: true
	col :tax_id_type, type: :enum, business_id: true, check: 0..5
	col :date_of_birth, type: :date
	col :legal_address_id, :ref => :br_address, required: true

	col :phone_1, len: 16
	col :phone_2, len: 16
	col :mobile_phone, len: 16
	col :preferred_contact_id, type: :long

	col :first_name, len: 64
	col :middle_name, len: 64
	col :last_name, index: true
	col :suffix, len: 16
	col :gender, type: :enum, check: 0..1
	col :legal_residency, type: :enum, check: 0..3
	col :citizenship, type: :country
	col :dependants_count, type: :byte, check: '>0'
	col :marital_status, type: :enum, check: 0..5
	col :employment_status, type: :enum, check: 0..6
	col :income_source
	col :employer
	col :nature_of_business
	col :employer_business_phone, len: 16
	col :years_with_employer, type: :byte, check: 0..100
	col :occupation
	col :employer_address_id, :ref => :br_address
	col :is_employer_finra_member
	col :is_senior_political_figure

	col :is_deceased
	col :is_pid_verified
	col :pid_type, :ref => 'ref.personal_id_types'
	col :pid_number, len: 32
	col :pid_state_code, type: :us_state
	col :pid_country_code, type: :country
	col :pid_issued, type: :date
	col :pid_expires, type: :date
	col :pid_other

	col :dba, index: true
	col :legal_name, index: true
	col :business_description, len: :max
	col :is_custodial_bank
	col :is_government_entity

	col :is_suppressed
	col :suppression_reason_id, :ref => :supTrigReasons

	col :ref => 'ref.annual_income_levels'
	col :annual_income_amount, type: :money
	col :ref => 'ref.liquid_assets_levels'
	col :liquid_assets_amount, type: :money
	col :ref => 'ref.tax_bracket_levels'
	col :estimated_net_worth_level_id, :ref => 'ref.net_worth_levels'
	col :estimated_net_worth_amount, type: :money
	col :liquid_net_worth_level_id, :ref => 'ref.net_worth_levels'
	col :liquid_net_worth_amount, type: :money
	col :ref => :annual_expenses_levels
	col :annual_expenses_amount, type: :money
	col :ref => :special_expenses_levels
	col :special_expenses_amount, type: :money
	col :ref => :special_expenses_timeframes
	col :is_assets_held_away_refused
	col :assets_held_away_total, type: :money
	col :last_cip_at

	timestamps dates: :short
end
