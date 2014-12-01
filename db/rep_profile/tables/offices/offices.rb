# Data table definition file.
# dbo.offices
# Contains offices hierarchy.

table :offices do
  col :parentId, :ref => :offices
  col :ref => :office_types, required: true
  col :treeLevel, type: :byte, required: true
  col :code, len: 10, required: true, business_id: true
  col :tax_id, len: 9, check: 'len(tax_id) = 9'
  col :crd_number, len: 10
  col :name, required: true
  col :description, len: :max
  col :addressId, :ref => :addresses
  col :mailingAddressId, :ref => :addresses
  col :contactsId, :ref => :contacts
  col :is_broker_dealer, required: true

  timestamps naming: :camel, dates: :short
end
