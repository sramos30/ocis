Feature: Syncing files

    As a user
    I want to be able to sync my local folders to to my owncloud server
    so that I dont have to upload and download files manually

    Background:
        Given user "Alice" has been created on the server with default attributes and without skeleton files

    @smokeTest @issue-9281
    Scenario: Syncing a file to the server
        Given user "Alice" has set up a client with default settings
        When user "Alice" creates a file "lorem-for-upload.txt" with the following content inside the sync folder
            """
            test content
            """
        And the user waits for file "lorem-for-upload.txt" to be synced
        Then as "Alice" the file "lorem-for-upload.txt" on the server should have the content "test content"


    Scenario: Syncing all files and folders from the server
        Given user "Alice" has created folder "simple-folder" on the server
        And user "Alice" has created folder "large-folder" on the server
        And user "Alice" has uploaded file on the server with content "test content" to "uploaded-lorem.txt"
        And user "Alice" has set up a client with default settings
        When the user waits for the files to sync
        Then the file "uploaded-lorem.txt" should exist on the file system
        And the file "uploaded-lorem.txt" should exist on the file system with the following content
            """
            test content
            """
        And the folder "simple-folder" should exist on the file system
        And the folder "large-folder" should exist on the file system


    Scenario: Syncing a file from the server and creating a conflict
        Given user "Alice" has uploaded file on the server with content "server content" to "/conflict.txt"
        And user "Alice" has set up a client with default settings
        And the user has paused the file sync
        And the user has changed the content of local file "conflict.txt" to:
            """
            client content
            """
        And user "Alice" has uploaded file on the server with content "changed server content" to "/conflict.txt"
        When the user resumes the file sync on the client
        And the user clicks on the activity tab
        And the user selects "Not Synced" tab in the activity
        # Then a conflict warning should be shown for 1 files
        Then the table of conflict warnings should include file "conflict.txt"
        And the file "conflict.txt" should exist on the file system with the following content
            """
            changed server content
            """
        And a conflict file for "conflict.txt" should exist on the file system with the following content
            """
            client content
            """


    Scenario: Sync all is selected by default
        Given user "Alice" has created folder "simple-folder" on the server
        And user "Alice" has created folder "large-folder" on the server
        And the user has started the client
        And the user has added the following account information:
            | server   | %local_server% |
            | user     | Alice          |
            | password | 1234           |
        When the user opens chose_what_to_sync dialog
        Then the dialog chose_what_to_sync should be visible
        And the sync all checkbox should be checked


    Scenario: Sync only one folder from the server
        Given user "Alice" has created folder "simple-folder" on the server
        And user "Alice" has created folder "large-folder" on the server
        And the user has started the client
        And the user has added the following account information:
            | server   | %local_server% |
            | user     | Alice          |
            | password | 1234           |
        When the user selects the following folders to sync:
            | folder        |
            | simple-folder |
        And the user connects the account
        Then the folder "simple-folder" should exist on the file system
        But the folder "large-folder" should not exist on the file system


    Scenario: Connect account with manual sync folder option
        Given user "Alice" has created folder "simple-folder" on the server
        And user "Alice" has created folder "large-folder" on the server
        And user "Alice" has uploaded file on the server with content "test content" to "lorem.txt"
        And the user has started the client
        And the user has added the following account information:
            | server   | %local_server% |
            | user     | Alice          |
            | password | 1234           |
        When the user selects manual sync folder option
        And the user connects the account
        Then the folder "simple-folder" should not exist on the file system
        But the folder "large-folder" should not exist on the file system
        And the file "lorem.txt" should not exist on the file system


    Scenario: sort folders list by name and size
        Given user "Alice" has created folder "123Folder" on the server
        And user "Alice" has uploaded file on the server with content "small" to "123Folder/lorem.txt"
        And user "Alice" has created folder "aFolder" on the server
        And user "Alice" has uploaded file on the server with content "more contents" to "aFolder/lorem.txt"
        And user "Alice" has created folder "bFolder" on the server
        And the user has started the client
        And the user has added the following account information:
            | server   | %local_server% |
            | user     | Alice          |
            | password | 1234           |
        When the user opens chose_what_to_sync dialog
        # folders are sorted by name in ascending order by default
        Then the folders should be in the following order:
            | folder    |
            | 123Folder |
            | aFolder   |
            | bFolder   |
        # sort folder by name in descending order
        When the user sorts the folder list by "Name"
        Then the folders should be in the following order:
            | folder    |
            | bFolder   |
            | aFolder   |
            | 123Folder |
        # sort folder by size in ascending order
        When the user sorts the folder list by "Size"
        Then the folders should be in the following order:
            | folder    |
            | bFolder   |
            | 123Folder |
            | aFolder   |
        # sort folder by size in descending order
        When the user sorts the folder list by "Size"
        Then the folders should be in the following order:
            | folder    |
            | aFolder   |
            | 123Folder |
            | bFolder   |


    Scenario Outline: Syncing a folder to the server
        Given user "Alice" has set up a client with default settings
        When user "Alice" creates a folder <foldername> inside the sync folder
        And the user waits for folder <foldername> to be synced
        Then as "Alice" folder <foldername> should exist on the server
        Examples:
            | foldername                                                               |
            | "myFolder"                                                               |
            | "really long folder name with some spaces and special char such as $%ñ&" |
            | "folder with space at end "                                              |


    Scenario: Many subfolders can be synced
        Given user "Alice" has created folder "parent" on the server
        And user "Alice" has set up a client with default settings
        When user "Alice" creates a folder "parent/subfolderEmpty1" inside the sync folder
        And user "Alice" creates a folder "parent/subfolderEmpty2" inside the sync folder
        And user "Alice" creates a folder "parent/subfolderEmpty3" inside the sync folder
        And user "Alice" creates a folder "parent/subfolderEmpty4" inside the sync folder
        And user "Alice" creates a folder "parent/subfolderEmpty5" inside the sync folder
        And user "Alice" creates a folder "parent/subfolder1" inside the sync folder
        And user "Alice" creates a folder "parent/subfolder2" inside the sync folder
        And user "Alice" creates a folder "parent/subfolder3" inside the sync folder
        And user "Alice" creates a folder "parent/subfolder4" inside the sync folder
        And user "Alice" creates a folder "parent/subfolder5" inside the sync folder
        And user "Alice" creates a file "parent/subfolder1/test.txt" with the following content inside the sync folder
            """
            test content
            """
        And user "Alice" creates a file "parent/subfolder2/test.txt" with the following content inside the sync folder
            """
            test content
            """
        And user "Alice" creates a file "parent/subfolder3/test.txt" with the following content inside the sync folder
            """
            test content
            """
        And user "Alice" creates a file "parent/subfolder4/test.txt" with the following content inside the sync folder
            """
            test content
            """
        And user "Alice" creates a file "parent/subfolder5/test.txt" with the following content inside the sync folder
            """
            test content
            """
        And the user waits for the files to sync
        Then as "Alice" folder "parent/subfolderEmpty1" should exist on the server
        And as "Alice" folder "parent/subfolderEmpty2" should exist on the server
        And as "Alice" folder "parent/subfolderEmpty3" should exist on the server
        And as "Alice" folder "parent/subfolderEmpty4" should exist on the server
        And as "Alice" folder "parent/subfolderEmpty5" should exist on the server
        And as "Alice" folder "parent/subfolder1" should exist on the server
        And as "Alice" folder "parent/subfolder2" should exist on the server
        And as "Alice" folder "parent/subfolder3" should exist on the server
        And as "Alice" folder "parent/subfolder4" should exist on the server
        And as "Alice" folder "parent/subfolder5" should exist on the server


    Scenario: Both original and copied folders can be synced
        Given user "Alice" has set up a client with default settings
        And user "Alice" has created a folder "original" inside the sync folder
        And user "Alice" has created a file "original/test.txt" with the following content inside the sync folder
            """
            test content
            """
        When the user copies the folder "original" to "copied"
        And the user waits for folder "copied" to be synced
        Then as "Alice" folder "original" should exist on the server
        And as "Alice" folder "copied" should exist on the server

    @issue-9281
    Scenario: Verify that you can create a subfolder with long name
        Given user "Alice" has set up a client with default settings
        And user "Alice" has created a folder "Folder1" inside the sync folder
        When user "Alice" creates a folder "Folder1/really long folder name with some spaces and special char such as $%ñ&" inside the sync folder
        And user "Alice" creates a file "Folder1/really long folder name with some spaces and special char such as $%ñ&/test.txt" with the following content inside the sync folder
            """
            test content
            """
        And the user waits for the files to sync
        Then as "Alice" folder "Folder1" should exist on the server
        And as "Alice" folder "Folder1/really long folder name with some spaces and special char such as $%ñ&" should exist on the server
        And the file "Folder1/really long folder name with some spaces and special char such as $%ñ&/test.txt" should exist on the file system with the following content
            """
            test content
            """
        And as "Alice" the file "Folder1/really long folder name with some spaces and special char such as $%ñ&/test.txt" on the server should have the content "test content"


    Scenario: Verify pre existing folders in local (Desktop client) are copied over to the server
        Given user "Alice" has created a folder "Folder1" inside the sync folder
        And user "Alice" has created a folder "Folder1/subFolder1" inside the sync folder
        And user "Alice" has created a folder "Folder1/subFolder1/subFolder2" inside the sync folder
        And user "Alice" has set up a client with default settings
        When the user waits for folder "Folder1" to be synced
        Then as "Alice" folder "Folder1" should exist on the server
        And as "Alice" folder "Folder1/subFolder1" should exist on the server
        And as "Alice" folder "Folder1/subFolder1/subFolder2" should exist on the server

    @skip @issue-9281
    Scenario: Filenames that are rejected by the server are reported
        Given user "Alice" has set up a client with default settings
        And user "Alice" has created a folder "Folder1" inside the sync folder
        When user "Alice" creates a file "Folder1/a\\a.txt" with the following content inside the sync folder
            """
            test content
            """
        And the user waits for folder "Folder1" to be synced
        Then as "Alice" folder "Folder1" should exist on the server
        When the user clicks on the activity tab
        And the user selects "Not Synced" tab in the activity
        Then the file "Folder1/a\\a.txt" should be blacklisted


    Scenario Outline: Verify one empty folder with a length longer than the allowed limit will not be synced
        Given user "Alice" has set up a client with default settings
        And user "Alice" has created a folder "<foldername>" inside the sync folder
        When user "Alice" creates a folder "<foldername>/<foldername>" inside the sync folder
        And user "Alice" creates a folder "<foldername>/<foldername>/<foldername>" inside the sync folder
        And user "Alice" creates a folder "<foldername>/<foldername>/<foldername>/<foldername>" inside the sync folder
        And user "Alice" creates a folder "<foldername>/<foldername>/<foldername>/<foldername>/<foldername>" inside the sync folder
        And the user waits for folder "<foldername>/<foldername>/<foldername>/<foldername>/<foldername>" to be synced
        Then as "Alice" folder "<foldername>" should exist on the server
        And as "Alice" folder "<foldername>/<foldername>" should exist on the server
        And as "Alice" folder "<foldername>/<foldername>/<foldername>" should exist on the server
        And as "Alice" folder "<foldername>/<foldername>/<foldername>/<foldername>" should exist on the server
        And as "Alice" folder "<foldername>/<foldername>/<foldername>/<foldername>/<foldername>" should exist on the server
        Examples:
            | foldername                                                      |
            | An empty folder which name is obviously more than 59 characters |


    Scenario: Invalid system names are synced in linux
        Given user "Alice" has created folder "CON" on the server
        And user "Alice" has created folder "test%" on the server
        And user "Alice" has uploaded file on the server with content "server content" to "/PRN"
        And user "Alice" has uploaded file on the server with content "server content" to "/foo%"
        And user "Alice" has set up a client with default settings
        When the user waits for the files to sync
        Then the folder "CON" should exist on the file system
        And the folder "test%" should exist on the file system
        And the file "PRN" should exist on the file system
        And the file "foo%" should exist on the file system
        And as "Alice" folder "CON" should exist on the server
        And as "Alice" folder "test%" should exist on the server
        And as "Alice" file "/PRN" should exist on the server
        And as "Alice" file "/foo%" should exist on the server


    Scenario: various types of files can be synced from server to client
        Given user "Alice" has created folder "simple-folder" on the server
        And user "Alice" has uploaded file "testavatar.png" to "simple-folder/testavatar.png" on the server
        And user "Alice" has uploaded file "testavatar.jpg" to "simple-folder/testavatar.jpg" on the server
        And user "Alice" has uploaded file "testavatar.jpeg" to "simple-folder/testavatar.jpeg" on the server
        And user "Alice" has uploaded file "testimage.mp3" to "simple-folder/testimage.mp3" on the server
        And user "Alice" has uploaded file "test_video.mp4" to "simple-folder/test_video.mp4" on the server
        And user "Alice" has uploaded file "simple.pdf" to "simple-folder/simple.pdf" on the server
        And user "Alice" has set up a client with default settings
        When the user waits for the files to sync
        Then the folder "simple-folder" should exist on the file system
        And the file "simple-folder/testavatar.png" should exist on the file system
        And the file "simple-folder/testavatar.jpg" should exist on the file system
        And the file "simple-folder/testavatar.jpeg" should exist on the file system
        And the file "simple-folder/testimage.mp3" should exist on the file system
        And the file "simple-folder/test_video.mp4" should exist on the file system
        And the file "simple-folder/simple.pdf" should exist on the file system


    Scenario: various types of files can be synced from client to server
        Given user "Alice" has set up a client with default settings
        And user "Alice" has created the following files inside the sync folder:
            | files            |
            | /testavatar.png  |
            | /testavatar.jpg  |
            | /testavatar.jpeg |
            | /testaudio.mp3   |
            | /test_video.mp4  |
            | /simple.txt      |
        When the user waits for the files to sync
        Then as "Alice" file "testavatar.png" should exist on the server
        And as "Alice" file "testavatar.jpg" should exist on the server
        And as "Alice" file "testavatar.jpeg" should exist on the server
        And as "Alice" file "testaudio.mp3" should exist on the server
        And as "Alice" file "test_video.mp4" should exist on the server
        And as "Alice" file "simple.txt" should exist on the server