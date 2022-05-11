@api @skipOnOcV10
Feature: Share a file or folder that is inside a space via public link
      As an user with manager space role
      I want to be able to share the data inside the space via public link

      | role        | permissions |
      | viewer      | 1           |
      | uploader    | 4           |
      | contributor | 5           |
      | editor      | 15          |

  Note - this feature is run in CI with ACCOUNTS_HASH_DIFFICULTY set to the default for production
  See https://github.com/owncloud/ocis/issues/1542 and https://github.com/owncloud/ocis/pull/839

  Background:
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | Alice    |
      | Brian    |
      | Bob      |
    And the administrator has given "Alice" the role "Admin" using the settings api
    And user "Alice" has created a space "share sub-item" with the default quota using the GraphApi
    And user "Alice" has created a folder "folder" in space "share sub-item"
    And user "Alice" has uploaded a file inside space "share sub-item" with content "some content" to "folder/file.txt"


  Scenario Outline: An user-owner can share an entrity inside project space via public link
    When user "Alice" creates a public link share inside of space "share sub-item" with settings:
      | path        | <entity>      |
      | shareType   | 3             |
      | permissions | <permissions> |
      | password    | <password>    |
      | name        | <name>        |
      | expireDate  | <expireDate>  |
    Then the HTTP status code should be "200"
    And the OCS status code should be "200"
    And the OCS status message should be "OK"
    And the fields of the last response to user "Alice" should include
      | path | /<entity> |
    Examples:
      | entity          | permissions | password | name | expireDate               |
      | folder          | 1           | 123      | link | 2042-03-25T23:59:59+0100 |
      | folder          | 4           |          |      |                          |
      | folder          | 5           | 200      |      | 2042-03-25T23:59:59+0100 |
      | folder          | 15          |          | link |                          |
      | folder/file.txt | 1           | 123      | link | 2042-03-25T23:59:59+0100 |


  Scenario Outline: An user participant of the project space with space manager role can share an entrity inside project space via public link
    Given user "Alice" has shared a space "share sub-item" to user "Brian" with role "manager"
    When user "Brian" creates a public link share inside of space "share sub-item" with settings:
      | path        | <entity>                 |
      | shareType   | 3                        |
      | permissions | 1                        |
      | password    | 123                      |
      | name        | public link              |
      | expireDate  | 2042-03-25T23:59:59+0100 |
    Then the HTTP status code should be "200"
    And the OCS status code should be "200"
    And the OCS status message should be "OK"
    And the fields of the last response to user "Alice" should include
      | path | /<entity> |
    Examples:
      | entity          |
      | folder          |
      | folder/file.txt |


  Scenario Outline: An user participant of the project space without space manager role cannot share an entrity inside project space via public link
    Given user "Alice" has shared a space "share sub-item" to user "Brian" with role "<spaceRole>"
    When user "Brian" creates a public link share inside of space "share sub-item" with settings:
      | path        | <entity>                 |
      | shareType   | 3                        |
      | permissions | 1                        |
      | password    | 123                      |
      | name        | public link              |
      | expireDate  | 2042-03-25T23:59:59+0100 |
    Then the HTTP status code should be "404"
    And the OCS status code should be "404"
    And the OCS status message should be "No share permission"
    Examples:
      | entity          | spaceRole |
      | folder          | editor    |
      | folder          | viewer    |
      | folder/file.txt | editor    |
      | folder/file.txt | viewer    |
