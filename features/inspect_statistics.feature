@wip
Feature: Inspect statistics.

	In order to track the current status and results of database inspect operation
	As a gauge user
	I need to get some statistical info during inspection process

	Scenario: Display the name of the database being inspected.
		Given gauge application
		When I run "check" command passing "gauge_db_green" argument as the database name
		Then the app should display "Inspecting 'gauge_db_green' database..." in "cyan" color

	Scenario: Successfull inspection result
		Given gauge application
		When I run "check" command passing "gauge_db_green" argument as the database name
		Then the app should display "Inspecting 'gauge_db_green' database - ok" in "green" color

	Scenario: Failed inspection result
		Given gauge application
		When I run "check" command passing "gauge_db_red" argument as the database name
		Then the app should display "Inspecting 'gauge_db_red' database - failed" in "red" color
