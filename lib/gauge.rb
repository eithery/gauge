# Contains all requires for Database Gauge applicaion.
require 'gauge/console_listener'
require 'gauge/database_inspector'
require 'gauge/db/connection'
require 'gauge/formatters/base'
require 'gauge/formatters/console_formatter'
require 'gauge/helper'
require 'gauge/repo'
require 'gauge/schema/data_column_schema'
require 'gauge/schema/data_table_schema'
require 'gauge/schema/database_schema'
require 'gauge/shell'
require 'gauge/validators/validator_base'
require 'gauge/validators/data_column_validator'
require 'gauge/validators/data_table_validator'
require 'gauge/validators/database_validator'
require 'gauge/version'

require 'active_support/core_ext/string/inflections'
require 'gli'
require 'rainbow'
require 'rainbow/ext/string'
require 'rexml/document'
require 'sequel'
