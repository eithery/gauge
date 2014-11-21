# Data table definition file.
# [dbo].[br_master_account]
# Master accounts.

table :br_master_account do
  col :master_account_id, id: true
  col :master_account_number, len: 20, business_id: true

  col :registration_id, :ref => :br_registration, required: true
  col :isConverted, required: true
  col :account_title, len: :max
  col :supportsTitleUpdate, type: :bool, required: true

  col :agent_code, len: 10, index: true
  col :office_code, len: 10
  col :division_code, len: 10

  col :trustName
  col :comments, len: :max

#  col :ref => :investment_time_horizon, schema: :ref
#  col :ref => :risk_tolerance, schema: :ref

  col :has_documents_in_order
  col :documents_in_order_by

  col :is_restricted, required: true
  col :restriction_note
  col :restriction_entered, type: :datetime
  col :restriction_entered_by

  col :is_erisa_sponsored_plan
  col :is_annuity_exchanged
  col :annuity_exchanged, type: :date
  col :has_owner_finra_member
  col :has_owner_public_company_policy_maker
  col :owner_public_company_name
  col :has_owner_foreign_political_figure

  col :status, dbtype: :smallint, required: true, default: 1, check: -1..1
  col :statusChanged, type: :datetime
  col :statusChangedBy
  col :changeStatusReasonId, :ref => :accountActivationReasons
  col :purgeDate, type: :datetime

  col :mergedToAccount, len: 20
  col :mergedAt, type: :datetime
  col :mergedBy
  col :mergeReasonId, :ref => :mergeReasons

  col :is_suppressed, required: true
  col :suppression_reason_id, :ref => :supTrigReasons
  col :established_on, type: :datetime

  timestamps
end
