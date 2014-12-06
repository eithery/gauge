# Data table definition file.
# vld.validation_rules
# Contains validation rules metadata.

table :validation_rules, sql_schema: :vld do
  col id: true, default: :uid
  col :code, len: 10
  col :rule, len: 64, required: true
  col :application_code, len: 64, required: true
  col :context, len: 64
  col :object_code, len: 64, required: true
  col :property, len: 64, required: true
  col :message, required: true
  col :level, type: :enum, check: 0..4, required: true
  col :param1, len: 64
  col :param2, len: 64
  col :param3, len: 64
  col :param4, len: 64
  col :is_enabled, required: true, default: true
  col :comment, len: :max
end
