@api @skipOnOcV10
Feature: State of the quota
  As a user
  I want to be able to see the state of the quota and and not let the quota overrun:
  quota state indication:
  | 0 - 75%  | normal   |
  | 76 - 90% | nearing  |
  | 91 - 99% | critical |
  | 100 %    | exceeded |

  Note - this feature is run in CI with ACCOUNTS_HASH_DIFFICULTY set to the default for production
  See https://github.com/owncloud/ocis/issues/1542 and https://github.com/owncloud/ocis/pull/839

  Background:
    Given user "Alice" has been created with default attributes and without skeleton files
    And the administrator has given "Alice" the role "Admin" using the settings api


  Scenario Outline: Quota information is returned in the list of spaces returned via the Graph API
    Given user "Alice" has created a space "<spaceName>" of type "project" with quota "<total>"
    And user "Alice" has uploaded a file inside space "<spaceName>" with content "<fileContent>" to "test.txt"
    When user "Alice" lists all available spaces via the GraphApi
    Then the json responded should contain a space "<spaceName>" with these key and value pairs:
      | key              | value       |
      | name             | <spaceName> |
      | quota@@@state    | <state>     |
      | quota@@@total    | <total>     |
      | quota@@@remaining| <remaining> |
      | quota@@@used     | <used>      |
    Examples:
      | spaceName | fileContent                                                                                           | state    | total | remaining | used |
      | Quota1%   | 1                                                                                                    | normal   | 100   | 99        | 1    |
      | Quota75%  | 123456789 123456789 123456789 123456789 123456789 123456789 123456789 12345                          | normal   | 100   | 25        | 75   |
      | Quota76%  | 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456                         | nearing  | 100   | 24        | 76   |
      | Quota90%  | 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890           | nearing  | 100   | 10        | 90   |
      | Quota91%  | 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 1          | critical | 100   | 9         | 91   |
      | Quota99%  | 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789  | critical | 100   | 1         | 99   |
      | Quota100% | 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890 | exceeded | 100   | 0         | 100  |


  Scenario: A file cannot be uploaded if there is insufficient quota
    Given user "Alice" has created a space "Project Alfa" of type "project" with quota "10"
    When user "Alice" uploads a file inside space "Project Alfa" with content "More than 10 bytes" to "test.txt" using the WebDAV API
    Then the HTTP status code should be "507"


  Scenario: A folder can be created even if there is insufficient quota for file content
    Given user "Alice" has created a space "Project Beta" of type "project" with quota "7"
    And user "Alice" has uploaded a file inside space "Project Beta" with content "7 bytes" to "test.txt"
    When user "Alice" creates a folder "NewFolder" in space "Project Beta" using the WebDav Api
    Then the HTTP status code should be "201"
    And for user "Alice" the space "Project Beta" should contain these entries:
      | NewFolder |


  Scenario: A file can be overwritten if there is enough quota
    Given user "Alice" has created a space "Project Gamma" of type "project" with quota "10"
    And user "Alice" has uploaded a file inside space "Project Gamma" with content "7 bytes" to "test.txt"
    When user "Alice" uploads a file inside space "Project Gamma" with content "0010 bytes" to "test.txt" using the WebDAV API
    Then the HTTP status code should be "204"


  Scenario: A file cannot be overwritten if there is insufficient quota
    When user "Alice" has created a space "Project Delta" of type "project" with quota "10"
    And user "Alice" has uploaded a file inside space "Project Delta" with content "7 bytes" to "test.txt"
    When user "Alice" uploads a file inside space "Project Delta" with content "00011 bytes" to "test.txt" using the WebDAV API
    Then the HTTP status code should be "507"
