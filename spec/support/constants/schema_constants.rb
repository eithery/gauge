# Eithery Lab, 2017
# Module Gauge::Schema::Constants
# Defines constants used in db schema specs.

module Gauge
  module Schema
    module Constants
      REPS_TABLE_NAMES = [:primary_reps, 'primary_reps', 'Primary_REPS', '[primary_reps]',
        'dbo.primary_reps', '[dbo].[primary_reps]']
      REF_TABLE_NAMES = [:ref_contract_types, 'ref.contract_types', '[ref].[contract_types]']
      EXISTING_TABLE_NAMES = REPS_TABLE_NAMES + REF_TABLE_NAMES
      MISSING_TABLE_NAMES = [:missing_table, 'missing_table']
    end
  end
end
