# Data table definition file.
# dbo.product_type
# Contains available product types.

table :product_type do
  col :type_id, len: 12, id: true
  col :type_desc
  col :productTypeCategoryId, :ref => :productTypeCategories, required: true
  col :prod_group_cd_1, type: :char
  col :prod_group_cd_2, type: :char
  col :prod_group_cd_3, type: :char
  col :prod_group_cd_4, type: :char
  col :prepopulateStateOfSale, type: :bool, required: true
  col :allowAutoDeactivation, required: true, default: true
  col :is_proprietary, required: true
  col :is_required_target_excess_commissions, required: true
end
