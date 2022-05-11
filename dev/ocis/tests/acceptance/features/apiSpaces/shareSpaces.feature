@api @skipOnOcV10
Feature: Share spaces
  As the owner of a space
  I want to be able to add members to a space, and to remove access for them

  Note - this feature is run in CI with ACCOUNTS_HASH_DIFFICULTY set to the default for production
  See https://github.com/owncloud/ocis/issues/1542 and https://github.com/owncloud/ocis/pull/839

  Background:
    Given user "Alice" has been created with default attributes and without skeleton files
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Bob" has been created with default attributes and without skeleton files
    And the administrator has given "Alice" the role "Admin" using the settings api


  Scenario: A user can share a space to another user with role viewer
    Given user "Alice" has created a space "Space to share" of type "project" with quota "10"
    When user "Alice" shares a space "Space to share" to user "Brian" with role "viewer"
    Then the HTTP status code should be "200"
    And the OCS status code should be "200"
    And the OCS status message should be "OK"


  Scenario: A user can share a space to another user with role editor
    Given user "Alice" has created a space "Space to share with role editor" of type "project" with quota "10"
    When user "Alice" shares a space "Space to share with role editor" to user "Brian" with role "editor"
    Then the HTTP status code should be "200"
    And the OCS status code should be "200"
    And the OCS status message should be "OK"


  Scenario: A user can see that a received shared space is available
    Given user "Alice" has created a space "Share space to Brian" of type "project" with quota "10"
    And user "Alice" has shared a space "Share space to Brian" to user "Brian" with role "viewer"
    When user "Brian" lists all available spaces via the GraphApi
    Then the json responded should contain a space "Share space to Brian" with these key and value pairs:
      | key               | value                |
      | driveType         | project              |
      | id                | %space_id%           |
      | name              | Share space to Brian |


  Scenario: A user can see who has been granted access
    Given user "Alice" has created a space "Share space to Brian" of type "project" with quota "10"
    And user "Alice" has shared a space "Share space to Brian" to user "Brian" with role "viewer"
    When user "Alice" lists all available spaces via the GraphApi
    Then the json responded should contain a space "Share space to Brian" granted to "Brian" with these key and value pairs:
      | key                                                    | value      |
      | root@@@permissions@@@1@@@grantedTo@@@0@@@user@@@id     | %user_id%  |
      | root@@@permissions@@@1@@@roles@@@0                     | viewer     |


  Scenario: A user can see a file in a received shared space
    Given user "Alice" has created a space "Share space with file" of type "project" with quota "10"
    And user "Alice" has uploaded a file inside space "Share space with file" with content "Test" to "test.txt"
    When user "Alice" has shared a space "Share space with file" to user "Brian" with role "viewer"
    Then for user "Brian" the space "Share space with file" should contain these entries:
      | test.txt |


  Scenario: A user can see a folder in received shared space
    Given user "Alice" has created a space "Share space with folder" of type "project" with quota "10"
    And user "Alice" has created a folder "Folder Main" in space "Share space with folder"
    When user "Alice" has shared a space "Share space with folder" to user "Brian" with role "viewer"
    Then for user "Brian" the space "Share space with folder" should contain these entries:
      | Folder Main |


  Scenario: When a user unshares a space, the space becomes unavailable to the receiver
    Given user "Alice" has created a space "Unshare space" of type "project" with quota "10"
    And user "Alice" has shared a space "Unshare space" to user "Brian" with role "viewer"
    When user "Brian" lists all available spaces via the GraphApi
    Then the json responded should contain a space "Unshare space" with these key and value pairs:
      | key       | value         |
      | driveType | project       |
      | id        | %space_id%    |
      | name      | Unshare space |
    When user "Alice" unshares a space "Unshare space" to user "Brian"
    Then the HTTP status code should be "200"
    And user "Brian" lists all available spaces via the GraphApi
    And the json responded should not contain a space with name "Unshare space"


  Scenario: A user can add another user to the space managers to enable him
    Given user "Alice" has created a space "Multiple Managers" of type "project" with quota "10"
    And user "Alice" has uploaded a file inside space "Multiple Managers" with content "Test" to "test.txt"
    When user "Alice" has shared a space "Multiple Managers" to user "Brian" with role "manager"
    And user "Brian" lists all available spaces via the GraphApi
    Then the json responded should contain a space "Multiple Managers" granted to "Brian" with role "manager"
    When user "Brian" has shared a space "Multiple Managers" to user "Bob" with role "viewer"
    And user "Bob" lists all available spaces via the GraphApi
    Then the json responded should contain a space "Multiple Managers" granted to "Bob" with role "viewer"
    And for user "Bob" the space "Multiple Managers" should contain these entries:
      | test.txt |
