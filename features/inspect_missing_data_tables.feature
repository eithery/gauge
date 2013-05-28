Feature: Inspect missing data tables.

	In order to synchronize the target database schema
	As a gauge user
	I need to know the list of missing data tables in my database.

	@wip
	Scenario: No missing data tables.
		Given gauge application
		When I run "check" command with "gauge_db_green" argument
		Then the app should display "Inspecting 'gauge_db_green' database..." in "cyan"

	Scenario: One missing data table.
		Given gauge application
		When I run "check" command with "gauge_db_yellow" argument
		Then the app should display "Inspecting 'gauge_db_yellow' database..." in "cyan"

	Scenario: Few missing data tables.
		Given gauge application
		When I run "check" command with "gauge_db_red" argument
		Then the app should display "Inspecting 'gauge_db_red' database..." in "cyan"
