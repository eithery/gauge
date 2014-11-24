# Data table definition file.
# [dbo].[clubs]
# Contains available rep clubs and awards.

table :clubs do
  col :code, len: 20, required: true
  col :name, required: true
  col :description, len: :max
end
