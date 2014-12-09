# Database definition file.
# Each 'database' declaration defines metadata for one particular database.
#
# Example:
#   database <database_name>, sql_name: <sql_database_name>
#
#   <database_name> - logical database name used in most command-line operations;
#   :sql_name       - represents physical SQL database name (the same as logical database name by default).
#
# Data tables metadata files can be found in db/<database_name> folder and all its subfolders.

database :rep_profile, sql_name: 'RepProfile', home: 'c:/dbs/gauge'
database :package_me, sql_name: 'PackageMe', home: 'c:/dbs/gauge'

# Test DB metadata. Used for test purposes only.
database :test_db_green
database :test_db_red
