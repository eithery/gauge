# Data table definition file.
# dbo.accountActivationReasons
# Contains reasons used to activate/deactive master accounts.

table :accountActivationReasons do
  col :name, required: true, unique: true
  col :description, len: :max
  col :type, type: :enum, required: true, check: 0..1
end
