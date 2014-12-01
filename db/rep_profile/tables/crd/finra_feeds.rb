# Data table definition file.
# crd.finra_feeds
# Contains FINRA feeds.

table :finra_feeds, sql_schema: :crd do
  col :name, required: true
  col :display_name, required: true
  col :posted_date_tag, required: true
  col :argument_tag, required: true
  col :feed_scope, type: :enum, required: true, check: 0..1
end
