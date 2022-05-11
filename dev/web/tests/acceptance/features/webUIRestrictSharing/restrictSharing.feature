@issue-ocis-1317
Feature: restrict Sharing
  As an admin
  I want to be able to restrict the sharing function
  So that users can only share files with specific users and groups

  Background:
    Given the setting "shareapi_auto_accept_share" of app "core" has been set to "no" in the server
    And the administrator has set the default folder for received shares to "Shares" in the server
    And these users have been created with default attributes and without skeleton files in the server:
      | username |
      | Alice    |
      | Brian    |
      | Carol    |
    And these users have been created with initialization and without skeleton files in the server:
      | username | password  | displayname   | email             |
      | Alison   | %regular% | Alison Cooper | alson@oc.com.np |
    And these groups have been created in the server:
      | groupname |
      | grp1      |
      | grp2      |
    And user "Alice" has been added to group "grp1" in the server
    And user "Brian" has been added to group "grp1" in the server
    And user "Carol" has been added to group "grp2" in the server
    And user "Alison" has been added to group "grp2" in the server
    And user "Brian" has created folder "simple-folder" in the server
    And user "Brian" has uploaded file "lorem.txt" to "simple-folder/lorem.txt" in the server
    And user "Brian" has logged in using the webUI

  @smokeTest
  Scenario: Restrict users to only share with users in their groups
    Given the setting "shareapi_only_share_with_group_members" of app "core" has been set to "yes" in the server
    When the user opens the share dialog for folder "simple-folder" using the webUI

    And the user types "Ali" in the share-with-field
    Then "user" "Alice Hansen" should be listed in the autocomplete list on the webUI
    But "user" "Alison Cooper" should not be listed in the autocomplete list on the webUI

  @smokeTest
  Scenario: Restrict users to only share with groups they are member of
    Given the setting "shareapi_only_share_with_membership_groups" of app "core" has been set to "yes" in the server
    When the user opens the share dialog for folder "simple-folder" using the webUI

    And the user types "grp" in the share-with-field
    Then "group" "grp1" should be listed in the autocomplete list on the webUI
    But "group" "grp2" should not be listed in the autocomplete list on the webUI


  Scenario: Do not restrict users to only share with groups they are member of
    Given the setting "shareapi_only_share_with_membership_groups" of app "core" has been set to "no" in the server
    When the user shares folder "simple-folder" with group "grp2" as "Viewer" using the webUI
    And user "Carol" accepts the share "Shares/simple-folder" offered by user "Brian" using the sharing API in the server
    Then as "Carol" folder "/Shares/simple-folder" should exist in the server

  @smokeTest
  Scenario: Forbid sharing with groups
    Given the setting "shareapi_allow_group_sharing" of app "core" has been set to "no" in the server
    When the user opens the share dialog for folder "simple-folder" using the webUI

    And the user types "grp" in the share-with-field
    Then "group" "grp1" should not be listed in the autocomplete list on the webUI
    And "group" "grp2" should not be listed in the autocomplete list on the webUI
