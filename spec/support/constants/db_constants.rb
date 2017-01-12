# Eithery Lab, 2017
# Module Gauge::DB::Constants
# Defines constants used in db objects specs.

module Gauge
  module DB
    module Constants
      TABLES = {
        :primary_reps => :dbo_primary_reps,
        :dbo_primary_reps => :dbo_primary_reps,
        'dbo.PRIMARY_rEPs' => :dbo_primary_reps,
        'primary_reps' => :dbo_primary_reps,
        :primary_REPS => :dbo_primary_reps,
        '"dbo"."primary_Reps"' => :dbo_primary_reps,
        '[rep_profile].[dbo].[primary_reps]' => :dbo_primary_reps,
        :bnr_CUSTOMER_Financial_Info => :dbo_bnr_customer_financial_info,
        'bnr.customer_financial_INFO' => :bnr_customer_financial_info,
        '"Rep_Profile"."bnr"."Customer_financial_info"' => :bnr_customer_financial_info
      }
    end
  end
end
