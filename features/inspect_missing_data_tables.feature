@wip
Feature: Inspect missing data tables.

	In order to synchronize the target database schema
	As a gauge user
	I need to know the list of missing data tables in my database.

	Scenario: No missing data tables.
		Given gauge application
		When I run "check" command passing "gauge_db_green" argument as the database name
		Then the app should display "Inspecting 'gauge_db_green' database..." in "cyan" color
		And the app should display "Inspecting 'gauge_db_green' database - ok" in "green" color

	Scenario: One missing data table.
		Given gauge application
		When I run "check" command passing "gauge_db_yellow" argument as the database name
		Then the app should display "Inspecting 'gauge_db_yellow' database..." in "cyan" color

	Scenario: Few missing data tables.
		Given gauge application
		When I run "check" command passing "gauge_db_red" argument as the database name
		Then the app should display "Inspecting 'gauge_db_red' database..." in "cyan" color
