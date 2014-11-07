# Data table definition file.
# [dbo].[employees]
# Contains personal information about reps.

table :employees do
  col :firstName
  col :middleName
  col :lastName { required }
  col :nickName
  col :designation
  col :displayName
  col :ssn, len: 16
  col :employeeCode, len: 16
  col :gender, type: :char { check %(F M) }
  col :dateOfBirth, type: :datetime
  col :businessAddressId, :ref => :addresses
  col :residenceAddressId, :ref => :addresses
  col :residenceAddress2Id, :ref => :addresses
  col :preferredMailingAddress, type: :enum { required; check 0..3 }
  col :contactsId, :ref => :contacts
  col :description, len: :max
  col :photo, type: :blob
end
