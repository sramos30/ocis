Changelog for ownCloud Web [unreleased] (UNRELEASED)
=======================================
The following sections list the changes in ownCloud web unreleased relevant to
ownCloud admins and users.

[unreleased]: https://github.com/owncloud/web/compare/v5.3.0...master

Summary
-------

* Bugfix - Accessible breadcrumb itemcount: [#6690](https://github.com/owncloud/web/pull/6690)
* Bugfix - AppBar ViewOptions alignment: [#6662](https://github.com/owncloud/web/pull/6662)
* Bugfix - Hide sidebar toggle button on spaces projects page: [#6690](https://github.com/owncloud/web/pull/6690)
* Bugfix - Use oC10 navigation entry names: [#6656](https://github.com/owncloud/web/pull/6656)
* Bugfix - TopBar on redirect: [#6704](https://github.com/owncloud/web/pull/6704)
* Bugfix - Unsticky appbar position: [#6708](https://github.com/owncloud/web/pull/6708)
* Enhancement - Archive download for oc10 backend: [#6239](https://github.com/owncloud/web/issues/6239)
* Enhancement - Editor role for single file public links: [#6618](https://github.com/owncloud/web/pull/6618)
* Enhancement - Full screen external apps: [#6688](https://github.com/owncloud/web/pull/6688)
* Enhancement - Make some UI elements/actions optional: [#6618](https://github.com/owncloud/web/pull/6618)
* Enhancement - PDF viewer: [#6654](https://github.com/owncloud/web/pull/6654)
* Enhancement - Permission-based visibility of upload and create buttons: [#6690](https://github.com/owncloud/web/pull/6690)
* Enhancement - Remove public links from SharedWithOthers page: [#5976](https://github.com/owncloud/web/issues/5976)
* Enhancement - Add "Shared with" column for "Shared with me" page: [#6140](https://github.com/owncloud/web/issues/6140)
* Enhancement - Spaces quota unlimited option: [#6693](https://github.com/owncloud/web/pull/6693)
* Enhancement - Spaces context menus: [#6659](https://github.com/owncloud/web/pull/6659)
* Enhancement - Spaces group sharing: [#6639](https://github.com/owncloud/web/pull/6639)
* Enhancement - Spaces link sharing: [#6633](https://github.com/owncloud/web/pull/6633)
* Enhancement - Space name in breadcrumb: [#6662](https://github.com/owncloud/web/pull/6662)
* Enhancement - Spaces overview topbar layout: [#6642](https://github.com/owncloud/web/pull/6642)
* Enhancement - Update ODS to v13.1.0-rc.1: [#6708](https://github.com/owncloud/web/pull/6708)

Details
-------

* Bugfix - Accessible breadcrumb itemcount: [#6690](https://github.com/owncloud/web/pull/6690)

   Our breadcrumbs announce the amount of resources inside a folder. Due to a bug the calculated
   number wasn't announced correctly, which we have resolved.

   https://github.com/owncloud/web/issues/6022
   https://github.com/owncloud/web/pull/6690

* Bugfix - AppBar ViewOptions alignment: [#6662](https://github.com/owncloud/web/pull/6662)

   We have fixed a visual glitch that rendered the ViewOptions in the AppBar on the left side
   instead of right-aligned if no Breadcrumbs or SharesNavigation is present.

   https://github.com/owncloud/web/issues/6685
   https://github.com/owncloud/web/pull/6662

* Bugfix - Hide sidebar toggle button on spaces projects page: [#6690](https://github.com/owncloud/web/pull/6690)

   We have hidden the sidebar toggle button on the spaces projects page to avoid user confusion.

   https://github.com/owncloud/web/pull/6690

* Bugfix - Use oC10 navigation entry names: [#6656](https://github.com/owncloud/web/pull/6656)

   When fetching navigation entries from oC10, we previously used the app's names. This caused
   issues when the navigation entry ID and the app ID differ. Also, the navigation entries did not
   match with the ones in the classic UI. This has been fixed as we now use the navigation entry name,
   which falls back to the app name if not given.

   https://github.com/owncloud/web/issues/6585
   https://github.com/owncloud/web/pull/6656

* Bugfix - TopBar on redirect: [#6704](https://github.com/owncloud/web/pull/6704)

   We fixed a visual glitch that showed the topbar on redirect pages.

   https://github.com/owncloud/web/issues/6527
   https://github.com/owncloud/web/pull/6704

* Bugfix - Unsticky appbar position: [#6708](https://github.com/owncloud/web/pull/6708)

   After recent changes to the files appbar, it wouldn't be visible when scrolling inside the
   table. This has been resolved.

   https://github.com/owncloud/web/issues/6696
   https://github.com/owncloud/web/pull/6708

* Enhancement - Archive download for oc10 backend: [#6239](https://github.com/owncloud/web/issues/6239)

   We now offer archive downloads (multifile or folder) as archive with oc10 backends. Since oc10
   archive downloads are path based this could only be made possible on pages that follow the
   folder hierarchy of the logged in user. In other words: on favorites pages the archive download
   is unavailable for oc10 backends as the selected files/folders don't necessarily share the
   same parent folder.

   https://github.com/owncloud/web/issues/6239
   https://github.com/owncloud/web/pull/6697

* Enhancement - Editor role for single file public links: [#6618](https://github.com/owncloud/web/pull/6618)

   Allow creating a public link with editor role for a single file. Only available in oCIS.

   https://github.com/owncloud/web/pull/6618

* Enhancement - Full screen external apps: [#6688](https://github.com/owncloud/web/pull/6688)

   It allows, for example, presentation apps to enter full screen.

   https://github.com/owncloud/web/pull/6688

* Enhancement - Make some UI elements/actions optional: [#6618](https://github.com/owncloud/web/pull/6618)

   Make renaming a share, permanently deleting files and showing the custom permissions role
   optional via capabilities. By default, all of these options are enabled/showed.

   Capabilities: * capabilities.files_sharing.can_rename *
   capabilities.files.permanent_deletion * capabilities.files_sharing.allow_custom

   https://github.com/owncloud/web/issues/6324
   https://github.com/owncloud/web/pull/6618

* Enhancement - PDF viewer: [#6654](https://github.com/owncloud/web/pull/6654)

   We've added a lightweight PDF viewer app which allows the user to bookmark PDF files.

   https://github.com/owncloud/web/pull/6654

* Enhancement - Permission-based visibility of upload and create buttons: [#6690](https://github.com/owncloud/web/pull/6690)

   Instead of showing disabled "Upload" and "New" buttons on public links with insufficient
   permissions, we now hide them for the page visitor.

   https://github.com/owncloud/web/issues/5618
   https://github.com/owncloud/web/pull/6690

* Enhancement - Remove public links from SharedWithOthers page: [#5976](https://github.com/owncloud/web/issues/5976)

   We've removed links from the shared-with-others page as those belong in the `Shared via link`
   page (and already exist there).

   https://github.com/owncloud/web/issues/5976
   https://github.com/owncloud/web/pull/6612

* Enhancement - Add "Shared with" column for "Shared with me" page: [#6140](https://github.com/owncloud/web/issues/6140)

   We've added the "Shared with" column for incoming shares in the "Shared with me" page and
   changed the order of the column to follow the "Share owner" column.

   https://github.com/owncloud/web/issues/6140
   https://github.com/owncloud/web/pull/6699

* Enhancement - Spaces quota unlimited option: [#6693](https://github.com/owncloud/web/pull/6693)

   Space quota can now be set to unlimited

   https://github.com/owncloud/web/issues/6470
   https://github.com/owncloud/web/pull/6693

* Enhancement - Spaces context menus: [#6659](https://github.com/owncloud/web/pull/6659)

   Spaces context menus have been adjusted visibly to match the other available context menus.
   Also, the corresponding component has been abstracted in the course of this. This cleans up a
   lot of (duplicated) code across the spaces views and makes future adjustments easier.

   https://github.com/owncloud/web/issues/6634
   https://github.com/owncloud/web/pull/6659

* Enhancement - Spaces group sharing: [#6639](https://github.com/owncloud/web/pull/6639)

   Resources within a space can now be shared with user groups. Spaces themselves can't be shared
   with groups, therefore those have been removed from the autocomplete results when adding
   members to a space.

   https://github.com/owncloud/web/issues/6283
   https://github.com/owncloud/web/pull/6639

* Enhancement - Spaces link sharing: [#6633](https://github.com/owncloud/web/pull/6633)

   Spaces and their resources can now be shared via links.

   https://github.com/owncloud/web/issues/6283
   https://github.com/owncloud/web/pull/6633

* Enhancement - Space name in breadcrumb: [#6662](https://github.com/owncloud/web/pull/6662)

   We have updated the breadcrumbs to show a space's name (if available).

   https://github.com/owncloud/web/issues/6637
   https://github.com/owncloud/web/pull/6662

* Enhancement - Spaces overview topbar layout: [#6642](https://github.com/owncloud/web/pull/6642)

   We've adjusted the topbar layout of the spaces overview to match the other pages.

   https://github.com/owncloud/web/issues/6641
   https://github.com/owncloud/web/pull/6642

* Enhancement - Update ODS to v13.1.0-rc.1: [#6708](https://github.com/owncloud/web/pull/6708)

   We updated the ownCloud Design System to version 13.1.0-rc.1. Please refer to the full
   changelog in the ODS release (linked) for more details. Summary:

   - Enhancement - Export package members:
   https://github.com/owncloud/owncloud-design-system/pull/2048 - Enhancement - Make
   OcResource inline-flex:
   https://github.com/owncloud/owncloud-design-system/pull/2041 - Bugfix - Disabled
   textarea color contrast in darkmode:
   https://github.com/owncloud/owncloud-design-system/pull/2055 - Bugfix - OcTextInput:
   Fix event handlers in loops:
   https://github.com/owncloud/owncloud-design-system/pull/2054

   https://github.com/owncloud/web/pull/6708
   https://github.com/owncloud/owncloud-design-system/releases/tag/v13.1.0-rc.1

Changelog for ownCloud Web [5.3.0] (2022-03-23)
=======================================
The following sections list the changes in ownCloud web 5.3.0 relevant to
ownCloud admins and users.

[5.3.0]: https://github.com/owncloud/web/compare/v5.2.0...v5.3.0

Summary
-------

* Bugfix - Thumbnails only for accepted shares: [#5310](https://github.com/owncloud/web/issues/5310)
* Bugfix - File handling in apps: [#6456](https://github.com/owncloud/web/pull/6456)
* Bugfix - Pressing enter in forms: [#6548](https://github.com/owncloud/web/pull/6548)
* Bugfix - Remove iFrame border: [#6555](https://github.com/owncloud/web/issues/6555)
* Bugfix - Show no auth popup on password protected public links in ownCloud 10: [#6530](https://github.com/owncloud/web/pull/6530)
* Bugfix - Sidebar panels in public links: [#2090](https://github.com/owncloud/web/issues/2090)
* Bugfix - Don't write error message on passing ReadmeContentModal.spec.js test: [#6525](https://github.com/owncloud/web/pull/6525)
* Bugfix - Rename parent folder: [#6516](https://github.com/owncloud/web/issues/6516)
* Bugfix - Resize observer errors within subfolders of a space: [#6569](https://github.com/owncloud/web/pull/6569)
* Bugfix - Resolve private links: [#5654](https://github.com/owncloud/web/pull/5654)
* Bugfix - Natural sort order: [#6532](https://github.com/owncloud/web/issues/6532)
* Bugfix - Prevent cross-site scripting attack while displaying space description: [#6523](https://github.com/owncloud/web/pull/6523)
* Bugfix - Prevent the member count inside a space from disappearing: [#6550](https://github.com/owncloud/web/pull/6550)
* Bugfix - TypeErrors when trying to destruct undefined properties: [#6568](https://github.com/owncloud/web/pull/6568)
* Enhancement - Don't block account page while groups are loading: [#6547](https://github.com/owncloud/web/pull/6547)
* Enhancement - Add a watcher for the share panel of a space: [#6543](https://github.com/owncloud/web/pull/6543)
* Enhancement - App context route to query instead of params: [#6622](https://github.com/owncloud/web/pull/6622)
* Enhancement - Contextmenu background hover: [#6553](https://github.com/owncloud/web/pull/6553)
* Enhancement - Design improvements: [#6492](https://github.com/owncloud/web/issues/6492)
* Enhancement - Improve resource loading within spaces: [#6601](https://github.com/owncloud/web/pull/6601)
* Enhancement - Internet Explorer deprecation warning banner: [#6629](https://github.com/owncloud/web/pull/6629)
* Enhancement - Load space images as preview: [#6529](https://github.com/owncloud/web/pull/6529)
* Enhancement - Move ListLoader component: [#6644](https://github.com/owncloud/web/pull/6644)
* Enhancement - Move NoContentMessage component: [#6643](https://github.com/owncloud/web/pull/6643)
* Enhancement - Move share indicators: [#5976](https://github.com/owncloud/web/issues/5976)
* Enhancement - Polish ViewOptions: [#6492](https://github.com/owncloud/web/issues/6492)
* Enhancement - Resolve private links into folders instead of parent: [#5533](https://github.com/owncloud/web/issues/5533)
* Enhancement - Share inheritance indicators: [#6613](https://github.com/owncloud/web/pull/6613)
* Enhancement - Shares overview: [#6440](https://github.com/owncloud/web/issues/6440)
* Enhancement - Side bar nav tags: [#6540](https://github.com/owncloud/web/pull/6540)
* Enhancement - Show space members in share panel for files inside a space: [#6554](https://github.com/owncloud/web/pull/6554)
* Enhancement - Allow updating space quota: [#6477](https://github.com/owncloud/web/pull/6477)
* Enhancement - Update the stored space after its members have been changed: [#6545](https://github.com/owncloud/web/pull/6545)
* Enhancement - Implement edit quota action in spaces overview: [#6598](https://github.com/owncloud/web/pull/6598)
* Enhancement - Implement people sharing for spaces: [#6455](https://github.com/owncloud/web/pull/6455)
* Enhancement - Implement the spaces permission concept: [#6531](https://github.com/owncloud/web/pull/6531)
* Enhancement - Implement people sharing for resources within a space: [#6577](https://github.com/owncloud/web/pull/6577)
* Enhancement - Trash bin: [#6566](https://github.com/owncloud/web/pull/6566)
* Enhancement - Trash bin breadcrumbs: [#6609](https://github.com/owncloud/web/pull/6609)
* Enhancement - Update the graph SDK: [#6519](https://github.com/owncloud/web/pull/6519)
* Enhancement - Update ODS to v13.0.0: [#6540](https://github.com/owncloud/web/pull/6540)

Details
-------

* Bugfix - Thumbnails only for accepted shares: [#5310](https://github.com/owncloud/web/issues/5310)

   Only accepted shares now display a thumbnail in the "Shared with me" resource table.

   https://github.com/owncloud/web/issues/5310
   https://github.com/owncloud/web/pull/6534

* Bugfix - File handling in apps: [#6456](https://github.com/owncloud/web/pull/6456)

   We fixed loading and saving files in apps in all contexts. It's now possible to open files in apps
   in personal files, favorites, share views and spaces.

   https://github.com/owncloud/web/pull/6456

* Bugfix - Pressing enter in forms: [#6548](https://github.com/owncloud/web/pull/6548)

   We fixed behavior when pressing enter in forms. For instance when adding or editing public
   links pressing enter in the name or password input fields, instead of saving the link it opened
   the datepicker.

   https://github.com/owncloud/web/pull/6548
   https://github.com/owncloud/owncloud-design-system/pull/2009

* Bugfix - Remove iFrame border: [#6555](https://github.com/owncloud/web/issues/6555)

   We fixed a UI issue which showed small borders around iFrames, e.g. in the external app.

   https://github.com/owncloud/web/issues/6555
   https://github.com/owncloud/web/pull/6573

* Bugfix - Show no auth popup on password protected public links in ownCloud 10: [#6530](https://github.com/owncloud/web/pull/6530)

   We fixed a native browser auth popup erroneously being shown for password protected public
   links with ownCloud 10.

   https://github.com/owncloud/web/issues/5727
   https://github.com/owncloud/web/pull/6530
   https://github.com/owncloud/owncloud-sdk/pull/1020

* Bugfix - Sidebar panels in public links: [#2090](https://github.com/owncloud/web/issues/2090)

   Public links were showing some panels (People, Links, Versions) that were not supposed to be
   visible in public links. We've fixed that by excluding those panels on public link routes.

   https://github.com/owncloud/web/issues/2090
   https://github.com/owncloud/web/pull/6567

* Bugfix - Don't write error message on passing ReadmeContentModal.spec.js test: [#6525](https://github.com/owncloud/web/pull/6525)

   ReadmeContentModal.spec.js test doesn't write error output anymore while passing

   https://github.com/owncloud/web/issues/6337
   https://github.com/owncloud/web/pull/6525

* Bugfix - Rename parent folder: [#6516](https://github.com/owncloud/web/issues/6516)

   We fixed the rename option in the parent folder / breadcrumb context menu. It was broken due to
   malformed webdav paths.

   https://github.com/owncloud/web/issues/6516
   https://github.com/owncloud/web/pull/6631

* Bugfix - Resize observer errors within subfolders of a space: [#6569](https://github.com/owncloud/web/pull/6569)

   We've fixed a bug where the resize observer crashes within subfolders of a space because there
   is no element to observe.

   https://github.com/owncloud/web/pull/6569

* Bugfix - Resolve private links: [#5654](https://github.com/owncloud/web/pull/5654)

   Private links didn't resolve correctly anymore because the internal file path handling was
   changed in our api client (owncloud-sdk). We've adjusted it accordingly so that private links
   now resolve correctly again.

   https://github.com/owncloud/web/pull/5654

* Bugfix - Natural sort order: [#6532](https://github.com/owncloud/web/issues/6532)

   We've fixed the sort order to respect natural sorting again. Also used the chance to make use of
   `Intl.Collator` instead of `localeCompare` which is considered to be a performance
   improvement.

   https://github.com/owncloud/web/issues/6532
   https://github.com/owncloud/web/pull/6632

* Bugfix - Prevent cross-site scripting attack while displaying space description: [#6523](https://github.com/owncloud/web/pull/6523)

   We've added a new package that strips out possible XSS attack code while displaying the space
   description

   https://github.com/owncloud/web/issues/6526
   https://github.com/owncloud/web/pull/6523

* Bugfix - Prevent the member count inside a space from disappearing: [#6550](https://github.com/owncloud/web/pull/6550)

   We've fixed a bug where opening the sidebar for a file inside a space caused the member count of
   the space to disappear.

   https://github.com/owncloud/web/pull/6550

* Bugfix - TypeErrors when trying to destruct undefined properties: [#6568](https://github.com/owncloud/web/pull/6568)

   We fixed TypeErrors when trying to destruct undefined properties in the space permissions
   checks by providing a default value.

   https://github.com/owncloud/web/pull/6568

* Enhancement - Don't block account page while groups are loading: [#6547](https://github.com/owncloud/web/pull/6547)

   We don't show a loading state for the full account information page anymore while the group
   membership information is loading. Instead we only show a loading spinner for the group
   membership information, while the rest of the user information is available immediately.

   https://github.com/owncloud/web/pull/6547

* Enhancement - Add a watcher for the share panel of a space: [#6543](https://github.com/owncloud/web/pull/6543)

   We've added a watcher for the share panel of a space to ensure seamless navigation via the share
   indicator.

   https://github.com/owncloud/web/pull/6543

* Enhancement - App context route to query instead of params: [#6622](https://github.com/owncloud/web/pull/6622)

   We've moved app context information (where you get redirected when you close an app) into the
   query instead of a regular param. This relocates this information further to the back of the url
   where it's less confusing for users.

   https://github.com/owncloud/web/pull/6622

* Enhancement - Contextmenu background hover: [#6553](https://github.com/owncloud/web/pull/6553)

   We've added a background hover color for contextmenu actions.

   https://github.com/owncloud/web/issues/6560
   https://github.com/owncloud/web/pull/6553
   https://github.com/owncloud/web/pull/6559

* Enhancement - Design improvements: [#6492](https://github.com/owncloud/web/issues/6492)

   We've fixed various design glitches and improved the overall look-and-feel of the UI.

   https://github.com/owncloud/web/issues/6492
   https://github.com/owncloud/web/issues/6555
   https://github.com/owncloud/web/pulls/6584

* Enhancement - Improve resource loading within spaces: [#6601](https://github.com/owncloud/web/pull/6601)

   We've improved the loading of resources within a space. This enhances performance and overall
   stability within spaces.

   * The loading task will determine if a space needs to be fetched or not. Route changes within a
   space do not require the space the be fetched again. This also ensures that the space image and
   readme won't be fetched when navigating into subfolders. * The space now gets set at the end of
   the loading task. This ensures that the space task has finished as soon as the image and readme
   get loaded.

   https://github.com/owncloud/web/pull/6601

* Enhancement - Internet Explorer deprecation warning banner: [#6629](https://github.com/owncloud/web/pull/6629)

   We've removed some internal checks for the internet explorer browser since it's not
   officially supported anymore in favor of a warning banner that informs the user that the web app
   may not work properly if they use it with IE.

   https://github.com/owncloud/web/pull/6629

* Enhancement - Load space images as preview: [#6529](https://github.com/owncloud/web/pull/6529)

   We've added a new logic which renders space images as preview to minimize data traffic

   https://github.com/owncloud/web/pull/6529
   https://github.com/owncloud/web/pull/6558

* Enhancement - Move ListLoader component: [#6644](https://github.com/owncloud/web/pull/6644)

   We've moved the ListLoader component into the web-pkg package and give it a more general name,
   to ease the use in other packages.

   https://github.com/owncloud/web/pull/6644

* Enhancement - Move NoContentMessage component: [#6643](https://github.com/owncloud/web/pull/6643)

   We've moved the NoContentMessage component into the web-pkg package to ease the use in other
   packages

   https://github.com/owncloud/web/pull/6643

* Enhancement - Move share indicators: [#5976](https://github.com/owncloud/web/issues/5976)

   We've moved the share/status indicators into a separate column and adjusted the design in ODS.

   https://github.com/owncloud/web/issues/5976
   https://github.com/owncloud/web/pull/6552
   https://github.com/owncloud/owncloud-design-system/pull/2014
   https://github.com/owncloud/web/pull/6583

* Enhancement - Polish ViewOptions: [#6492](https://github.com/owncloud/web/issues/6492)

   We've added an hover effect for ViewOptions buttons

   https://github.com/owncloud/web/issues/6492
   https://github.com/owncloud/web/pull/6591

* Enhancement - Resolve private links into folders instead of parent: [#5533](https://github.com/owncloud/web/issues/5533)

   Private links always resolved into the parent folder of the linked file and visually
   highlighted the file or folder from the link. We've changed this behaviour to directly
   navigate into the folder in case the linked resource is a folder and only keep the previous
   behaviour for when the linked resource is a file.

   https://github.com/owncloud/web/issues/5533
   https://github.com/owncloud/web/pull/5654

* Enhancement - Share inheritance indicators: [#6613](https://github.com/owncloud/web/pull/6613)

   We've implemented the share inheritance indicators in the share sidebar panel. They indicate
   whether a resource is shared indirectly via one of its parent folders.

   https://github.com/owncloud/web/issues/6528
   https://github.com/owncloud/web/pull/6613

* Enhancement - Shares overview: [#6440](https://github.com/owncloud/web/issues/6440)

   We've merged the three shares navigation items into one central "Shares" item, with a toggle to
   switch between the three different kinds of shares (incoming, outgoing, links). In the
   process, we have also renamed the "All files" page to the "Personal" page, indicating that this
   is the user's personal space since shares (and potentially other shared spaces) live
   elsewhere.

   https://github.com/owncloud/web/issues/6440
   https://github.com/owncloud/web/issues/6570
   https://github.com/owncloud/web/pull/6512
   https://github.com/owncloud/web/pull/6573

* Enhancement - Side bar nav tags: [#6540](https://github.com/owncloud/web/pull/6540)

   We have implemented a way to show a tag next to the sidebar navigation item link text

   https://github.com/owncloud/web/issues/6259
   https://github.com/owncloud/web/pull/6540

* Enhancement - Show space members in share panel for files inside a space: [#6554](https://github.com/owncloud/web/pull/6554)

   The space managers are now displayed in the sidebar for resources within a space. Also, space
   members are now sorted via role (managers first) and name.

   https://github.com/owncloud/web/issues/6283
   https://github.com/owncloud/web/pull/6554

* Enhancement - Allow updating space quota: [#6477](https://github.com/owncloud/web/pull/6477)

   We have implemented a way to update the quota of a space

   https://github.com/owncloud/web/issues/6470
   https://github.com/owncloud/web/pull/6477

* Enhancement - Update the stored space after its members have been changed: [#6545](https://github.com/owncloud/web/pull/6545)

   We now update the stored space after its members have been changed. Also, the
   permission-object of a built space has been simplified in the course of this.

   https://github.com/owncloud/web/pull/6545

* Enhancement - Implement edit quota action in spaces overview: [#6598](https://github.com/owncloud/web/pull/6598)

   We've added the edit quota action to the space context menu in the spaces overview.

   https://github.com/owncloud/web/pull/6598

* Enhancement - Implement people sharing for spaces: [#6455](https://github.com/owncloud/web/pull/6455)

   Spaces can now be shared with other people. This change specifically includes:

   * listing all members who have access to a space (possible for all space members) * adding
   members to a space and giving them dedicated roles (possible for managers only) * editing the
   role of members (possible for managers only) * removing members from a space (possible for
   managers only)

   https://github.com/owncloud/web/issues/6283
   https://github.com/owncloud/web/pull/6455
   https://github.com/owncloud/web/pull/6572

* Enhancement - Implement the spaces permission concept: [#6531](https://github.com/owncloud/web/pull/6531)

   We've implemented the spaces permission concept and improved the code structure for further
   permission changes.

   https://github.com/owncloud/web/pull/6531

* Enhancement - Implement people sharing for resources within a space: [#6577](https://github.com/owncloud/web/pull/6577)

   Resources within a space can now be shared with other people.

   https://github.com/owncloud/web/issues/6283
   https://github.com/owncloud/web/pull/6577

* Enhancement - Trash bin: [#6566](https://github.com/owncloud/web/pull/6566)

   We've improved the trash bin in general: * Add compatibility with owncloud-sdk 3.0.0-alpha 1 *
   Add a confirmation dialog while hitting the `Empty trash bin` button * Add trash bin for project
   spaces * Change personal trash bin route from `files/trash` to `files/trash/personal`

   https://github.com/owncloud/web/issues/6544
   https://github.com/owncloud/web/issues/5974
   https://github.com/owncloud/web/pull/6566

* Enhancement - Trash bin breadcrumbs: [#6609](https://github.com/owncloud/web/pull/6609)

   We've improved the trash bin in general: * Add a breadcrumb for personal trash bin * Improve the
   breadcrumb for spaces trash bin, also add 'Navigate to space' action to context menu * Fix wrong
   page title in spaces trash bin

   https://github.com/owncloud/web/pull/6609

* Enhancement - Update the graph SDK: [#6519](https://github.com/owncloud/web/pull/6519)

   We've updated the graph SDK to include the "me"-endpoint.

   https://github.com/owncloud/web/pull/6519

* Enhancement - Update ODS to v13.0.0: [#6540](https://github.com/owncloud/web/pull/6540)

   We updated the ownCloud Design System to version 13.0.0. Please refer to the full changelog in
   the ODS release (linked) for more details. Summary:

   - Change - Default type of OcButton:
   https://github.com/owncloud/owncloud-design-system/pull/2009 - Change - Remove
   OcStatusIndicators from OcResource:
   https://github.com/owncloud/owncloud-design-system/pull/2014 - Enhancement -
   Redesign OcStatusIndicators:
   https://github.com/owncloud/owncloud-design-system/pull/2014 - Enhancement - Icons
   for drawio, ifc and odg resource types:
   https://github.com/owncloud/owncloud-design-system/pull/2005 - Enhancement - Apply
   size property to oc-tag:
   https://github.com/owncloud/owncloud-design-system/pull/2011 - Enhancement -
   Underline OcResourceName:
   https://github.com/owncloud/owncloud-design-system/pull/2019 - Enhancement -
   Configurable OcResource parentfolder name:
   https://github.com/owncloud/owncloud-design-system/pull/2029 - Enhancement - Polish
   OcSwitch: https://github.com/owncloud/owncloud-design-system/pull/2018 -
   Enhancement - Make filled primary OcButton use gradient background:
   https://github.com/owncloud/owncloud-design-system/pull/2036 - Bugfix - Disabled
   OcSelect background: https://github.com/owncloud/owncloud-design-system/pull/2008 -
   Bugfix - Icons/Thumbnails were only visible for clickable resources:
   https://github.com/owncloud/owncloud-design-system/pull/2007 - Bugfix - OcSelect
   transparent background:
   https://github.com/owncloud/owncloud-design-system/pull/2036

   https://github.com/owncloud/web/pull/6540
   https://github.com/owncloud/web/pull/6600
   https://github.com/owncloud/web/pull/6584
   https://github.com/owncloud/web/pull/6561
   https://github.com/owncloud/owncloud-design-system/releases/tag/v13.0.0

Changelog for ownCloud Web [5.2.0] (2022-03-03)
=======================================
The following sections list the changes in ownCloud web 5.2.0 relevant to
ownCloud admins and users.

[5.2.0]: https://github.com/owncloud/web/compare/v5.1.0...v5.2.0

Summary
-------

* Bugfix - Breadcrumb 'All Files' link: [#6467](https://github.com/owncloud/web/pull/6467)
* Bugfix - Load capabilities for password protected public links: [#6471](https://github.com/owncloud/web/pull/6471)
* Bugfix - No selection info right sidebar: [#6502](https://github.com/owncloud/web/issues/6502)
* Bugfix - Update file list when creating new files: [#5530](https://github.com/owncloud/web/issues/5530)
* Enhancement - Add quick rename button: [#6645](https://github.com/owncloud/web/pull/6645)
* Enhancement - Display search results within files app: [#6496](https://github.com/owncloud/web/issues/6496)
* Enhancement - Option to enable Vue history mode: [#6363](https://github.com/owncloud/web/issues/6363)
* Enhancement - Redesign OcBreadcrumb: [#6218](https://github.com/owncloud/web/issues/6218)
* Enhancement - Redesign create and upload buttons: [#6279](https://github.com/owncloud/web/issues/6279)
* Enhancement - Redesign FilesTable: [#6207](https://github.com/owncloud/web/issues/6207)
* Enhancement - Run web as oc10 sidecar: [#6363](https://github.com/owncloud/web/issues/6363)
* Enhancement - Allow updating space image and description: [#6410](https://github.com/owncloud/web/pull/6410)
* Enhancement - Outsource space readme content modal: [#6509](https://github.com/owncloud/web/pull/6509)
* Enhancement - Implement the right sidebar for spaces: [#6437](https://github.com/owncloud/web/pull/6437)
* Enhancement - Update ODS to v12.2.1: [#6450](https://github.com/owncloud/web/pull/6450)

Details
-------

* Bugfix - Breadcrumb 'All Files' link: [#6467](https://github.com/owncloud/web/pull/6467)

   The `All Files` link in the breadcrumb now always point to the root of the personal storage home
   instead of the optional homeFolder.

   https://github.com/owncloud/web/issues/6327
   https://github.com/owncloud/web/pull/6467

* Bugfix - Load capabilities for password protected public links: [#6471](https://github.com/owncloud/web/pull/6471)

   We've enabled capability loading for password protected public links.

   https://github.com/owncloud/web/issues/5863
   https://github.com/owncloud/web/pull/6471

* Bugfix - No selection info right sidebar: [#6502](https://github.com/owncloud/web/issues/6502)

   We fixed that the right sidebar was not showing the "no selection" info panel anymore in the root
   of "All files". In addition we also use the same "no selection" info panel now in the root nodes of
   public links.

   https://github.com/owncloud/web/issues/6502
   https://github.com/owncloud/web/issues/6182
   https://github.com/owncloud/web/pull/6505

* Bugfix - Update file list when creating new files: [#5530](https://github.com/owncloud/web/issues/5530)

   We update the file list now when creating a file in an editor that openes in a new tab (like
   draw.io).

   https://github.com/owncloud/web/issues/5530
   https://github.com/owncloud/web/pull/6358

* Enhancement - Add quick rename button: [#6645](https://github.com/owncloud/web/pull/6645)

   We've added a button for quick editing a resource name

   https://github.com/owncloud/web/issues/6626
   https://github.com/owncloud/web/pull/6645

* Enhancement - Display search results within files app: [#6496](https://github.com/owncloud/web/issues/6496)

   We've updated the "Search in all files" view to be displayed within the files app instead of
   showing them in a dedicated extension. This way, users don't loose their context and can still
   use sidebar.

   https://github.com/owncloud/web/issues/6496
   https://github.com/owncloud/web/issues/6507
   https://github.com/owncloud/web/pulls/6511

* Enhancement - Option to enable Vue history mode: [#6363](https://github.com/owncloud/web/issues/6363)

   We've added the option to use vue's history mode. All configuration is done automatically by
   the system. To enable it, add a `<base href="PATH">` header tag to `index.html`,
   `oidc-callback.html` and `oidc-silent-redirect.html`. Adding `<base>` is not needed for
   ocis.

   https://github.com/owncloud/web/issues/6363
   https://github.com/owncloud/web/issues/6277

* Enhancement - Redesign OcBreadcrumb: [#6218](https://github.com/owncloud/web/issues/6218)

   We've adjustet the look of the OcBreadcrumb to fit the Redesign

   https://github.com/owncloud/web/issues/6218
   https://github.com/owncloud/web/pull/6472

* Enhancement - Redesign create and upload buttons: [#6279](https://github.com/owncloud/web/issues/6279)

   We have separated the "Create new file/folder" and "Upload" actions above the files list into
   two separate buttons, also using the new resource type icons for more consistency.

   https://github.com/owncloud/web/issues/6279
   https://github.com/owncloud/web/pull/6358
   https://github.com/owncloud/web/pull/6500

* Enhancement - Redesign FilesTable: [#6207](https://github.com/owncloud/web/issues/6207)

   We've redesigned the QuickActions visually and updated theming to fit the redesign

   https://github.com/owncloud/web/issues/6207
   https://github.com/owncloud/web/pull/6450

* Enhancement - Run web as oc10 sidecar: [#6363](https://github.com/owncloud/web/issues/6363)

   We've added the option to run web in oc10 sidecar mode. Copy
   `config/config.json.sample-oc10` to `config/config.json`, run `yarn server` and then
   `docker compose up oc10`.

   https://github.com/owncloud/web/issues/6363

* Enhancement - Allow updating space image and description: [#6410](https://github.com/owncloud/web/pull/6410)

   We have implemented multiple ways to update the image and description of a space.

   https://github.com/owncloud/web/issues/6377
   https://github.com/owncloud/web/pull/6410

* Enhancement - Outsource space readme content modal: [#6509](https://github.com/owncloud/web/pull/6509)

   We've added a new component for space readme content modal and extracted duplicated code.

   https://github.com/owncloud/web/pull/6509

* Enhancement - Implement the right sidebar for spaces: [#6437](https://github.com/owncloud/web/pull/6437)

   The right sidebar for a space functions similar to the files sidebar and gives the user basic
   information and actions for the current space.

   https://github.com/owncloud/web/issues/6284
   https://github.com/owncloud/web/pull/6437

* Enhancement - Update ODS to v12.2.1: [#6450](https://github.com/owncloud/web/pull/6450)

   We updated the ownCloud Design System to version 12.2.1. Please refer to the full changelog in
   the ODS release (linked) for more details. Summary:

   - Enhancement - Apply outstanding background color to oc-card:
   https://github.com/owncloud/owncloud-design-system/pull/1974 - Enhancement -
   Redesign OcBreadcrumb: https://github.com/owncloud/web/issues/6218 - Enhancement -
   Redesign files table related components:
   https://github.com/owncloud/owncloud-design-system/pull/1958

   https://github.com/owncloud/web/pull/6450
   https://github.com/owncloud/web/pull/6472
   https://github.com/owncloud/web/pull/6505
   https://github.com/owncloud/owncloud-design-system/releases/tag/v12.2.1

Changelog for ownCloud Web [5.1.0] (2022-02-18)
=======================================
The following sections list the changes in ownCloud web 5.1.0 relevant to
ownCloud admins and users.

[5.1.0]: https://github.com/owncloud/web/compare/v5.0.0...v5.1.0

Summary
-------

* Bugfix - App compatibility: [#6439](https://github.com/owncloud/web/pull/6439)
* Bugfix - Fix closing apps opened from search: [#6444](https://github.com/owncloud/web/pull/6444)
* Enhancement - Add the graph client to the client service: [#6425](https://github.com/owncloud/web/pull/6425)
* Enhancement - Enable context menu for search results: [#6445](https://github.com/owncloud/web/pull/6445)
* Enhancement - Use the Vue store for spaces: [#6427](https://github.com/owncloud/web/pull/6427)

Details
-------

* Bugfix - App compatibility: [#6439](https://github.com/owncloud/web/pull/6439)

   We've made sure that apps that were not made compatible with ownCloud Web 5.0.0 don't run into a
   non-rendered state.

   https://github.com/owncloud/web/pull/6439

* Bugfix - Fix closing apps opened from search: [#6444](https://github.com/owncloud/web/pull/6444)

   We've made sure that closing apps that were opened from search navigates properly back to the
   original search.

   https://github.com/owncloud/web/pull/6444

* Enhancement - Add the graph client to the client service: [#6425](https://github.com/owncloud/web/pull/6425)

   This way, the client for the graph API can easily be fetched when needed.

   https://github.com/owncloud/web/pull/6425

* Enhancement - Enable context menu for search results: [#6445](https://github.com/owncloud/web/pull/6445)

   We've enabled a rudimentary context menu for search results.

   https://github.com/owncloud/web/pull/6445

* Enhancement - Use the Vue store for spaces: [#6427](https://github.com/owncloud/web/pull/6427)

   Using the store for spaces integrates them seamlessly in our ecosystem and makes it easier to
   develop spaces even further. E.g. the properties of a space can now be altered without fetching
   all spaces again. This was achieved by introducing a "buildSpace" method, that transforms a
   space into a more generic resource object (just like regular files or shares).

   https://github.com/owncloud/web/pull/6427

Changelog for ownCloud Web [5.0.0] (2022-02-14)
=======================================
The following sections list the changes in ownCloud web 5.0.0 relevant to
ownCloud admins and users.

[5.0.0]: https://github.com/owncloud/web/compare/v4.9.0...v5.0.0

Summary
-------

* Bugfix - Application config not available to application: [#6296](https://github.com/owncloud/web/issues/6296)
* Bugfix - Failed move by drag'n'drop doesn't show the resource name in the error: [#6412](https://github.com/owncloud/web/issues/6412)
* Bugfix - Add and remove to/from favorites: [#6328](https://github.com/owncloud/web/issues/6328)
* Bugfix - Jumpy batch actions: [#6360](https://github.com/owncloud/web/pull/6360)
* Bugfix - Open folder from context menu: [#6187](https://github.com/owncloud/web/issues/6187)
* Bugfix - Breadcrumbs in different views: [#6326](https://github.com/owncloud/web/issues/6326)
* Bugfix - Scrolling inside Markdown Editor: [#4606](https://github.com/owncloud/web/issues/4606)
* Bugfix - Focus management in topbar dropdowns: [#6213](https://github.com/owncloud/web/pull/6213)
* Change - Dropped editor route whitelist: [#6381](https://github.com/owncloud/web/pull/6381)
* Change - Enforce extensions to always display the ui-header: [#6401](https://github.com/owncloud/web/pull/6401)
* Change - Remove UiKit: [#6103](https://github.com/owncloud/web/issues/6103)
* Change - Rename theme logo sidebar to topbar: [#6349](https://github.com/owncloud/web/pull/6349)
* Change - Use remixicons for redesign: [#6142](https://github.com/owncloud/web/pull/6142)
* Change - Drop support for Internet Explorer and other dead browsers: [#6386](https://github.com/owncloud/web/pull/6386)
* Enhancement - Add spaces actions: [#6254](https://github.com/owncloud/web/pull/6254)
* Enhancement - File creation via app provider: [#5890](https://github.com/owncloud/web/pull/5890)
* Enhancement - Redirect to IDP when opening apps from bookmark: [#6045](https://github.com/owncloud/web/issues/6045)
* Enhancement - Context Route Params: [#6331](https://github.com/owncloud/web/pull/6331)
* Enhancement - Darkmode theme switcher: [#6242](https://github.com/owncloud/web/issues/6242)
* Enhancement - Drawio improvements: [#6125](https://github.com/owncloud/web/pull/6125)
* Enhancement - File selection simplification: [#5967](https://github.com/owncloud/web/issues/5967)
* Enhancement - Resource-specific icons in ResourceTable: [#6295](https://github.com/owncloud/web/pull/6295)
* Enhancement - Reorganize urls: [#6137](https://github.com/owncloud/web/pull/6137)
* Enhancement - Lazy resource table cells: [#6204](https://github.com/owncloud/web/pull/6204)
* Enhancement - Add URL handling to markdown editor: [#6134](https://github.com/owncloud/web/pull/6134)
* Enhancement - Persist chosen sorting options: [#5930](https://github.com/owncloud/web/issues/5930)
* Enhancement - Redesign appswitcher: [#6102](https://github.com/owncloud/web/issues/6102)
* Enhancement - Redesign main layout: [#6036](https://github.com/owncloud/web/issues/6036)
* Enhancement - Redesigned user menu: [#6272](https://github.com/owncloud/web/pull/6272)
* Enhancement - Show parent folder for resources: [#6226](https://github.com/owncloud/web/pull/6226)
* Enhancement - Add default sorting to the spaces list: [#6262](https://github.com/owncloud/web/pull/6262)
* Enhancement - Implement spaces front page: [#6287](https://github.com/owncloud/web/pull/6287)
* Enhancement - Implement spaces list: [#6199](https://github.com/owncloud/web/pull/6199)
* Enhancement - Update ODS to v12.1.0: [#6086](https://github.com/owncloud/web/pull/6086)
* Enhancement - Update SDK: [#6309](https://github.com/owncloud/web/pull/6309)

Details
-------

* Bugfix - Application config not available to application: [#6296](https://github.com/owncloud/web/issues/6296)

   We fixed a bug in providing config to external apps like draw-io.

   https://github.com/owncloud/web/issues/6296
   https://github.com/owncloud/web/pull/6298

* Bugfix - Failed move by drag'n'drop doesn't show the resource name in the error: [#6412](https://github.com/owncloud/web/issues/6412)

   We fixed the error message when moving an item via drag-and-drop failed, now it shows the
   correct name of the item.

   https://github.com/owncloud/web/issues/6412

* Bugfix - Add and remove to/from favorites: [#6328](https://github.com/owncloud/web/issues/6328)

   We've fixed bugs related to adding and removing files to/from favorites: - "favorite" star
   button in the right sidebar of the files app was not being updated when the favorite-state was
   modified through a click on the star icon - toggling the favorites state of the current folder
   was broken (via both context menu on current folder and right sidebar without a file selection)

   https://github.com/owncloud/web/issues/6328
   https://github.com/owncloud/web/pull/6330

* Bugfix - Jumpy batch actions: [#6360](https://github.com/owncloud/web/pull/6360)

   We fixed a bug that made the batch actions move up and down a few pixels every time they
   appeared/disappeared.

   https://github.com/owncloud/web/pull/6360

* Bugfix - Open folder from context menu: [#6187](https://github.com/owncloud/web/issues/6187)

   We fixed a bug in the context menu that prevented correct folder navigation ("Open folder").

   https://github.com/owncloud/web/issues/6187
   https://github.com/owncloud/web/pull/6232

* Bugfix - Breadcrumbs in different views: [#6326](https://github.com/owncloud/web/issues/6326)

   The files app had the breadcrumbs broken in the various views. We fixed that by actively
   watching the current route now for updates of some active route helpers.

   https://github.com/owncloud/web/issues/6326
   https://github.com/owncloud/web/pull/6370

* Bugfix - Scrolling inside Markdown Editor: [#4606](https://github.com/owncloud/web/issues/4606)

   Scrolling inside the Markdown Editor was broken, before the redesign by allowing the user to
   scroll the appBar out of the viewport, and after the redesign by cutting a potentially long
   preview off at the bottom. This has been addressed by allowing to scroll the preview content.

   https://github.com/owncloud/web/issues/4606
   https://github.com/owncloud/web/pull/6386

* Bugfix - Focus management in topbar dropdowns: [#6213](https://github.com/owncloud/web/pull/6213)

   We've fixed issues with focus management upon opening and closing the dropdown menus in the
   ApplicationSwitcher and Usermenu.

   https://github.com/owncloud/web/pull/6213

* Change - Dropped editor route whitelist: [#6381](https://github.com/owncloud/web/pull/6381)

   We've dropped the `routes` key from file extension handlers defined by editor apps. This was
   used as a whitelist for being rendered as available editor in the files app. The only usage of
   this was for disabling editors in the trashbin. We've moved that part of the business logic to
   the files app itself and from now on ignore the `routes` key from editors.

   https://github.com/owncloud/web/pull/6381

* Change - Enforce extensions to always display the ui-header: [#6401](https://github.com/owncloud/web/pull/6401)

   We've enforced the ui to always render the header for third party extensions. From now on
   extensions are not able to disable the header anymore.

   https://github.com/owncloud/web/pull/6401

* Change - Remove UiKit: [#6103](https://github.com/owncloud/web/issues/6103)

   The ownCloud design system has dropped the underlying UiKit library, which we've also removed
   from the web codebase to reduce the overall bundle size.

   https://github.com/owncloud/web/issues/6103
   https://github.com/owncloud/web/pull/6213

* Change - Rename theme logo sidebar to topbar: [#6349](https://github.com/owncloud/web/pull/6349)

   With the redesign, the theme-able logo has moved from the sidebar to the topbar. Accordingly,
   within a theme, the key for it has been renamed from `sidebar` to `topbar`.

   https://github.com/owncloud/web/pull/6349
   https://github.com/owncloud/web/pull/6386

* Change - Use remixicons for redesign: [#6142](https://github.com/owncloud/web/pull/6142)

   We've switched the iconset to remixicons to fit the new design.

   https://github.com/owncloud/web/issues/6100
   https://github.com/owncloud/web/pull/6142
   https://github.com/owncloud/web/pull/6270

* Change - Drop support for Internet Explorer and other dead browsers: [#6386](https://github.com/owncloud/web/pull/6386)

   Even though it was never officially supported, we were still checking for certain dead
   browsers. This has now been dropped.

   https://github.com/owncloud/web/pull/6386

* Enhancement - Add spaces actions: [#6254](https://github.com/owncloud/web/pull/6254)

   We added the following actions to the spaces overview:

   * Create a new space * Rename a space * Delete a space

   https://github.com/owncloud/web/issues/6255
   https://github.com/owncloud/web/pull/6254

* Enhancement - File creation via app provider: [#5890](https://github.com/owncloud/web/pull/5890)

   For oCIS deployments the integration of the app provider for editing files was enhanced by
   adding support for the app provider capabilities to create files as well.

   https://github.com/owncloud/web/pull/5890
   https://github.com/owncloud/web/pull/6312

* Enhancement - Redirect to IDP when opening apps from bookmark: [#6045](https://github.com/owncloud/web/issues/6045)

   We've expanded the check for authentication requirements to the referrer of the current URL.
   As a result an app that doesn't necessarily require authentication can still require
   authentication based on the file context it was opened in. This is especially important for
   situations where an app is opened for a file from a bookmark, so that we cannot rely on the user
   already having an authenticated session.

   https://github.com/owncloud/web/issues/6045
   https://github.com/owncloud/web/issues/6069
   https://github.com/owncloud/web/pull/6314

* Enhancement - Context Route Params: [#6331](https://github.com/owncloud/web/pull/6331)

   We now add params of the source context route to the query of app routes and convert them back to
   params when routing back to the origin - this is necessary to properly navigate back from
   opening files in extensions or in search results, throughout personal, public or, in the
   future, spaces views.

   https://github.com/owncloud/web/issues/6390
   https://github.com/owncloud/web/pull/6331

* Enhancement - Darkmode theme switcher: [#6242](https://github.com/owncloud/web/issues/6242)

   We've added a theme switcher and now initialize the user interface theme based on the user's
   browser preferences. It also gets saved to the localstorage of the browser so the user's
   preference gets saved locally.

   https://github.com/owncloud/web/issues/6242
   https://github.com/owncloud/web/pull/6240
   https://github.com/owncloud/web/pull/6350

* Enhancement - Drawio improvements: [#6125](https://github.com/owncloud/web/pull/6125)

   - Honor the autosave configuration, and actually save - Show error messages to the user,
   currently all failures are silent

   https://github.com/owncloud/web/pull/6125

* Enhancement - File selection simplification: [#5967](https://github.com/owncloud/web/issues/5967)

   When creating a file or folder the created item is neither selected nor scrolled to anymore.
   This enhances usability because the selection model doesn't get altered to a single item
   selection anymore and allows to create items and adding them to a preselected set of resources.
   It also fixes an accessibility violation as the selection model (and with it the current page in
   it's entirety) is not altered anymore without announcement.

   https://github.com/owncloud/web/issues/5967
   https://github.com/owncloud/web/pull/6208

* Enhancement - Resource-specific icons in ResourceTable: [#6295](https://github.com/owncloud/web/pull/6295)

   We've added FontAwesome icons for the different resource types, each getting their
   respective resource type color from the ODS definition.

   https://github.com/owncloud/web/pull/6295
   https://github.com/owncloud/web/pull/6387

* Enhancement - Reorganize urls: [#6137](https://github.com/owncloud/web/pull/6137)

   With the [global-url-format
   ADR](https://github.com/owncloud/ocis/blob/master/docs/ocis/adr/0011-global-url-format.md)
   we've decided how the internal and external URL schema should look like.

   To have a human understandable structure we've decided to also rethink how the overall
   structure should look like. This PR introduces the new schema and takes care that existing
   routes still work by redirecting them.

   https://github.com/owncloud/web/issues/6085
   https://github.com/owncloud/web/pull/6137
   https://github.com/owncloud/ocis/blob/master/docs/ocis/adr/0011-global-url-format.md

* Enhancement - Lazy resource table cells: [#6204](https://github.com/owncloud/web/pull/6204)

   ODS introduced lazy loadable table cells, this feature is now also part of web and enabled by
   default. To disable the feature set the displayResourcesLazy option to false.

   https://github.com/owncloud/web/pull/6204

* Enhancement - Add URL handling to markdown editor: [#6134](https://github.com/owncloud/web/pull/6134)

   We made the markdown editor URL aware. This enables the close button to return to the source
   folder of the file being edited and also enables opening the editor again on page reload.

   https://github.com/owncloud/web/issues/5928
   https://github.com/owncloud/web/pull/6134

* Enhancement - Persist chosen sorting options: [#5930](https://github.com/owncloud/web/issues/5930)

   We now persist the chosen sorting options per view into the local storage of the browser. This
   means, that when e.g. the `All files` page is sorted by last modification date and the `Share
   with others` page is sorted by share receivers, the web UI remembers those choices for example
   across browser tabs or during navigation in the folder tree.

   https://github.com/owncloud/web/issues/5930
   https://github.com/owncloud/web/pull/6290

* Enhancement - Redesign appswitcher: [#6102](https://github.com/owncloud/web/issues/6102)

   We've redesigned the appswitcher to follow the new design and highlight the currently used
   app.

   https://github.com/owncloud/web/issues/6102
   https://github.com/owncloud/web/pull/6349

* Enhancement - Redesign main layout: [#6036](https://github.com/owncloud/web/issues/6036)

   We've started to implement the redesign by adjusting the sidebar, topbar and appswitcher.
   While doing so, we also removed the `vue2-touch-events` dependency.

   https://github.com/owncloud/web/issues/6036
   https://github.com/owncloud/web/pull/6086
   https://github.com/owncloud/web/pull/6222
   https://github.com/owncloud/web/pull/6228
   https://github.com/owncloud/web/pull/6360
   https://github.com/owncloud/web/pull/6365
   https://github.com/owncloud/web/pull/6366
   https://github.com/owncloud/web/pull/6386

* Enhancement - Redesigned user menu: [#6272](https://github.com/owncloud/web/pull/6272)

   We've redesigned the user menu. It now also features more detailed information about the
   user's quota and how much space they have left.

   https://github.com/owncloud/web/issues/6101
   https://github.com/owncloud/web/pull/6272

* Enhancement - Show parent folder for resources: [#6226](https://github.com/owncloud/web/pull/6226)

   We've added a visual hint for the parent folder of a resource in cases where it could be usefull.

   https://github.com/owncloud/web/issues/5953
   https://github.com/owncloud/web/pull/6226

* Enhancement - Add default sorting to the spaces list: [#6262](https://github.com/owncloud/web/pull/6262)

   Spaces will now be sorted by their name by default.

   https://github.com/owncloud/web/issues/6253
   https://github.com/owncloud/web/pull/6262

* Enhancement - Implement spaces front page: [#6287](https://github.com/owncloud/web/pull/6287)

   Each space can now be entered from within the spaces list. The space front page will then display
   all the space contents, plus an image and a readme file if set. Basic actions like uploading
   files, creating folders, renaming resources, and more. were also implemented in the course of
   this.

   https://github.com/owncloud/web/issues/6271
   https://github.com/owncloud/web/pull/6287

* Enhancement - Implement spaces list: [#6199](https://github.com/owncloud/web/pull/6199)

   We added a new route that lists all available spaces of type "project".

   https://github.com/owncloud/web/issues/6104
   https://github.com/owncloud/web/pull/6199
   https://github.com/owncloud/web/pull/6399

* Enhancement - Update ODS to v12.1.0: [#6086](https://github.com/owncloud/web/pull/6086)

   We updated the ownCloud Design System to version 12.1.0. Please refer to the full changelog in
   the ODS release (linked) for more details. Summary:

   - Change - Drop Internet Explorer support:
   https://github.com/owncloud/owncloud-design-system/pull/1909 - Change - Do not sort in
   OcTable: https://github.com/owncloud/owncloud-design-system/pull/1825 - Change - Pass
   folderLink to OcResource component:
   https://github.com/owncloud/owncloud-design-system/pull/1913 - Change - Remove
   OcAppSideBar component:
   https://github.com/owncloud/owncloud-design-system/pull/1810 - Change - Remove
   OcAppBar component: https://github.com/owncloud/owncloud-design-system/pull/1810 -
   Change - Remove implicit ODS registration:
   https://github.com/owncloud/owncloud-design-system/pull/1848 - Change - Remove
   oc-table-files from ods:
   https://github.com/owncloud/owncloud-design-system/pull/1817 - Change - Remove OcGrid
   options: https://github.com/owncloud/owncloud-design-system/pull/1658 - Change - Move
   OcSidebarNav and OcSidebarNavItem to web: https://github.com/owncloud/web/issues/6036
   - Change - Remove UiKit: https://github.com/owncloud/owncloud-design-system/pull/1658
   - Change - Remove unused props for unstyled components:
   https://github.com/owncloud/owncloud-design-system/pull/1795 - Change - Use
   remixicons for redesign:
   https://github.com/owncloud/owncloud-design-system/pull/1826 - Enhancement - Make
   Vue-Composition-API available:
   https://github.com/owncloud/owncloud-design-system/pull/1848 - Enhancement - Export
   mappings of types, icons and colors of resources:
   https://github.com/owncloud/owncloud-design-system/pull/1920 - Enhancement - Fix
   OcAvatar line-height: https://github.com/owncloud/owncloud-design-system/pull/1810
   - Enhancement - Add option to render table cells lazy:
   https://github.com/owncloud/owncloud-design-system/pull/1848 - Enhancement - Make
   OcDrop rounded: https://github.com/owncloud/owncloud-design-system/pull/1881 -
   Enhancement - Change background color of OcDrop:
   https://github.com/owncloud/owncloud-design-system/pull/1919 - Enhancement - Improve
   OcList: https://github.com/owncloud/owncloud-design-system/pull/1881 - Enhancement -
   Show path / parent folder to distinguish files:
   https://github.com/owncloud/web/issues/5953 - Enhancement - Redesign Filetype icons:
   https://github.com/owncloud/web/issues/6278 - Enhancement - Adjust OcSearchBar to new
   design: https://github.com/owncloud/owncloud-design-system/pull/1810/ - Enhancement
   - Sizes: https://github.com/owncloud/owncloud-design-system/pull/1858 - Enhancement -
   Add svg icon for spaces: https://github.com/owncloud/owncloud-design-system/pull/1846
   - Enhancement - OcTable header alignment:
   https://github.com/owncloud/owncloud-design-system/pull/1922 - Enhancement - Use
   Roboto font: https://github.com/owncloud/owncloud-design-system/pull/1876 -
   Enhancement - Redesign OcModal:
   https://github.com/owncloud/owncloud-design-system/pull/1953 - Bugfix - Missing
   OcDrop shadow: https://github.com/owncloud/owncloud-design-system/pull/1926 - Bugfix
   - OcNotification positioning:
   https://github.com/owncloud/owncloud-design-system/pull/1658 - Bugfix - Rename
   GhostElement: https://github.com/owncloud/owncloud-design-system/pull/1845 - Bugfix
   - OcTooltip isn't reactive:
   https://github.com/owncloud/owncloud-design-system/pull/1863 - Bugfix -
   Background-primary-gradient border: https://github.com/owncloud/web/issues/6383

   https://github.com/owncloud/web/pull/6086
   https://github.com/owncloud/web/pull/6142
   https://github.com/owncloud/web/pull/6213
   https://github.com/owncloud/web/pull/6228
   https://github.com/owncloud/web/pull/6240
   https://github.com/owncloud/web/pull/6295
   https://github.com/owncloud/web/pull/6360
   https://github.com/owncloud/web/pull/6368
   https://github.com/owncloud/web/pull/6418
   https://github.com/owncloud/owncloud-design-system/releases/tag/v12.0.0
   https://github.com/owncloud/owncloud-design-system/releases/tag/v12.1.0

* Enhancement - Update SDK: [#6309](https://github.com/owncloud/web/pull/6309)

   We've updated the ownCloud SDK to version 2.0.0.

   - Change - Drop Internet Explorer support:
   https://github.com/owncloud/owncloud-sdk/pull/966 - Change - Pass full file or directory
   path to methods of Files class: https://github.com/owncloud/owncloud-sdk/pull/971 -
   Change - Remove webdav v1 api support:
   https://github.com/owncloud/owncloud-sdk/pull/962 - Change - Use peerDependencies
   instead of dependencies: https://github.com/owncloud/owncloud-sdk/pull/979 - Bugfix -
   Graceful reject for failing network request in OCS:
   https://github.com/owncloud/owncloud-sdk/pull/977

   https://github.com/owncloud/web/pull/6309
   https://github.com/owncloud/web/pull/6287
   https://github.com/owncloud/owncloud-sdk/releases/tag/v1.1.2
   https://github.com/owncloud/owncloud-sdk/releases/tag/v2.0.0

Changelog for ownCloud Web [4.9.0] (2021-12-24)
=======================================
The following sections list the changes in ownCloud web 4.9.0 relevant to
ownCloud admins and users.

[4.9.0]: https://github.com/owncloud/web/compare/v4.8.0...v4.9.0

Summary
-------

* Enhancement - Print version numbers: [#5954](https://github.com/owncloud/web/issues/5954)

Details
-------

* Enhancement - Print version numbers: [#5954](https://github.com/owncloud/web/issues/5954)

   The package version of the web UI and the version of the backend (if available) now get printed to
   the browser console and get set as meta generator tag in the html head. This makes it possible to
   easily reference versions in bug reports.

   https://github.com/owncloud/web/issues/5954
   https://github.com/owncloud/web/pull/6190

Changelog for ownCloud Web [4.8.0] (2021-12-22)
=======================================
The following sections list the changes in ownCloud web 4.8.0 relevant to
ownCloud admins and users.

[4.8.0]: https://github.com/owncloud/web/compare/v4.7.0...v4.8.0

Summary
-------

* Bugfix - Editor default handling: [#6186](https://github.com/owncloud/web/pull/6186)
* Bugfix - Sort before pagination: [#5687](https://github.com/owncloud/web/issues/5687)
* Enhancement - Edit people shares without changing the panel: [#6039](https://github.com/owncloud/web/pull/6039)
* Enhancement - Respect share max, min and enforced expiration date: [#6176](https://github.com/owncloud/web/pull/6176)
* Enhancement - Simplify people sharing sidebar: [#6039](https://github.com/owncloud/web/pull/6039)

Details
-------

* Bugfix - Editor default handling: [#6186](https://github.com/owncloud/web/pull/6186)

   Editor apps that don't provide the information about whether or not they are a default editor
   were not recognized as default editors when left-clicking a file in the file list. We've
   changed the default behaviour so that editors are capable of being the default editor unless
   explicitly disabled.

   https://github.com/owncloud/web/pull/6186

* Bugfix - Sort before pagination: [#5687](https://github.com/owncloud/web/issues/5687)

   We've extracted the sorting logic from the [OcTable
   component](https://owncloud.design/#/oC%20Components/OcTable) and moved it to the data
   preprocessing steps in web. This way we won't sort the current page anymore, but sort the whole
   data of the current folder and then only show the current page from that sorted data.

   https://github.com/owncloud/web/issues/5687
   https://github.com/owncloud/web/pull/6136

* Enhancement - Edit people shares without changing the panel: [#6039](https://github.com/owncloud/web/pull/6039)

   We have reworked the full list view of sharees in the right sidebar for better overview and
   faster editing.

   https://github.com/owncloud/web/issues/5763
   https://github.com/owncloud/web/pull/6039

* Enhancement - Respect share max, min and enforced expiration date: [#6176](https://github.com/owncloud/web/pull/6176)

   If the expiration date max and/or enforcement is supported (defined by the capabilities) the
   UI now handles the different cases and respects the backend settings. In oc10 there are options
   to enforce the maximum available date for group and user shares, this is now considered in the UI
   and updates dynamically in both cases.

   https://github.com/owncloud/web/pull/6176
   https://github.com/owncloud/web/pull/6039

* Enhancement - Simplify people sharing sidebar: [#6039](https://github.com/owncloud/web/pull/6039)

   We have reworked the people sharing sidebar to not be split into show/edit/create panels. The
   create form now is fixed to the top with the sharees list below and editing happening in-line.

   https://github.com/owncloud/web/issues/5923
   https://github.com/owncloud/web/issues/5608
   https://github.com/owncloud/web/issues/5797
   https://github.com/owncloud/web/pull/6039

Changelog for ownCloud Web [4.7.0] (2021-12-16)
=======================================
The following sections list the changes in ownCloud web 4.7.0 relevant to
ownCloud admins and users.

[4.7.0]: https://github.com/owncloud/web/compare/v4.6.0...v4.7.0

Summary
-------

* Bugfix - Contextmenu on public links: [#6123](https://github.com/owncloud/web/issues/6123)
* Bugfix - Inconsistencies in share expiry dates: [#6084](https://github.com/owncloud/web/pull/6084)
* Bugfix - Extension casing: [#5339](https://github.com/owncloud/web/issues/5339)
* Bugfix - Show extension image: [#5985](https://github.com/owncloud/web/pull/5985)
* Bugfix - File renaming: [#4893](https://github.com/owncloud/web/issues/4893)
* Bugfix - Hidden files hidden by default: [#5985](https://github.com/owncloud/web/pull/5985)
* Bugfix - Ensure route config is honored for new file handlers: [#6135](https://github.com/owncloud/web/pull/6135)
* Bugfix - Show context menu for all file extensions: [#6002](https://github.com/owncloud/web/issues/6002)
* Bugfix - Do not scroll on apps open in app provider: [#5960](https://github.com/owncloud/web/issues/5960)
* Bugfix - Open in browser for public files: [#4615](https://github.com/owncloud/web/issues/4615)
* Bugfix - Order extensions and default: [#5985](https://github.com/owncloud/web/pull/5985)
* Bugfix - Double escaping in progress bar: [#4214](https://github.com/owncloud/web/issues/4214)
* Bugfix - Context for dates in SideBar: [#5068](https://github.com/owncloud/web/issues/5068)
* Bugfix - User email attribute initialization: [#6118](https://github.com/owncloud/web/pull/6118)
* Enhancement - Adopt oc-table-files from ods: [#6106](https://github.com/owncloud/web/pull/6106)
* Enhancement - Show errors when failing to open app in app provider: [#6003](https://github.com/owncloud/web/pull/6003)
* Enhancement - Build options: [#5985](https://github.com/owncloud/web/pull/5985)
* Enhancement - MarkdownEditor and MediaViewer can be default: [#6148](https://github.com/owncloud/web/pull/6148)
* Enhancement - Show feedback on startup: [#5985](https://github.com/owncloud/web/pull/5985)
* Enhancement - Update ODS to v12.0.0-alpha1: [#6106](https://github.com/owncloud/web/pull/6106)

Details
-------

* Bugfix - Contextmenu on public links: [#6123](https://github.com/owncloud/web/issues/6123)

   We fixed an issue of the contextmenu not being displayed for the files table on public links.

   https://github.com/owncloud/web/issues/6123

* Bugfix - Inconsistencies in share expiry dates: [#6084](https://github.com/owncloud/web/pull/6084)

   * Share expiry dates now always refer to the end of the given day. This change allows users to
   select the current day as expiry date. * Displayed expiry dates have been aligned to ensure
   their consistency. * Existing expiry dates for public links can now be removed again. * We now
   use the Luxon `DateTime` object more consistently across the code base (replacing
   JavaScript's `new Date()).

   https://github.com/owncloud/web/pull/6084

* Bugfix - Extension casing: [#5339](https://github.com/owncloud/web/issues/5339)

   We fixed file extensions always being shown in lowercase.

   https://github.com/owncloud/web/issues/5339
   https://github.com/owncloud/web/pull/6117

* Bugfix - Show extension image: [#5985](https://github.com/owncloud/web/pull/5985)

   Allow extensions to set an image as its logo, instead of an icon. If `img` is set, it will take
   precedence over `icon`.

   https://github.com/owncloud/web/pull/5985

* Bugfix - File renaming: [#4893](https://github.com/owncloud/web/issues/4893)

   We fixed the displayed file name not being properly updated in files list and sidebar after
   renaming.

   https://github.com/owncloud/web/issues/4893
   https://github.com/owncloud/web/pull/6114

* Bugfix - Hidden files hidden by default: [#5985](https://github.com/owncloud/web/pull/5985)

   Hide hidden files (files started with ".") by default, similar to oc10

   https://github.com/owncloud/web/pull/5985

* Bugfix - Ensure route config is honored for new file handlers: [#6135](https://github.com/owncloud/web/pull/6135)

   Only display the new file entries for the routes it belongs to.

   https://github.com/owncloud/web/pull/6135

* Bugfix - Show context menu for all file extensions: [#6002](https://github.com/owncloud/web/issues/6002)

   The context menu was failing to build for file extensions that did not have a match in the apps
   from the app provider.

   https://github.com/owncloud/web/issues/6002
   https://github.com/owncloud/web/pull/6003

* Bugfix - Do not scroll on apps open in app provider: [#5960](https://github.com/owncloud/web/issues/5960)

   Apps opened from the app provider were taking more than the window size, prompting the use of the
   scrollbar.

   https://github.com/owncloud/web/issues/5960
   https://github.com/owncloud/web/pull/6003

* Bugfix - Open in browser for public files: [#4615](https://github.com/owncloud/web/issues/4615)

   We fixed opening publicly shared files in the browser.

   https://github.com/owncloud/web/issues/4615
   https://github.com/owncloud/web/pull/6133

* Bugfix - Order extensions and default: [#5985](https://github.com/owncloud/web/pull/5985)

   Ensure the default extensions are displayed first. Ensure that extensions can be set as
   default or not.

   https://github.com/owncloud/web/pull/5985

* Bugfix - Double escaping in progress bar: [#4214](https://github.com/owncloud/web/issues/4214)

   We fixed file names with special chars not being properly displayed in the upload progressbar.

   https://github.com/owncloud/web/issues/4214
   https://github.com/owncloud/web/pull/6131

* Bugfix - Context for dates in SideBar: [#5068](https://github.com/owncloud/web/issues/5068)

   We fixed dates in sidebar file info having no context. The sidebar is either showing the last
   modification date or the deletion date. Before this change it wasn't obvious what kind of date
   was showing. Especially when the file list was showing a completely different date (e.g., a
   share date) it was confusing to the user to see a possibly different date here without
   explanation.

   https://github.com/owncloud/web/issues/5068
   https://github.com/owncloud/web/pull/6119

* Bugfix - User email attribute initialization: [#6118](https://github.com/owncloud/web/pull/6118)

   Until now, the user email would only be set if the user used it instead of a username in the login
   form. It now can also be set from the user webdav response as a fallback.

   https://github.com/owncloud/web/pull/6118

* Enhancement - Adopt oc-table-files from ods: [#6106](https://github.com/owncloud/web/pull/6106)

   Ods oc-table-files always contained concrete web-app-files logic, to make development more
   agile and keep things close oc-table-files was renamed to resource-table and relocated to
   live in web-app-files from now on.

   https://github.com/owncloud/web/pull/6106
   https://github.com/owncloud/owncloud-design-system/pull/1817

* Enhancement - Show errors when failing to open app in app provider: [#6003](https://github.com/owncloud/web/pull/6003)

   The error message provided by wopi is now displayed to the user, giving some context on why it
   failed to open a file.

   https://github.com/owncloud/web/pull/6003

* Enhancement - Build options: [#5985](https://github.com/owncloud/web/pull/5985)

   Configure the startup title (displayed before the configuration is loaded) via env variable
   TITLE. Make the source map generation optional with the env variable SOURCE_MAP.

   https://github.com/owncloud/web/pull/5985

* Enhancement - MarkdownEditor and MediaViewer can be default: [#6148](https://github.com/owncloud/web/pull/6148)

   We have updated the extension handlers of two internal apps to be able to be used as default
   actions.

   https://github.com/owncloud/web/pull/6148

* Enhancement - Show feedback on startup: [#5985](https://github.com/owncloud/web/pull/5985)

   Instead of displaying an empty page while all components load, display a spiner. Also show an
   error message if there was an error.

   https://github.com/owncloud/web/pull/5985

* Enhancement - Update ODS to v12.0.0-alpha1: [#6106](https://github.com/owncloud/web/pull/6106)

   We updated the ownCloud Design System to version 12.0.0-alpha1. Please refer to the full
   changelog in the ODS release (linked) for more details. Summary:

   - Change - Remove oc-table-files from ods:
   https://github.com/owncloud/owncloud-design-system/pull/1817 - Change - Remove unused
   props for unstyled components:
   https://github.com/owncloud/owncloud-design-system/pull/1795

   https://github.com/owncloud/web/pull/6106
   https://github.com/owncloud/owncloud-design-system/releases/tag/v12.0.0-alpha1

Changelog for ownCloud Web [4.6.0] (2021-12-07)
=======================================
The following sections list the changes in ownCloud web 4.6.0 relevant to
ownCloud admins and users.

[4.6.0]: https://github.com/owncloud/web/compare/v4.5.0...v4.6.0

Summary
-------

* Bugfix - Pagination: [#6056](https://github.com/owncloud/web/pull/6056)
* Enhancement - Implement breadcrumb context menu: [#6044](https://github.com/owncloud/web/pull/6044)
* Enhancement - Contextmenu for multiple files: [#5973](https://github.com/owncloud/web/pull/5973)
* Enhancement - Add tooltips to relative dates: [#6037](https://github.com/owncloud/web/pull/6037)
* Enhancement - Update ODS to v11.3.1: [#6090](https://github.com/owncloud/web/pull/6090)

Details
-------

* Bugfix - Pagination: [#6056](https://github.com/owncloud/web/pull/6056)

   We fixed the pagination as it was slicing the items wrong on pages after the first one.

   https://github.com/owncloud/web/pull/6056

* Enhancement - Implement breadcrumb context menu: [#6044](https://github.com/owncloud/web/pull/6044)

   The last element of the breadcrumb now has a context menu which gives the user the possibility to
   perform actions on the current folder.

   https://github.com/owncloud/web/issues/6030
   https://github.com/owncloud/web/pull/6044

* Enhancement - Contextmenu for multiple files: [#5973](https://github.com/owncloud/web/pull/5973)

   We have enabled batch actions in the context menu for when multiple resources are selected.

   https://github.com/owncloud/web/issues/5968
   https://github.com/owncloud/web/issues/5977
   https://github.com/owncloud/web/pull/5973

* Enhancement - Add tooltips to relative dates: [#6037](https://github.com/owncloud/web/pull/6037)

   Relative dates like "1 day ago" now have a tooltip that shows the absolute date.

   https://github.com/owncloud/web/issues/5672
   https://github.com/owncloud/web/pull/6037

* Enhancement - Update ODS to v11.3.1: [#6090](https://github.com/owncloud/web/pull/6090)

   We updated the ownCloud Design System to version 11.3.1. Please refer to the full changelog in
   the ODS release (linked) for more details. Summary:

   - Bugfix - Set language for date formatting:
   https://github.com/owncloud/owncloud-design-system/pull/1806 - Enhancement -
   Relative date tooltips in the OcTableFiles component:
   https://github.com/owncloud/owncloud-design-system/pull/1787 - Enhancement -
   Breadcrumb contextmenu: https://github.com/owncloud/web/issues/6030 - Enhancement -
   Optional padding size for OcDrop:
   https://github.com/owncloud/owncloud-design-system/pull/1798 - Enhancement -
   Truncate file names while preserving file extensions:
   https://github.com/owncloud/owncloud-design-system/issues/1758

   https://github.com/owncloud/web/pull/6090
   https://github.com/owncloud/owncloud-design-system/releases/tag/v11.3.0
   https://github.com/owncloud/owncloud-design-system/releases/tag/v11.3.1

Changelog for ownCloud Web [4.5.0] (2021-11-16)
=======================================
The following sections list the changes in ownCloud web 4.5.0 relevant to
ownCloud admins and users.

[4.5.0]: https://github.com/owncloud/web/compare/v4.4.0...v4.5.0

Summary
-------

* Bugfix - Fix location picker breadcrumb url encoding: [#5940](https://github.com/owncloud/web/pull/5940)
* Bugfix - Correct capabilities URL when server run in a subfolder: [#6010](https://github.com/owncloud/web/issues/6010)
* Bugfix - Context menu rendering: [#5952](https://github.com/owncloud/web/pull/5952)
* Bugfix - Use search app translations: [#5955](https://github.com/owncloud/web/issues/5955)
* Enhancement - Accentuate new files: [#6020](https://github.com/owncloud/web/pull/6020)
* Enhancement - Use default info from app provider: [#5962](https://github.com/owncloud/web/issues/5962)
* Enhancement - Rename `_chunks` folder to `chunks`: [#5988](https://github.com/owncloud/web/pull/5988)
* Enhancement - Default action order: [#5952](https://github.com/owncloud/web/pull/5952)
* Enhancement - Reduced sidebar width: [#5981](https://github.com/owncloud/web/issues/5981)
* Enhancement - Automatically show oC 10 apps in the app switcher menu: [#5980](https://github.com/owncloud/web/issues/5980)
* Enhancement - App provider and archiver on public links: [#5924](https://github.com/owncloud/web/pull/5924)
* Enhancement - Update ODS to v11.2.2: [#6009](https://github.com/owncloud/web/pull/6009)

Details
-------

* Bugfix - Fix location picker breadcrumb url encoding: [#5940](https://github.com/owncloud/web/pull/5940)

   The breadcrumb urls in location-picker were encoded. We've fixed this by removing the
   encoding.

   https://github.com/owncloud/web/issues/5938
   https://github.com/owncloud/web/pull/5940
   https://github.com/owncloud/web/pull/5715

* Bugfix - Correct capabilities URL when server run in a subfolder: [#6010](https://github.com/owncloud/web/issues/6010)

   We fixed an issue where the capabilities where requested from a wrong URL in the case the server
   is running in a subfolder e.g. `http://localhost/owncloud`

   https://github.com/owncloud/web/issues/6010

* Bugfix - Context menu rendering: [#5952](https://github.com/owncloud/web/pull/5952)

   We fixed that the context menu was being created for each and every file row of the current page
   (it was just not made visible). Now it only gets created when it gets activated by the user for a
   file row.

   https://github.com/owncloud/web/pull/5952

* Bugfix - Use search app translations: [#5955](https://github.com/owncloud/web/issues/5955)

   We fixed that the search app was not using its translations properly.

   https://github.com/owncloud/web/issues/5955
   https://github.com/owncloud/web/pull/5956

* Enhancement - Accentuate new files: [#6020](https://github.com/owncloud/web/pull/6020)

   We've added a visual highlighting of newly created (or uploaded) resources in the
   OcFilesTable.

   https://github.com/owncloud/web/pull/6020

* Enhancement - Use default info from app provider: [#5962](https://github.com/owncloud/web/issues/5962)

   The app provider returns information about the default application per mime type. This
   information is now respected when triggering the default action for a file.

   https://github.com/owncloud/web/issues/5962
   https://github.com/owncloud/web/pull/5970

* Enhancement - Rename `_chunks` folder to `chunks`: [#5988](https://github.com/owncloud/web/pull/5988)

   We've renamed the `_chunks` folder to `chunks` in the ownCloud Web build output in order to make
   it more easily embedable with the Go embed directive.

   https://github.com/owncloud/web/pull/5988

* Enhancement - Default action order: [#5952](https://github.com/owncloud/web/pull/5952)

   We've changed the order of actions which are being considered as default action. The order is
   now 1) installed editors, 2) external apps from the app provider, 3) system default actions.
   Previously the external apps took precedence.

   https://github.com/owncloud/web/pull/5952

* Enhancement - Reduced sidebar width: [#5981](https://github.com/owncloud/web/issues/5981)

   We reduced the sidebar width to give the files list more horizontal room, especially on medium
   sized screens.

   https://github.com/owncloud/web/issues/5981
   https://github.com/owncloud/web/pull/5983

* Enhancement - Automatically show oC 10 apps in the app switcher menu: [#5980](https://github.com/owncloud/web/issues/5980)

   When using the ownCloud 10 app of web the configuration automatically gets augmented with all
   menu items / apps from the classic UI. They open in a new tab in the classic UI and have a generic
   icon.

   https://github.com/owncloud/web/issues/5980
   https://github.com/owncloud/web/pull/5996

* Enhancement - App provider and archiver on public links: [#5924](https://github.com/owncloud/web/pull/5924)

   We made the app provider and archiver services available on public links. As a prerequisite for
   this we needed to make backend capabilities available on public links, which will be
   beneficial for all future extension development.

   https://github.com/owncloud/web/issues/5884
   https://github.com/owncloud/ocis/issues/2479
   https://github.com/owncloud/web/issues/2479
   https://github.com/owncloud/web/issues/5901
   https://github.com/owncloud/web/pull/5924

* Enhancement - Update ODS to v11.2.2: [#6009](https://github.com/owncloud/web/pull/6009)

   We updated the ownCloud Design System to version 11.2.2. Please refer to the full changelog in
   the ODS release (linked) for more details. Summary:

   - Bugfix - Limit select event in OcTableFiles:
   https://github.com/owncloud/owncloud-design-system/pull/1753 - Bugfix - Add
   word-break rule to OcNotificationMessage component:
   https://github.com/owncloud/owncloud-design-system/issues/1712 - Bugfix - OcTable
   sorting case sensitivity:
   https://github.com/owncloud/owncloud-design-system/issues/1698 - Bugfix - Drag and
   Drop triggers wrong actions: https://github.com/owncloud/web/issues/5808 - Bugfix - Fix
   files table event: https://github.com/owncloud/web/issues/1777 - Bugfix - Fix extension
   icon rendering: https://github.com/owncloud/web/issues/1779 - Enhancement - Make
   OcDatepicker themable:
   https://github.com/owncloud/owncloud-design-system/issues/1679 - Enhancement -
   Streamline OcTextInput:
   https://github.com/owncloud/owncloud-design-system/pull/1636 - Enhancement - Add
   accentuated class for OcTable:
   https://github.com/owncloud/owncloud-design-system/pull/5967 - Enhancement - Add
   Ghost Element for Drag & Drop:
   https://github.com/owncloud/owncloud-design-system/pull/5788 - Enhancement - Add
   "extension" svg icon: https://github.com/owncloud/owncloud-design-system/pull/1771 -
   Enhancement - Add closure to mutate resource dom selector:
   https://github.com/owncloud/owncloud-design-system/pull/1766 - Enhancement - Reduce
   filename text weight: https://github.com/owncloud/owncloud-design-system/pull/1759

   https://github.com/owncloud/web/pull/6009
   https://github.com/owncloud/owncloud-design-system/releases/tag/v11.2.2

Changelog for ownCloud Web [4.4.0] (2021-10-26)
=======================================
The following sections list the changes in ownCloud web 4.4.0 relevant to
ownCloud admins and users.

[4.4.0]: https://github.com/owncloud/web/compare/v4.3.0...v4.4.0

Summary
-------

* Bugfix - Fix duplicated event subscriptions: [#5910](https://github.com/owncloud/web/pull/5910)
* Bugfix - External apps by shares: [#5907](https://github.com/owncloud/web/pull/5907)
* Bugfix - New Collaborator removes wrong autocomplete items: [#5857](https://github.com/owncloud/web/issues/5857)
* Bugfix - Fix overlapping requests in files app: [#5917](https://github.com/owncloud/web/pull/5917)
* Bugfix - Clean router path handling: [#5894](https://github.com/owncloud/web/pull/5894)
* Bugfix - Unnecessary redirects on personal page: [#5893](https://github.com/owncloud/web/pull/5893)
* Enhancement - Accessible, themeable media viewer: [#5900](https://github.com/owncloud/web/pull/5900)
* Enhancement - Datepicker in Dropdown: [#5806](https://github.com/owncloud/web/pull/5806)
* Enhancement - Sorting out dependencies: [#5898](https://github.com/owncloud/web/pull/5898)
* Enhancement - Update ODS to v11.0.0: [#5806](https://github.com/owncloud/web/pull/5806)

Details
-------

* Bugfix - Fix duplicated event subscriptions: [#5910](https://github.com/owncloud/web/pull/5910)

   In some cases it happened that subscriptions to certain topics happened multiple times. This
   is problematic in cases where it should happen only once, for example loading a resource which
   can result in multiple requests and a overlapping state.

   This is fixes by introducing the option to unsubscribe a event individually by a given token or
   for all on a given topic.

   https://github.com/owncloud/web/issues/5875
   https://github.com/owncloud/web/pull/5910

* Bugfix - External apps by shares: [#5907](https://github.com/owncloud/web/pull/5907)

   Opening shares in "Shared with me" section was broken. We have added property `mimeType` by the
   build of a shared resource, so that the external apps can be found for it.

   We fixed passing the fileId property for the context actions.

   https://github.com/owncloud/web/issues/5906
   https://github.com/owncloud/web/pull/5907

* Bugfix - New Collaborator removes wrong autocomplete items: [#5857](https://github.com/owncloud/web/issues/5857)

   We've addressed that when you add new collaborators in the autocomplete and remove one from the
   autocompletion it always removes the last element.

   https://github.com/owncloud/web/issues/5857
   https://github.com/owncloud/web/pull/5931

* Bugfix - Fix overlapping requests in files app: [#5917](https://github.com/owncloud/web/pull/5917)

   In some cases the files app tended to display the wrong resources when navigating quickly
   through the views. This happened because the resource provisioning step wasn't canceled.
   This is now fixed by using vue-concurrency which on a high level wraps iterable generators
   which are cancelable. We're using it to wrap the resource loading and cancel it as soon as the
   resource set is not needed anymore.

   It also improves the overall performance for the files app.

   https://github.com/owncloud/web/issues/5085
   https://github.com/owncloud/web/issues/5875
   https://github.com/owncloud/web/pull/5917

* Bugfix - Clean router path handling: [#5894](https://github.com/owncloud/web/pull/5894)

   This patch was already introduced earlier for the files application only. In the meantime we
   found out that this is also needed on different places across the ecosystem.

   We've refactored the way how the patch gets applied to the routes: It is now possible to set an
   individual route's `meta.patchCleanPath` to true.

   https://github.com/owncloud/web/issues/4595#issuecomment-938587035
   https://github.com/owncloud/web/pull/5894

* Bugfix - Unnecessary redirects on personal page: [#5893](https://github.com/owncloud/web/pull/5893)

   Navigating to all files could lead to loading resources twice, first resources from root (/)
   and second the resources from the homeFolder (options.homeFolder). We've fixed this by
   detecting those cases and only load resources for the homeFolder.

   https://github.com/owncloud/web/issues/5085
   https://github.com/owncloud/web/issues/5875
   https://github.com/owncloud/web/pull/5893

* Enhancement - Accessible, themeable media viewer: [#5900](https://github.com/owncloud/web/pull/5900)

   We have updated the media viewer app to respect theme colors and fulfill accessibility
   requirements (e.g. keyboard navigation, semantic HTML, font size).

   https://github.com/owncloud/web/pull/5900

* Enhancement - Datepicker in Dropdown: [#5806](https://github.com/owncloud/web/pull/5806)

   We have moved the datepicker for share expiration in the right sidebar into a dropdown to align
   it with the other elements when creating/editing shares.

   https://github.com/owncloud/web/pull/5806

* Enhancement - Sorting out dependencies: [#5898](https://github.com/owncloud/web/pull/5898)

   We have cleaned and simplified the dependency structure in our apps.

   https://github.com/owncloud/web/pull/5898

* Enhancement - Update ODS to v11.0.0: [#5806](https://github.com/owncloud/web/pull/5806)

   We updated the ownCloud Design System to version 11.0.0. Please refer to the full changelog in
   the ODS release (linked) for more details. Summary:

   - Bugfix - Prevent hover style on footer of OcTableFiles:
   https://github.com/owncloud/owncloud-design-system/pull/1667 - Change - Replace
   vue-datetime with v-calendar in our datepicker component:
   https://github.com/owncloud/owncloud-design-system/pull/1661 - Enhancement - Allow
   hover option in OcTableFiles:
   https://github.com/owncloud/owncloud-design-system/pull/1632

   https://github.com/owncloud/web/pull/5806
   https://github.com/owncloud/owncloud-design-system/releases/tag/v11.0.0

Changelog for ownCloud Web [4.3.0] (2021-10-07)
=======================================
The following sections list the changes in ownCloud web 4.3.0 relevant to
ownCloud admins and users.

[4.3.0]: https://github.com/owncloud/web/compare/v4.2.0...v4.3.0

Summary
-------

* Enhancement - Download as archive: [#5832](https://github.com/owncloud/web/pull/5832)
* Enhancement - Early store initialization: [#5874](https://github.com/owncloud/web/pull/5874)
* Enhancement - Add wrapper app for external apps: [#5805](https://github.com/owncloud/web/pull/5805)
* Enhancement - Add AppProvider actions to fileactions: [#5805](https://github.com/owncloud/web/pull/5805)
* Enhancement - Move custom permissions to roles drop: [#5764](https://github.com/owncloud/web/issues/5764)
* Enhancement - Refactor runtime boot process: [#5752](https://github.com/owncloud/web/pull/5752)
* Enhancement - Multiple shared with me tables: [#5814](https://github.com/owncloud/web/pull/5814)

Details
-------

* Enhancement - Download as archive: [#5832](https://github.com/owncloud/web/pull/5832)

   We've introduced archive downloads based on whether or not an archiver capability is present.
   The current implementation supports the archiver v2 (a.k.a. the REVA implementation).
   Archive downloads are available in two different ways: - as action on a folder (right-click
   context menu or actions panel in the right sidebar) - as batch action for all selected files The
   implementation is currently limited to authenticated contexts. A public links
   implementation will follow soon.

   https://github.com/owncloud/web/issues/3913
   https://github.com/owncloud/web/issues/5809
   https://github.com/owncloud/web/pull/5832

* Enhancement - Early store initialization: [#5874](https://github.com/owncloud/web/pull/5874)

   We made sure that the store and auth get initialized as early as possible. With this we ensured
   that capabilities are always loaded as soon as applications start their initialization
   process.

   https://github.com/owncloud/web/pull/5874

* Enhancement - Add wrapper app for external apps: [#5805](https://github.com/owncloud/web/pull/5805)

   We have added a `external` app that can render apps coming from the oCIS AppProvider via iFrame.

   https://github.com/owncloud/web/pull/5805

* Enhancement - Add AppProvider actions to fileactions: [#5805](https://github.com/owncloud/web/pull/5805)

   If the AppProvider within oCIS communicates a matching application for the mime type of a file,
   there are now additional actions in the default actions and actions in both the contextmenu and
   the right sidebar.

   https://github.com/owncloud/web/pull/5805

* Enhancement - Move custom permissions to roles drop: [#5764](https://github.com/owncloud/web/issues/5764)

   We've moved all the custom permissions (previously advanced permissions) in the sharing
   dialog into a dropdown which gets triggered by selecting the Custom permissions item in the
   roles dropdown.

   https://github.com/owncloud/web/issues/5764
   https://github.com/owncloud/web/pull/5647

* Enhancement - Refactor runtime boot process: [#5752](https://github.com/owncloud/web/pull/5752)

   We have updated the way applications are being loaded in the web runtime. It does now feature a
   dedicated boot process, providing hooks that other applications can take advantage of.

   https://github.com/owncloud/web/issues/2891
   https://github.com/owncloud/web/issues/3726
   https://github.com/owncloud/web/issues/3771
   https://github.com/owncloud/web/issues/4735
   https://github.com/owncloud/web/issues/5135
   https://github.com/owncloud/web/issues/5460
   https://github.com/owncloud/web/pull/5752
   (tbd)
   (tbd)
   (tbd,
   %22needs
   api
   tweak%22%29
   (tbd)
   (tbd)
   (tbd)

* Enhancement - Multiple shared with me tables: [#5814](https://github.com/owncloud/web/pull/5814)

   We have separated the single table on the shared with me page into up to three different tables: -
   pending shares - accepted shares - declined shares By default we show pending and accepted
   shares. There is navigation in place to switch over from the accepted to the declined shares and
   the other way around. Pending shares stay visible all the time since it's expected that users
   take immediate action on pending shares anyway.

   https://github.com/owncloud/web/pull/5814
   https://github.com/owncloud/web/pull/5177

Changelog for ownCloud Web [4.2.0] (2021-09-14)
=======================================
The following sections list the changes in ownCloud web 4.2.0 relevant to
ownCloud admins and users.

[4.2.0]: https://github.com/owncloud/web/compare/v4.1.0...v4.2.0

Summary
-------

* Bugfix - Pagination on Locationpicker: [#5715](https://github.com/owncloud/web/pull/5715)
* Enhancement - Add robots.txt file: [#5762](https://github.com/owncloud/web/pull/5762)
* Enhancement - Fetch file info in the Files sidebar: [#5570](https://github.com/owncloud/web/issues/5570)
* Enhancement - Add missing tooltips: [#5723](https://github.com/owncloud/web/issues/5723)
* Enhancement - Re-design recipients role select: [#5632](https://github.com/owncloud/web/pull/5632)
* Enhancement - Show sharees as collapsed list of avatars: [#5758](https://github.com/owncloud/web/pull/5758)
* Enhancement - Show sharing information in details sidebar: [#5735](https://github.com/owncloud/web/issues/5735)
* Enhancement - Switch filesize calculation base: [#5739](https://github.com/owncloud/web/pull/5739)
* Enhancement - Update ODS to 10.0.0: [#5725](https://github.com/owncloud/web/pull/5725)
* Enhancement - URL encoding / decoding: [#5714](https://github.com/owncloud/web/issues/5714)

Details
-------

* Bugfix - Pagination on Locationpicker: [#5715](https://github.com/owncloud/web/pull/5715)

   Pagination on copying/moving files as well as page reloads when copying/moving files were
   broken. When changing the Vue router encoding, we fixed both issues.

   https://github.com/owncloud/web/pull/5715

* Enhancement - Add robots.txt file: [#5762](https://github.com/owncloud/web/pull/5762)

   Added a robots.txt for ocis-web

   https://github.com/owncloud/web/pull/5762

* Enhancement - Fetch file info in the Files sidebar: [#5570](https://github.com/owncloud/web/issues/5570)

   We've started fetching the file info when a single item is selected and the Files sidebar is
   opened. With this change we have more information available in different lists e.g. private
   link in shared lists.

   https://github.com/owncloud/web/issues/5570
   https://github.com/owncloud/web/pull/5665

* Enhancement - Add missing tooltips: [#5723](https://github.com/owncloud/web/issues/5723)

   We've added tooltips to the "view option dropdown" and "toggle sidebar" buttons.

   https://github.com/owncloud/web/issues/5723
   https://github.com/owncloud/web/pull/5724

* Enhancement - Re-design recipients role select: [#5632](https://github.com/owncloud/web/pull/5632)

   We've redesigned recipient role select in the Files app sidebar.

   https://github.com/owncloud/web/pull/5632

* Enhancement - Show sharees as collapsed list of avatars: [#5758](https://github.com/owncloud/web/pull/5758)

   We've introduced a collapsed list of avatars of sharees in the `People` panel of the right
   sidebar. On click we switch to showing the full list of sharees. With this additional
   intermediate state we were able to clean up the UI a bit for easier cognitive load.

   https://github.com/owncloud/web/issues/5736
   https://github.com/owncloud/web/pull/5758

* Enhancement - Show sharing information in details sidebar: [#5735](https://github.com/owncloud/web/issues/5735)

   We've added sharing information like from whom, when and where a file was shared to the detail
   view in the right sidebar.

   https://github.com/owncloud/web/issues/5735
   https://github.com/owncloud/web/pull/5730

* Enhancement - Switch filesize calculation base: [#5739](https://github.com/owncloud/web/pull/5739)

   We've switched from base-2 to base-10 when calculating the displayed file-size to align it
   better with user expectations.

   https://github.com/owncloud/web/pull/5739

* Enhancement - Update ODS to 10.0.0: [#5725](https://github.com/owncloud/web/pull/5725)

   We updated the ownCloud Design System to version 10.0.0. Please refer to the full changelog in
   the ODS release (linked) for more details. Summary: - Bugfix - Fix search for options provided
   as objects: https://github.com/owncloud/owncloud-design-system/pull/1602 - Bugfix -
   Contextmenu button triggered wrong event:
   https://github.com/owncloud/owncloud-design-system/pull/1610 - Bugfix - Use pointer
   cursor for OcSelect actions:
   https://github.com/owncloud/owncloud-design-system/pull/1604 - Bugfix - Reset
   droptarget background color in OcTableFiles:
   https://github.com/owncloud/owncloud-design-system/pull/1625 - Enhancement -
   OcTableFiles Contextmenu Tooltip:
   https://github.com/owncloud/owncloud-design-system/pull/1610 - Enhancement -
   Highlight droptarget in OcTableFiles:
   https://github.com/owncloud/owncloud-design-system/pull/1610 - Enhancement - Remove
   "Showdetails" button in OcTableFiles:
   https://github.com/owncloud/owncloud-design-system/pull/1610 - Enhancement - Switch
   filesize calculation base:
   https://github.com/owncloud/owncloud-design-system/pull/1598 - Change - Use route
   query to store active page:
   https://github.com/owncloud/owncloud-design-system/pull/1626 - Change - Refactor
   OcAvatarGroup and rename to OcAvatars:
   https://github.com/owncloud/owncloud-design-system/pull/5736 - Change - Add label prop
   to OcSelect: https://github.com/owncloud/owncloud-design-system/pull/1633

   https://github.com/owncloud/web/pull/5725
   https://github.com/owncloud/web/pull/5769
   https://github.com/owncloud/owncloud-design-system/releases/tag/v9.3.0
   https://github.com/owncloud/owncloud-design-system/releases/tag/v10.0.0

* Enhancement - URL encoding / decoding: [#5714](https://github.com/owncloud/web/issues/5714)

   We have updated the Vue router (prior to version 4) encoding from `files%2Fall%2Ffolder` to
   `files/all/folder`. It was also needed to use the router query object instead of the params to
   store the current page pagination information.

   https://github.com/owncloud/web/issues/5714
   https://github.com/owncloud/web/pull/5715

Changelog for ownCloud Web [4.1.0] (2021-08-20)
=======================================
The following sections list the changes in ownCloud web 4.1.0 relevant to
ownCloud admins and users.

[4.1.0]: https://github.com/owncloud/web/compare/v4.0.0...v4.1.0

Summary
-------

* Bugfix - Escape file name in Media viewer: [#5593](https://github.com/owncloud/web/issues/5593)
* Bugfix - Handle loading and parsing errors when loading themes: [#5669](https://github.com/owncloud/web/pull/5669)
* Bugfix - Load folder in Media viewer: [#5427](https://github.com/owncloud/web/issues/5427)
* Enhancement - Add multiple selection Sidebar: [#5164](https://github.com/owncloud/web/issues/5164)
* Enhancement - Enable live reload for changes to themes: [#5668](https://github.com/owncloud/web/pull/5668)
* Enhancement - Move file via drag and drop: [#5592](https://github.com/owncloud/web/issues/5592)
* Enhancement - Refresh files list via breadcrumbs: [#2018](https://github.com/owncloud/web/issues/2018)
* Enhancement - Signout icon: [#5681](https://github.com/owncloud/web/pull/5681)
* Enhancement - Toggle right sidebar: [#5165](https://github.com/owncloud/web/issues/5165)
* Enhancement - Update ODS to 9.2.0: [#5689](https://github.com/owncloud/web/pull/5689)

Details
-------

* Bugfix - Escape file name in Media viewer: [#5593](https://github.com/owncloud/web/issues/5593)

   We've started escaping the file name in the Media viewer extension so that a file with special
   characters in the name can still be loaded.

   https://github.com/owncloud/web/issues/5593
   https://github.com/owncloud/web/pull/5655

* Bugfix - Handle loading and parsing errors when loading themes: [#5669](https://github.com/owncloud/web/pull/5669)

   Adds graceful error handling of json parse errors when loading custom themes.

   https://github.com/owncloud/web/pull/5669

* Bugfix - Load folder in Media viewer: [#5427](https://github.com/owncloud/web/issues/5427)

   We've fixed the loading of a folder in the Media viewer extension. If a user reloads the Media
   viewer now, it load all the medias both in private and public context.

   https://github.com/owncloud/web/issues/5427
   https://github.com/owncloud/web/pull/5585
   https://github.com/owncloud/web/pull/5710

* Enhancement - Add multiple selection Sidebar: [#5164](https://github.com/owncloud/web/issues/5164)

   We've changed the sidebar so if a user selects multiple files or folders he sees a detailed view
   of his selection in the sidebar.

   https://github.com/owncloud/web/issues/5164
   https://github.com/owncloud/web/pull/5630

* Enhancement - Enable live reload for changes to themes: [#5668](https://github.com/owncloud/web/pull/5668)

   This allows live reloads to be triggered by changes to themes defined within the
   'packages/web-runtime/themes/**/*' folders, to facilitate efficient WYSIWYG
   development when wanting to customise the look and feel of the frontend.

   https://github.com/owncloud/web/pull/5668

* Enhancement - Move file via drag and drop: [#5592](https://github.com/owncloud/web/issues/5592)

   We've added moving files and folders via drag and drop to the files table view.

   https://github.com/owncloud/web/issues/5592
   https://github.com/owncloud/web/pull/5588

* Enhancement - Refresh files list via breadcrumbs: [#2018](https://github.com/owncloud/web/issues/2018)

   In the personal and public files lists we've added a click handler to the last breadcrumb item
   representing the current folder that reloads the files list.

   https://github.com/owncloud/web/issues/2018
   https://github.com/owncloud/web/pull/5659

* Enhancement - Signout icon: [#5681](https://github.com/owncloud/web/pull/5681)

   We changed the icon in the personal menu nav item for signing out based on recent user feedback.

   https://github.com/owncloud/web/pull/5681

* Enhancement - Toggle right sidebar: [#5165](https://github.com/owncloud/web/issues/5165)

   We introduced a button above the files list to toggle the right sidebar (open/close). It always
   opens for the current selection model. If nothing is selected, the current folder will be shown
   in the right sidebar. With this we now allow sharing a folder when the user already navigated
   into it.

   https://github.com/owncloud/web/issues/5165
   https://github.com/owncloud/web/pull/5678
   https://github.com/owncloud/web/pull/5709

* Enhancement - Update ODS to 9.2.0: [#5689](https://github.com/owncloud/web/pull/5689)

   We updated the ownCloud Design System to version 9.2.0.

   https://github.com/owncloud/web/pull/5689
   https://github.com/owncloud/owncloud-design-system/releases/tag/v9.0.0
   https://github.com/owncloud/owncloud-design-system/releases/tag/v9.0.1
   https://github.com/owncloud/owncloud-design-system/releases/tag/v9.1.0
   https://github.com/owncloud/owncloud-design-system/releases/tag/v9.2.0

Changelog for ownCloud Web [4.0.0] (2021-08-04)
=======================================
The following sections list the changes in ownCloud web 4.0.0 relevant to
ownCloud admins and users.

[4.0.0]: https://github.com/owncloud/web/compare/v3.4.1...v4.0.0

Summary
-------

* Bugfix - Left sidebar visibility in public links: [#5602](https://github.com/owncloud/web/pull/5602)
* Bugfix - Check names also for folders or files that currently are not visible: [#5583](https://github.com/owncloud/web/pull/5583)
* Bugfix - Content Security Policy for OpenID Connect authentication: [#5536](https://github.com/owncloud/web/pull/5536)
* Bugfix - Send authentication on manifests.json: [#5553](https://github.com/owncloud/web/pull/5553)
* Bugfix - Unnecessary quota requests: [#5539](https://github.com/owncloud/web/pull/5539)
* Bugfix - Use profile picture capability in avatars: [#5178](https://github.com/owncloud/web/pull/5178)
* Change - Add custom search service: [#5415](https://github.com/owncloud/web/pull/5415)
* Enhancement - New layout for context menu: [#5160](https://github.com/owncloud/web/issues/5160)
* Enhancement - Dropdown actions in FilesTable: [#5102](https://github.com/owncloud/web/issues/5102)
* Enhancement - Refactor recipient autocomplete in people panel: [#5554](https://github.com/owncloud/web/pull/5554)
* Enhancement - Load only opened panels: [#5569](https://github.com/owncloud/web/issues/5569)
* Enhancement - Prevent binding to only loopback IP when running in watch mode: [#5515](https://github.com/owncloud/web/pull/5515)
* Enhancement - Add filter & search to files app: [#5415](https://github.com/owncloud/web/pull/5415)
* Enhancement - Define the number of visible share recipients: [#5506](https://github.com/owncloud/web/pull/5506)
* Enhancement - Sidebar sliding panels navigation: [#5549](https://github.com/owncloud/web/pull/5549)

Details
-------

* Bugfix - Left sidebar visibility in public links: [#5602](https://github.com/owncloud/web/pull/5602)

   We fixed that the left sidebar was showing the navigation items of an authenticated context
   when visiting a public link as authenticated user.

   https://github.com/owncloud/web/pull/5602

* Bugfix - Check names also for folders or files that currently are not visible: [#5583](https://github.com/owncloud/web/pull/5583)

   We've changed the way how web checks if a file or folder exists. From now on it also include files
   from the current folder that actually are not visible.

   This was problematic in situations like the pagination, where a file or folder was not
   available in the current set of resources and the user tried to create a folder with the same
   name.

   https://github.com/owncloud/web/pull/5583

* Bugfix - Content Security Policy for OpenID Connect authentication: [#5536](https://github.com/owncloud/web/pull/5536)

   We added CSP rules for allowing OpenID Connect authentication when running ownCloud Web as app
   in ownCloud 10.

   https://github.com/owncloud/web/pull/5536

* Bugfix - Send authentication on manifests.json: [#5553](https://github.com/owncloud/web/pull/5553)

   We've changed that requests to manifest.json will use authentication, too.

   https://github.com/owncloud/web/pull/5553

* Bugfix - Unnecessary quota requests: [#5539](https://github.com/owncloud/web/pull/5539)

   We've removed requests that checked for a user's quota on pages where it was not relevant.

   https://github.com/owncloud/web/pull/5539

* Bugfix - Use profile picture capability in avatars: [#5178](https://github.com/owncloud/web/pull/5178)

   Requests for loading avatar profile pictures now only get sent if the backend communicates
   their availability in the capabilities.

   https://github.com/owncloud/web/pull/5178

* Change - Add custom search service: [#5415](https://github.com/owncloud/web/pull/5415)

   We've added `search` as another core app that can be utilized by other (third-party) frontend
   extensions to provide filter and search functionality. Please note that you need to add
   `search` to the `apps` array of your config.json file, otherwise the search bar with its global
   file search capabilities will disappear.

   https://github.com/owncloud/web/pull/5415

* Enhancement - New layout for context menu: [#5160](https://github.com/owncloud/web/issues/5160)

   The new context menu in the files list received additional menu items and a clear separation
   into three sections.

   https://github.com/owncloud/web/issues/5160
   https://github.com/owncloud/web/pull/5576

* Enhancement - Dropdown actions in FilesTable: [#5102](https://github.com/owncloud/web/issues/5102)

   Users can now access quick actions in a dropdown by clicking on the three-dots button or
   right-clicking on rows in the files table.

   We've also bumped the ownCloud Design System to version 8.3.0

   https://github.com/owncloud/web/issues/5102
   https://github.com/owncloud/web/issues/5103
   https://github.com/owncloud/web/pull/5551
   https://github.com/owncloud/web/pull/5554
   https://github.com/owncloud/owncloud-design-system/releases/tag/v8.3.0

* Enhancement - Refactor recipient autocomplete in people panel: [#5554](https://github.com/owncloud/web/pull/5554)

   We've refactored the recipient autocomplete in people panel so that selected recipients are
   displayed directly in the autocomplete instead of the list below it.

   https://github.com/owncloud/web/pull/5554

* Enhancement - Load only opened panels: [#5569](https://github.com/owncloud/web/issues/5569)

   Do not load panels in the Files extension sidebar until they are opened.

   https://github.com/owncloud/web/issues/5569
   https://github.com/owncloud/web/pull/5573

* Enhancement - Prevent binding to only loopback IP when running in watch mode: [#5515](https://github.com/owncloud/web/pull/5515)

   This is required when running the acceptance tests on Windows, it allows the selenium docker
   containers to access the frontend due to the host binding in rollup (when running `yarn
   serve`). Does not break any existing functionality.

   https://github.com/owncloud/web/pull/5515

* Enhancement - Add filter & search to files app: [#5415](https://github.com/owncloud/web/pull/5415)

   We've changed the existing searchbar to use the custom search service. It is now able to be used
   at the same time as a filter (on the frontend) and, if the backend is capable of search, as a search
   input.

   https://github.com/owncloud/web/pull/5415

* Enhancement - Define the number of visible share recipients: [#5506](https://github.com/owncloud/web/pull/5506)

   We've added a new configuration option `sharingRecipientsPerPage` to define how many
   recipients should be shown in the share recipients dropdown.

   https://github.com/owncloud/web/pull/5506

* Enhancement - Sidebar sliding panels navigation: [#5549](https://github.com/owncloud/web/pull/5549)

   The sidebar now uses a ios like concept for navigate through the different actions in the
   sidebar. It replaces the accordion navigation entirely.

   https://github.com/owncloud/web/issues/5523
   https://github.com/owncloud/web/pull/5549

Changelog for ownCloud Web [3.4.1] (2021-07-12)
=======================================
The following sections list the changes in ownCloud web 3.4.1 relevant to
ownCloud admins and users.

[3.4.1]: https://github.com/owncloud/web/compare/v3.4.0...v3.4.1

Summary
-------

* Bugfix - Load preview in right sidebar: [#5501](https://github.com/owncloud/web/pull/5501)
* Bugfix - Align view options to the right: [#5493](https://github.com/owncloud/web/pull/5493)

Details
-------

* Bugfix - Load preview in right sidebar: [#5501](https://github.com/owncloud/web/pull/5501)

   We fixed a bug that caused previews not being loaded in the details accordion of the right
   sidebar.

   https://github.com/owncloud/web/pull/5501

* Bugfix - Align view options to the right: [#5493](https://github.com/owncloud/web/pull/5493)

   We've fixed the position of the view options button which would appear in any screen where
   actions are missing on the left.

   https://github.com/owncloud/web/pull/5493

Changelog for ownCloud Web [3.4.0] (2021-07-09)
=======================================
The following sections list the changes in ownCloud web 3.4.0 relevant to
ownCloud admins and users.

[3.4.0]: https://github.com/owncloud/web/compare/v3.3.1...v3.4.0

Summary
-------

* Bugfix - Batch action for deleting adhering permissions: [#5441](https://github.com/owncloud/web/pull/5441)
* Enhancement - Add page size view option: [#5470](https://github.com/owncloud/web/pull/5470)
* Enhancement - Add view options: [#5408](https://github.com/owncloud/web/pull/5408)
* Enhancement - Details in Sharing Sidebar: [#5161](https://github.com/owncloud/web/issues/5161)
* Enhancement - Feedback link: [#5468](https://github.com/owncloud/web/pull/5468)
* Enhancement - Content Security Policy for known iframe integrations: [#5420](https://github.com/owncloud/web/pull/5420)
* Enhancement - Batch actions for accepting and declining shares: [#5204](https://github.com/owncloud/web/issues/5204)
* Enhancement - Update Design System to 8.0.0: [#5465](https://github.com/owncloud/web/pull/5465)

Details
-------

* Bugfix - Batch action for deleting adhering permissions: [#5441](https://github.com/owncloud/web/pull/5441)

   We fixed that the batch actions for deleting files and folders was showing for shares that only
   have viewer permissions.

   https://github.com/owncloud/web/pull/5441

* Enhancement - Add page size view option: [#5470](https://github.com/owncloud/web/pull/5470)

   We've added a new item into the view options which can be used to set the number of items displayed
   per page. This value is persisted in the local storage so that the user doesn't have to update it
   every time he visits the app.

   https://github.com/owncloud/web/pull/5470

* Enhancement - Add view options: [#5408](https://github.com/owncloud/web/pull/5408)

   We've added view options above the files lists so that the user can customise them. Currently,
   it is possible to toggle visibility of hidden files. Changes in view options are persisted in
   local storage.

   https://github.com/owncloud/web/pull/5408
   https://github.com/owncloud/web/pull/5450

* Enhancement - Details in Sharing Sidebar: [#5161](https://github.com/owncloud/web/issues/5161)

   We're now displaying more information about the highlighted file in the sharing sidebar,
   including a preview (if applicable) as well as sharing and version information in one place.

   https://github.com/owncloud/web/issues/5161
   https://github.com/owncloud/web/pull/5284
   https://github.com/owncloud/web/pull/5483

* Enhancement - Feedback link: [#5468](https://github.com/owncloud/web/pull/5468)

   We've added a feedback link in the topbar which opens a survey in a new tab. The intention is to
   gather feedback from users. There is a config option to disable the link (see docs "getting
   started").

   https://github.com/owncloud/web/pull/5468

* Enhancement - Content Security Policy for known iframe integrations: [#5420](https://github.com/owncloud/web/pull/5420)

   We added CSP rules for allowing iframe integrations of the onlyoffice and richdocuments
   documentservers.

   https://github.com/owncloud/web/pull/5420

* Enhancement - Batch actions for accepting and declining shares: [#5204](https://github.com/owncloud/web/issues/5204)

   We've added batch actions for accepting and declining multiple selected incoming shares at
   once.

   https://github.com/owncloud/web/issues/5204
   https://github.com/owncloud/web/issues/2513
   https://github.com/owncloud/web/issues/3101
   https://github.com/owncloud/web/issues/5435
   https://github.com/owncloud/web/pull/5374

* Enhancement - Update Design System to 8.0.0: [#5465](https://github.com/owncloud/web/pull/5465)

   The ownCloud design system has been updated to its latest version.

   https://github.com/owncloud/web/pull/5465
   https://github.com/owncloud/web/pull/5483
   https://github.com/owncloud/web/pull/5408
   https://github.com/owncloud/owncloud-design-system/releases/tag/v8.0.0
   https://github.com/owncloud/owncloud-design-system/releases/tag/v7.5.0

Changelog for ownCloud Web [3.3.1] (2021-06-28)
=======================================
The following sections list the changes in ownCloud web 3.3.1 relevant to
ownCloud admins and users.

[3.3.1]: https://github.com/owncloud/web/compare/v3.3.0...v3.3.1

Summary
-------

* Bugfix - Image-source directive did not handle updates correctly: [#5364](https://github.com/owncloud/web/pull/5364)

Details
-------

* Bugfix - Image-source directive did not handle updates correctly: [#5364](https://github.com/owncloud/web/pull/5364)

   When using v-image-source to bind an image source it did not handle changes to the image source
   url.

   This has been fixed by implementing the update hook in the directive.

   https://github.com/owncloud/web/pull/5364

Changelog for ownCloud Web [3.3.0] (2021-06-23)
=======================================
The following sections list the changes in ownCloud web 3.3.0 relevant to
ownCloud admins and users.

[3.3.0]: https://github.com/owncloud/web/compare/v3.2.0...v3.3.0

Summary
-------

* Bugfix - Avoid duplicate loading of resources: [#5194](https://github.com/owncloud/web/pull/5194)
* Bugfix - Center MediaViewer loading spinner: [#5270](https://github.com/owncloud/web/pull/5270)
* Bugfix - Keyboard navigation for copy to clipboard: [#5147](https://github.com/owncloud/web/pull/5147)
* Bugfix - Hide left sidebar navigation when switching routes: [#5025](https://github.com/owncloud/web/pull/5025)
* Bugfix - Hide "Create new public link" button: [#5126](https://github.com/owncloud/web/pull/5126)
* Bugfix - Add docs link & fix translations on error page: [#5034](https://github.com/owncloud/web/pull/5034)
* Bugfix - Make skip to main content link visible: [#5118](https://github.com/owncloud/web/pull/5118)
* Bugfix - Add index route for the OC10 integration: [#5201](https://github.com/owncloud/web/pull/5201)
* Bugfix - Reduced Thumbnail Size: [#5194](https://github.com/owncloud/web/pull/5194)
* Bugfix - Do not call Vuex create store multiple times: [#5254](https://github.com/owncloud/web/pull/5254)
* Bugfix - Prevent scrolling issues: [#5131](https://github.com/owncloud/web/pull/5131)
* Bugfix - Show `0` as used quota if a negative number is given: [#5229](https://github.com/owncloud/web/pull/5229)
* Bugfix - Resizeable html container: [#5052](https://github.com/owncloud/web/pull/5052)
* Bugfix - Translated user menu items: [#5042](https://github.com/owncloud/web/pull/5042)
* Bugfix - Prevent `fileTypeIcon` to throw a TypeError: [#5253](https://github.com/owncloud/web/pull/5253)
* Bugfix - Make sure IDs in HTML are unique: [#5028](https://github.com/owncloud/web/pull/5028)
* Bugfix - Remove unnecessary Propfind requests: [#5340](https://github.com/owncloud/web/pull/5340)
* Bugfix - Upsert resource in filestable: [#5130](https://github.com/owncloud/web/pull/5130)
* Enhancement - Improve a11y colors: [#5138](https://github.com/owncloud/web/pull/5138)
* Enhancement - Accessible status indicators: [#5182](https://github.com/owncloud/web/pull/5182)
* Enhancement - Use a proper definition list for the account settings page: [#5012](https://github.com/owncloud/web/pull/5012)
* Enhancement - Add pagination: [#5224](https://github.com/owncloud/web/pull/5224)
* Enhancement - Asynchronous loading of images: [#4973](https://github.com/owncloud/web/issues/4973)
* Enhancement - Update owncloud Design System to v7.1.2: [#5002](https://github.com/owncloud/web/pull/5002)
* Enhancement - Button appearance: [#5053](https://github.com/owncloud/web/pull/5053)
* Enhancement - Confirmation message when copying links: [#5147](https://github.com/owncloud/web/pull/5147)
* Enhancement - File editor mode: [#5226](https://github.com/owncloud/web/issues/5226)
* Enhancement - Improve accessibility for the files sidebar: [#5000](https://github.com/owncloud/web/pull/5000)
* Enhancement - Improve a11y in the files sidebar peoples & shares section: [#5034](https://github.com/owncloud/web/pull/5034)
* Enhancement - Focus breadcrumb on route change: [#5166](https://github.com/owncloud/web/pull/5166)
* Enhancement - Enable focus trap in oc-modal: [#5013](https://github.com/owncloud/web/pull/5013)
* Enhancement - Hide left sidebar if no navitems are present: [#5149](https://github.com/owncloud/web/pull/5149)
* Enhancement - Introduce image cache: [#3098](https://github.com/owncloud/web/issues/3098)
* Enhancement - Do not reset file selection when cancelling batch delete: [#5107](https://github.com/owncloud/web/pull/5107)
* Enhancement - Move breadcrumbs out of location picker heading: [#5020](https://github.com/owncloud/web/pull/5020)
* Enhancement - Move hint in the Location picker under breadcrumbs: [#5008](https://github.com/owncloud/web/pull/5008)
* Enhancement - Improve accessibility on new file menu: [#5058](https://github.com/owncloud/web/pull/5058)
* Enhancement - OcTooltip: [#5055](https://github.com/owncloud/web/pull/5055)
* Enhancement - Send focus to "Add people" btn after closing Add/Edit panels: [#5129](https://github.com/owncloud/web/pull/5129)
* Enhancement - Remove autoclose on notifications: [#5040](https://github.com/owncloud/web/pull/5040)
* Enhancement - Request cancellation: [#5163](https://github.com/owncloud/web/issues/5163)
* Enhancement - Ability to update file resource fields: [#5311](https://github.com/owncloud/web/pull/5311)
* Enhancement - Use `oc-select` for role select: [#4937](https://github.com/owncloud/web/pull/4937)
* Enhancement - Add focus trap to left sidebar: [#5027](https://github.com/owncloud/web/pull/5027)
* Enhancement - Improve accessibility on trash bin: [#5046](https://github.com/owncloud/web/pull/5046)
* Enhancement - TypeScript Support: [#5194](https://github.com/owncloud/web/pull/5194)
* Enhancement - Update ownCloud Design System to v7.4.2: [#5224](https://github.com/owncloud/web/pull/5224)
* Enhancement - Use slots in the navigation sidebar: [#5105](https://github.com/owncloud/web/pull/5105)
* Enhancement - Improve accessibility on user menu: [#5010](https://github.com/owncloud/web/pull/5010)
* Enhancement - Visibility observer: [#5194](https://github.com/owncloud/web/pull/5194)

Details
-------

* Bugfix - Avoid duplicate loading of resources: [#5194](https://github.com/owncloud/web/pull/5194)

   On the personal route, we had a redirect case where resources would be loaded twice, which now is
   fixed.

   https://github.com/owncloud/web/pull/5194

* Bugfix - Center MediaViewer loading spinner: [#5270](https://github.com/owncloud/web/pull/5270)

   The loading spinner in the media viewer app wasn't centered vertically since the wrapping
   element was to small. It has now been given a min-height of the current screen size.

   https://github.com/owncloud/web/issues/5196
   https://github.com/owncloud/web/pull/5270

* Bugfix - Keyboard navigation for copy to clipboard: [#5147](https://github.com/owncloud/web/pull/5147)

   We've fixed that the buttons for copying (private/public) links to the clipboard were not
   usable via keyboard.

   https://github.com/owncloud/web/pull/5147

* Bugfix - Hide left sidebar navigation when switching routes: [#5025](https://github.com/owncloud/web/pull/5025)

   On smaller screens, the left sidebar containing the extension navigation is collapsed. We've
   fixed that when the user expanded the sidebar and navigated to a different route the sidebar is
   collapsed again.

   https://github.com/owncloud/web/pull/5025

* Bugfix - Hide "Create new public link" button: [#5126](https://github.com/owncloud/web/pull/5126)

   The button to create new public links was visible even if the user lacked the permissions to
   create one. It is now being hidden unless the user is allowed to create a share of the respective
   file.

   https://github.com/owncloud/web/pull/5126

* Bugfix - Add docs link & fix translations on error page: [#5034](https://github.com/owncloud/web/pull/5034)

   The MissingConfigPage had a translated paragraph that didn't work because of an presumably
   unallowed `<br/>` tag inside the text.

   Also, the link to the GitHub repo was replace with a link to the web docs and public rocket chat.

   https://github.com/owncloud/web/pull/5034

* Bugfix - Make skip to main content link visible: [#5118](https://github.com/owncloud/web/pull/5118)

   We've fixed the z-index of the skip to main content link so that it is not hidden under different
   content anymore and is again visible on focus, with a visible focus border.

   https://github.com/owncloud/web/pull/5118
   https://github.com/owncloud/web/pull/5167

* Bugfix - Add index route for the OC10 integration: [#5201](https://github.com/owncloud/web/pull/5201)

   Added an index route for the OC10 integration which gets called when opening
   http://your-server/index.php/apps/web. The route basically redirects to the same URL
   while appending /index.html, as this is the correct URL for accessing the Web UI. Setting Web as
   default layout would result in an endless redirect loop otherwise.

   https://github.com/owncloud/core/issues/38799
   https://github.com/owncloud/web/pull/5201

* Bugfix - Reduced Thumbnail Size: [#5194](https://github.com/owncloud/web/pull/5194)

   We have greatly reduced the size of the images we request from the backend to display as
   thumbnail previews in order to minimize loading times.

   https://github.com/owncloud/web/pull/5194

* Bugfix - Do not call Vuex create store multiple times: [#5254](https://github.com/owncloud/web/pull/5254)

   We've moved the create Vuex store logic into the index file of Web runtime to prevent
   initialising the store multiple times.

   https://github.com/owncloud/web/pull/5254

* Bugfix - Prevent scrolling issues: [#5131](https://github.com/owncloud/web/pull/5131)

   In cases where the browser-window space was not enough to render all views the ui ended up with
   weird scrolling behavior.

   This has been fixed by restructuring the dom elements and giving them proper styles.

   https://github.com/owncloud/web/pull/5131

* Bugfix - Show `0` as used quota if a negative number is given: [#5229](https://github.com/owncloud/web/pull/5229)

   In the case if the server returns a negative number as used quota (what should not happen) show `0
   B of 2 GB` and not only of ` 2 GB`

   https://github.com/owncloud/web/pull/5229

* Bugfix - Resizeable html container: [#5052](https://github.com/owncloud/web/pull/5052)

   We removed a critical accessibility offense by removing the hardcoded maximum-scale and
   allowing for user-scalable viewsizes.

   https://github.com/owncloud/web/pull/5052

* Bugfix - Translated user menu items: [#5042](https://github.com/owncloud/web/pull/5042)

   Some of the user menu items were not correctly translated, which is now fixed.

   https://github.com/owncloud/web/pull/5042

* Bugfix - Prevent `fileTypeIcon` to throw a TypeError: [#5253](https://github.com/owncloud/web/pull/5253)

   The function would die with `TypeError: file.extension.toLowerCase is not a function` if
   `file.extension` was set to something that is not a string.

   https://github.com/owncloud/web/pull/5253

* Bugfix - Make sure IDs in HTML are unique: [#5028](https://github.com/owncloud/web/pull/5028)

   Quick action button IDs were repeated in every row of the file table, which isn't allowed in HTML
   (IDs must be unique per document). By changing to classes, this offense was resolved.

   The same goes for IDs in the people shares part of the sidebar where IDs are now appended with the
   share ID, which is necessary since they need to be both unique and referenced by ID for
   accessibility reasons.

   https://github.com/owncloud/web/pull/5028
   https://github.com/owncloud/web/pull/5148

* Bugfix - Remove unnecessary Propfind requests: [#5340](https://github.com/owncloud/web/pull/5340)

   In the the files-app views `Favorites`, `SharedViaLink`, `SharedWithMe` and
   `SharedWithOthers` we did a unnecessary propfind request to obtain the rootFolder which is
   not required there.

   This has been fixed by removing those requests.

   https://github.com/owncloud/web/pull/5340

* Bugfix - Upsert resource in filestable: [#5130](https://github.com/owncloud/web/pull/5130)

   When uploading an already existing resource in the filestable, we sometimes displayed both
   files in the filestable until the page got refreshed. We now check when uploading a file if it
   exists in the filestable and replace it there if that is the case.

   https://github.com/owncloud/web/pull/5130

* Enhancement - Improve a11y colors: [#5138](https://github.com/owncloud/web/pull/5138)

   To get a11y compliant it's required that colors match a given contrast ratio to it's
   back-/fore-/ground. We improved this on:

   - all ODS components - all oc-color variables - oc-star in sidebar

   https://github.com/owncloud/web/pull/5138

* Enhancement - Accessible status indicators: [#5182](https://github.com/owncloud/web/pull/5182)

   To make both the clickable (button) and the visible (icon) part of the status indicators in the
   files table accessible, we have added a description, in addition to the tooltip and
   `aria-label`.

   https://github.com/owncloud/web/pull/5182

* Enhancement - Use a proper definition list for the account settings page: [#5012](https://github.com/owncloud/web/pull/5012)

   https://github.com/owncloud/web/pull/5012

* Enhancement - Add pagination: [#5224](https://github.com/owncloud/web/pull/5224)

   We've added pagination to all files lists. Current limit for displayed resources is 100.

   https://github.com/owncloud/web/pull/5224
   https://github.com/owncloud/web/pull/5309

* Enhancement - Asynchronous loading of images: [#4973](https://github.com/owncloud/web/issues/4973)

   Thumbnail and avatar images now get loaded in the background and don't block the main rendering
   of the user interface.

   https://github.com/owncloud/web/issues/4973
   https://github.com/owncloud/web/pull/5194

* Enhancement - Update owncloud Design System to v7.1.2: [#5002](https://github.com/owncloud/web/pull/5002)

   - Lots of updates regarding accessibility topics - Removal of home icon in breadcrumbs,
   changed to "All files" link as breadcrumb root - Added aria-labels to all landmarks in sidebar
   and proper logo-alt attribute to image in sidebar

   https://github.com/owncloud/web/pull/5002
   https://github.com/owncloud/web/pull/5044
   https://github.com/owncloud/web/pull/5074
   https://github.com/owncloud/web/pull/5186
   https://github.com/owncloud/web/pull/5189

* Enhancement - Button appearance: [#5053](https://github.com/owncloud/web/pull/5053)

   Changed the appearance of the "accept/decline share" buttons in the "Shared With Me" file list
   so they actually look like buttons.

   Also changed the "Clear selection" button in the files table batch actions from `raw` to
   `outline` appearance.

   https://github.com/owncloud/web/pull/5053
   https://github.com/owncloud/web/pull/5148

* Enhancement - Confirmation message when copying links: [#5147](https://github.com/owncloud/web/pull/5147)

   We've added confirmation messages (toasts) when a private or public link is copied to the
   clipboard.

   https://github.com/owncloud/web/pull/5147

* Enhancement - File editor mode: [#5226](https://github.com/owncloud/web/issues/5226)

   We've added a parameter called `mode` to the different ways of opening a file editor. The mode
   can be `edit` or `create` and reflects whether the file editor was opened in an editing mode or in
   a creation mode.

   https://github.com/owncloud/web/issues/5226
   https://github.com/owncloud/web/pull/5256

* Enhancement - Improve accessibility for the files sidebar: [#5000](https://github.com/owncloud/web/pull/5000)

   We've did several improvements to enhance the accessibility on the files sidebar: -
   Transformed the file name to a h2 element - Transformed the "Open folder"-action to a link
   instead of a button - Transformed the favorite-star to a button-element - Adjusted aria-label
   of the favorite-star to describe what it does instead of its current state - Added a more
   descriptive close button label - Clicking outside of the sidebar now closes it - Removed the
   aria-label on the action buttons as they already include proper labels - Added a hint for screen
   readers if an action opens a new window/tab - Make sidebar header sticky

   https://github.com/owncloud/web/pull/5000
   https://github.com/owncloud/web/pull/5266

* Enhancement - Improve a11y in the files sidebar peoples & shares section: [#5034](https://github.com/owncloud/web/pull/5034)

   We've did several improvements to enhance the accessibility on the files sidebar: - Gave
   `role="presentation" to the collaborator avatar - Refactored `<span>` and `<div>` tags into
   `<p>` tags and unified translations a bit - Enhanced hints in the collaborator quick action
   buttons with collaborator name - Hide private links if the capability is not enabled - Set
   avatar-images to `:aria-hidden="true"` since they're only visual elements and can be hidden
   from screenreaders - Changed `<section>` wrapper around private link shares - Removed
   `<section>` wrapper around public link shares - Removed `<section>` wrapper around
   collaborators - Added screenreader-only explain texts regarding collaborator/share
   ownership - Added aria-label for share receiver section - Worked on unifying the way we handle
   translations: Focus on v-translate and $gettext() - Turn tags into `<ul> & <li>` list, add
   aria-labelledby to both tag list and resharer tag list - Translated "Open with $appName" for
   sidebar quick actions

   https://github.com/owncloud/web/pull/5034
   https://github.com/owncloud/web/pull/5043
   https://github.com/owncloud/web/pull/5121

* Enhancement - Focus breadcrumb on route change: [#5166](https://github.com/owncloud/web/pull/5166)

   We now focus the current breadcrumb item when navigating to another page and announce the
   amount of files and folders in the folder the user has navigated to.

   https://github.com/owncloud/web/pull/5166

* Enhancement - Enable focus trap in oc-modal: [#5013](https://github.com/owncloud/web/pull/5013)

   After the recent changes in ODS, the oc-modal can now use a focus-trap which is a feature needed
   for accessibility-reasons.

   https://github.com/owncloud/web/pull/5013

* Enhancement - Hide left sidebar if no navitems are present: [#5149](https://github.com/owncloud/web/pull/5149)

   For extensions / pages without nav items and public link pages, we now hide the left sidebar to
   not confuse screen readers and give more screen space for the content.

   https://github.com/owncloud/web/pull/5149

* Enhancement - Introduce image cache: [#3098](https://github.com/owncloud/web/issues/3098)

   We have added a (configurable) cache for thumbnails and avatar images to avoid loading the same
   files over and over again.

   https://github.com/owncloud/web/issues/3098
   https://github.com/owncloud/web/pull/5194

* Enhancement - Do not reset file selection when cancelling batch delete: [#5107](https://github.com/owncloud/web/pull/5107)

   We've removed the reset selection method call when cancelling batch delete. If the user now
   cancels the delete dialog, the file selection stays as it was before displaying the dialog.

   https://github.com/owncloud/web/pull/5107

* Enhancement - Move breadcrumbs out of location picker heading: [#5020](https://github.com/owncloud/web/pull/5020)

   We've moved the breadcrumbs element out of the location picker heading and moved it under it.
   The heading is now also reflecting the page title. We've also decreased the size of both
   breadcrumbs and action buttons so that they fit better together.

   https://github.com/owncloud/web/pull/5020

* Enhancement - Move hint in the Location picker under breadcrumbs: [#5008](https://github.com/owncloud/web/pull/5008)

   We've moved the hint that is describing how to use the Location picker from sidebar under the
   breadcrumbs. There is navigation of the Files extension displayed in the sidebar now instead.

   https://github.com/owncloud/web/pull/5008

* Enhancement - Improve accessibility on new file menu: [#5058](https://github.com/owncloud/web/pull/5058)

   We now use buttons instead of a-tags in the new file menu. Also fixed the double-focus per item
   when navigating via tab.

   https://github.com/owncloud/web/pull/5058

* Enhancement - OcTooltip: [#5055](https://github.com/owncloud/web/pull/5055)

   We've changed the tooltip implementation to use oc-tooltip directive from ODS instead of
   uikit's.

   https://github.com/owncloud/web/issues/4654
   https://github.com/owncloud/web/issues/2623
   https://github.com/owncloud/web/issues/4597
   https://github.com/owncloud/web/issues/4332
   https://github.com/owncloud/web/issues/4300
   https://github.com/owncloud/web/issues/5155
   https://github.com/owncloud/web/pull/5055

* Enhancement - Send focus to "Add people" btn after closing Add/Edit panels: [#5129](https://github.com/owncloud/web/pull/5129)

   We've started sending the focus to "Add people" button after the `Add` panel in the people
   accordion has been closed. Also, when editing a share the focus jumps back to the "Edit" button
   in the respective share after cancelling or confirming the action.

   https://github.com/owncloud/web/pull/5129
   https://github.com/owncloud/web/pull/5146

* Enhancement - Remove autoclose on notifications: [#5040](https://github.com/owncloud/web/pull/5040)

   The autoclose is now being handled in the design system component. The timeout can be set via
   property.

   https://github.com/owncloud/web/pull/5040

* Enhancement - Request cancellation: [#5163](https://github.com/owncloud/web/issues/5163)

   Requests (e.g. loading of images) can now be pragmatically cancelled from the client side.
   Before, obsolete requests would still create load on the server and return results that then
   would be discarded by the web frontend.

   https://github.com/owncloud/web/issues/5163
   https://github.com/owncloud/web/pull/5194

* Enhancement - Ability to update file resource fields: [#5311](https://github.com/owncloud/web/pull/5311)

   We've introduced the ability to update individual resource fields only instead of updating
   the whole resource at once.

   https://github.com/owncloud/web/pull/5311

* Enhancement - Use `oc-select` for role select: [#4937](https://github.com/owncloud/web/pull/4937)

   We've used the new `oc-select` component from ODS for selecting role in people and public links
   accordions in the right sidebar. We are using this component to enable keyboard navigation
   when selecting the role.

   https://github.com/owncloud/web/pull/4937

* Enhancement - Add focus trap to left sidebar: [#5027](https://github.com/owncloud/web/pull/5027)

   We've added a focus trap to the left sidebar on smaller resolutions when it's collapsible. If
   the sidebar is opened and focused, the focus stays within the sidebar.

   https://github.com/owncloud/web/pull/5027

* Enhancement - Improve accessibility on trash bin: [#5046](https://github.com/owncloud/web/pull/5046)

   Add more context to the empty trash bin button text and only render it, if resources are present.

   https://github.com/owncloud/web/pull/5046

* Enhancement - TypeScript Support: [#5194](https://github.com/owncloud/web/pull/5194)

   We have added support for TypeScript and started to refactor parts of the codebase. This will
   help us provide clearer interfaces and catch bugs earlier.

   https://github.com/owncloud/web/pull/5194

* Enhancement - Update ownCloud Design System to v7.4.2: [#5224](https://github.com/owncloud/web/pull/5224)

   We've updated ownCloud Design System to version 7.4.2 to bring the new pagination component.

   https://github.com/owncloud/web/pull/5224
   https://github.com/owncloud/web/pull/5292
   https://github.com/owncloud/web/pull/5319
   https://github.com/owncloud/owncloud-design-system/releases/tag/v7.4.1
   https://github.com/owncloud/owncloud-design-system/releases/tag/v7.4.2

* Enhancement - Use slots in the navigation sidebar: [#5105](https://github.com/owncloud/web/pull/5105)

   In the new sidebar content is defined solely via slots. We've moved all the content into those
   slots so that the sidebar still gets displayed correctly.

   https://github.com/owncloud/web/pull/5105

* Enhancement - Improve accessibility on user menu: [#5010](https://github.com/owncloud/web/pull/5010)

   Wrapped the user menu button in a nav element and added an aria-label which describes it as main
   navigation.

   https://github.com/owncloud/web/pull/5010

* Enhancement - Visibility observer: [#5194](https://github.com/owncloud/web/pull/5194)

   By adding a visibility observer, we now only load image previews for those files that are close
   to the user's viewport. It is also equipped with a short waiting period so scrolling doesn't
   lead to an overload of requests.

   https://github.com/owncloud/web/pull/5194

Changelog for ownCloud Web [3.2.0] (2021-05-31)
=======================================
The following sections list the changes in ownCloud web 3.2.0 relevant to
ownCloud admins and users.

[3.2.0]: https://github.com/owncloud/web/compare/v3.1.0...v3.2.0

Summary
-------

* Bugfix - Correct navigation through "via"-tags: [#5122](https://github.com/owncloud/web/pull/5122)
* Bugfix - Correct sharee tag: [#5112](https://github.com/owncloud/web/pull/5112)
* Enhancement - Confirmation for public link deletion: [#5125](https://github.com/owncloud/web/pull/5125)
* Enhancement - Continuously deployed demo instance with latest Web: [#5145](https://github.com/owncloud/web/pull/5145)
* Enhancement - Configure previews: [#5159](https://github.com/owncloud/web/pull/5159)
* Enhancement - Prompts leaving user about pending uploads: [#2590](https://github.com/owncloud/web/issues/2590)

Details
-------

* Bugfix - Correct navigation through "via"-tags: [#5122](https://github.com/owncloud/web/pull/5122)

   The "shared via X" link in the indirect share tag in the sidebar was navigating to the parent
   directory of the indirect share entry. This has been fixed for the collaborators sidebar
   section and the link target is the share entry itself now.

   https://github.com/owncloud/web/pull/5122

* Bugfix - Correct sharee tag: [#5112](https://github.com/owncloud/web/pull/5112)

   The tag _inside_ a shared folder always announced the current user as "owner", since the shares
   lookup didn't check for the parent folders' ownership. This has been fixed now and users get the
   correct tag (e.g. "Viewer", "Editor" etc) in the sidebar.

   https://github.com/owncloud/web/pull/5112

* Enhancement - Confirmation for public link deletion: [#5125](https://github.com/owncloud/web/pull/5125)

   The deletion of public links is an irreversible interaction and should be handled with more
   care since users might have bookmarked or shared with other people. We have added a
   confirmation modal now to prevent users from accidentally deleting public links.

   https://github.com/owncloud/web/pull/5125

* Enhancement - Continuously deployed demo instance with latest Web: [#5145](https://github.com/owncloud/web/pull/5145)

   Whenever a commit or merge to master happens, a demo instance with the latest Web build will be
   deployed.

   https://github.com/owncloud/web/pull/5145

* Enhancement - Configure previews: [#5159](https://github.com/owncloud/web/pull/5159)

   We introduced a new config option to configure which file will be previewed. To do so, add
   `"options.previewFileExtensions": ["jpg", "txt"]` in the config.json file.

   https://github.com/owncloud/web/issues/5079
   https://github.com/owncloud/web/pull/5159

* Enhancement - Prompts leaving user about pending uploads: [#2590](https://github.com/owncloud/web/issues/2590)

   Added an unload event listener that detects closes/ reloads/ navigates to another URL. Added
   prompt that ask for confirmation to leave site on unload events if uploads pending. Removed the
   event listener before destroy of component.

   https://github.com/owncloud/web/issues/2590
   https://github.com/owncloud/web/pull/4840

Changelog for ownCloud Web [3.1.0] (2021-05-12)
=======================================
The following sections list the changes in ownCloud web 3.1.0 relevant to
ownCloud admins and users.

[3.1.0]: https://github.com/owncloud/web/compare/v3.0.0...v3.1.0

Summary
-------

* Bugfix - Editors for all routes: [#5095](https://github.com/owncloud/web/pull/5095)
* Bugfix - Improve web container: [#4942](https://github.com/owncloud/web/pull/4942)
* Bugfix - Display navigation for resolved private link: [#5023](https://github.com/owncloud/web/pull/5023)
* Bugfix - Fix z-index on the new file menu: [#5056](https://github.com/owncloud/web/pull/5056)
* Enhancement - Accessibility improvements: [#4965](https://github.com/owncloud/web/pull/4965)
* Enhancement - Implement proper direct delete: [#4991](https://github.com/owncloud/web/pull/4991)
* Enhancement - Enable files app search bar to be toggleable on a per-route basis: [#4815](https://github.com/owncloud/web/pull/4815)
* Enhancement - Extension config: [#5024](https://github.com/owncloud/web/pull/5024)
* Enhancement - Focus management: [#4993](https://github.com/owncloud/web/pull/4993)
* Enhancement - Align headline hierarchy: [#5003](https://github.com/owncloud/web/issues/5003)
* Enhancement - Lazy file avatar loading: [#5073](https://github.com/owncloud/web/pull/5073)
* Enhancement - Use list for displaying added people: [#4915](https://github.com/owncloud/web/pull/4915)
* Enhancement - Use real page title for location picker: [#5009](https://github.com/owncloud/web/pull/5009)
* Enhancement - Show search button in search bar: [#4985](https://github.com/owncloud/web/pull/4985)

Details
-------

* Bugfix - Editors for all routes: [#5095](https://github.com/owncloud/web/pull/5095)

   If an extension doesn't define valid routes it should be allowed for all routes by default. That
   behaviour was not working properly and is fixed now.

   https://github.com/owncloud/web/pull/5095

* Bugfix - Improve web container: [#4942](https://github.com/owncloud/web/pull/4942)

   The wrapping `index.html.ejs` had some minor problems with HTML validators which are now
   fixed.

   https://github.com/owncloud/web/pull/4942

* Bugfix - Display navigation for resolved private link: [#5023](https://github.com/owncloud/web/pull/5023)

   We've fixed that the navigation in the left sidebar is visible for a resolved private link as
   well

   https://github.com/owncloud/web/pull/5023

* Bugfix - Fix z-index on the new file menu: [#5056](https://github.com/owncloud/web/pull/5056)

   Added a z-index to files-view because it prevented the new file menu from having a higher
   z-index than the table headers. As a result the new file menu was being overlapped by them.

   https://github.com/owncloud/web/pull/5056

* Enhancement - Accessibility improvements: [#4965](https://github.com/owncloud/web/pull/4965)

   A lot of random changes: - Extracted some helper classes to ODS & unified their usage - Removed
   `<br>` tags that were incorrectly used for spacing - Used `<h4>` tags for headings in the files
   sidebar - Make skip-to-main button translate-able - Update searchbar label string - Renamed
   "personal files" to "all files" in routes (soft rename, due to changes in the future) - Updated
   ODS to v6.0.3, making row heights theme-able and bringing a more accessible avatar component
   that improves loading of users' profile pictures - Translate quick action labels/tooltips
   properly - Added a note about actions being available above the file list to the live region
   update for selection

   https://github.com/owncloud/web/pull/4965
   https://github.com/owncloud/web/pull/4975
   https://github.com/owncloud/web/pull/5030
   https://github.com/owncloud/web/pull/5088

* Enhancement - Implement proper direct delete: [#4991](https://github.com/owncloud/web/pull/4991)

   We implemented a proper delete action for a single file instead of reusing the batch action for
   deleting multiple files. This also solves the issue with the checkbox being checked when
   opening the delete modal, which was not a11y compliant.

   https://github.com/owncloud/web/pull/4991

* Enhancement - Enable files app search bar to be toggleable on a per-route basis: [#4815](https://github.com/owncloud/web/pull/4815)

   Permits the search bar in the files app to be toggleable on a per-route basis as shown or hidden.

   https://github.com/owncloud/web/pull/4815

* Enhancement - Extension config: [#5024](https://github.com/owncloud/web/pull/5024)

   Loading extension specific config was only possible for file editors. We now also load it in the
   general app information, so that it's available in the `apps` getter of the global vuex store.

   https://github.com/owncloud/web/pull/5024

* Enhancement - Focus management: [#4993](https://github.com/owncloud/web/pull/4993)

   We added a mixin that makes it able to manage, record and reverse-replay the focus for the
   current document. The first components that using it are modal and sidebar in the files app.

   https://github.com/owncloud/web/issues/4992
   https://github.com/owncloud/web/pull/4993

* Enhancement - Align headline hierarchy: [#5003](https://github.com/owncloud/web/issues/5003)

   Streamlined headline tags so that pages have a h1 tag and the headline hierarchy is adhered.

   https://github.com/owncloud/web/issues/5003
   https://github.com/owncloud/web/pull/5004
   https://github.com/owncloud/web/pull/5005

* Enhancement - Lazy file avatar loading: [#5073](https://github.com/owncloud/web/pull/5073)

   We've changed the way how large file lists get rendered. In some cases where we had a long list of
   files, the loading of avatars could lead to long waiting times till the first paint happens.

   Now we first render the list of files, load the associated avatars in the background and then
   update the ui.

   https://github.com/owncloud/web/issues/4973
   https://github.com/owncloud/web/pull/5073

* Enhancement - Use list for displaying added people: [#4915](https://github.com/owncloud/web/pull/4915)

   We've changed the HTML elements in the people accordion when adding new people. People added
   via people autocomplete are now displayed in a list element to use correct structure for screen
   readers.

   https://github.com/owncloud/web/pull/4915

* Enhancement - Use real page title for location picker: [#5009](https://github.com/owncloud/web/pull/5009)

   We've added real page titles to the location picker. The title is consisted of the current
   action, target and product name.

   https://github.com/owncloud/web/pull/5009

* Enhancement - Show search button in search bar: [#4985](https://github.com/owncloud/web/pull/4985)

   https://github.com/owncloud/web/pull/4985

Changelog for ownCloud Web [3.0.0] (2021-04-21)
=======================================
The following sections list the changes in ownCloud web 3.0.0 relevant to
ownCloud admins and users.

[3.0.0]: https://github.com/owncloud/web/compare/v2.1.0...v3.0.0

Summary
-------

* Bugfix - Avatar url without double slash: [#4610](https://github.com/owncloud/web/issues/4610)
* Bugfix - Open mediaviewer for upper case file extensions: [#4647](https://github.com/owncloud/web/issues/4647)
* Bugfix - Only one `<main>` tag per HTML document: [#1652](https://github.com/owncloud/web/issues/1652)
* Bugfix - Parent paths traversal for shares: [#4860](https://github.com/owncloud/web/issues/4860)
* Change - Update owncloud Design System to v6.0.1: [#4940](https://github.com/owncloud/web/pull/4940)
* Change - New files list: [#4627](https://github.com/owncloud/web/pull/4627)
* Enhancement - A11y improvements for files app bar: [#4786](https://github.com/owncloud/web/issues/4786)
* Enhancement - Enable files app search bar to be toggleable on a per-route basis: [#4815](https://github.com/owncloud/web/pull/4815)
* Enhancement - Add web-pkg package: [#4907](https://github.com/owncloud/web/pull/4907)
* Enhancement - Implement live region updates on route changes: [#4812](https://github.com/owncloud/web/pull/4812)
* Enhancement - Use list for displaying added people: [#4915](https://github.com/owncloud/web/pull/4915)
* Enhancement - Runtime theming: [#4822](https://github.com/owncloud/web/pull/4822)
* Enhancement - Add "Shared via link" page: [#4881](https://github.com/owncloud/web/pull/4881)
* Enhancement - Use ODS translations: [#4934](https://github.com/owncloud/web/pull/4934)

Details
-------

* Bugfix - Avatar url without double slash: [#4610](https://github.com/owncloud/web/issues/4610)

   The avatar url added another superfluous slash after the instance url which resulted in the
   avatar not being able to load.

   https://github.com/owncloud/web/issues/4610
   https://github.com/owncloud/web/pull/4849

* Bugfix - Open mediaviewer for upper case file extensions: [#4647](https://github.com/owncloud/web/issues/4647)

   We fixed a bug where the mediaviewer didn't open for files which had an uppercase (or mixed case)
   file extension.

   https://github.com/owncloud/web/issues/4647
   https://github.com/owncloud/web/pull/4627

* Bugfix - Only one `<main>` tag per HTML document: [#1652](https://github.com/owncloud/web/issues/1652)

   Only one `<main>` tag is allowed per HTML document. This change removes the ones in
   `web-container` and `web-runtime` and adds one to each extension (files-list, mediaviewer,
   markdowneditor, drawio) since they can't be loaded at the same time.

   https://github.com/owncloud/web/issues/1652
   https://github.com/owncloud/web/pull/4627

* Bugfix - Parent paths traversal for shares: [#4860](https://github.com/owncloud/web/issues/4860)

   We fixed a bug in parent paths traversals for loading shares. A path with a trailing slash was
   twice in the result of (parent-)paths, leading to fetching the existing shares on the current
   folder twice. Since we fetch incoming and outgoing shares this caused 2 unnecessary requests
   on every page load that changed into a child folder or a folder unrelated to the current path.

   https://github.com/owncloud/web/issues/4860
   https://github.com/owncloud/web/pull/4918

* Change - Update owncloud Design System to v6.0.1: [#4940](https://github.com/owncloud/web/pull/4940)

   - Lots of updates regarding accessibility topics, an updated color palette and custom CSS
   properties to allow for (runtime) theming. - ODS started to use peerDependencies now, we
   adopted this and added the required packages

   https://github.com/owncloud/web/issues/4331
   https://github.com/owncloud/web/pull/4940
   https://github.com/owncloud/web/pull/4925
   https://github.com/owncloud/web/pull/4862
   https://github.com/owncloud/web/pull/4983

* Change - New files list: [#4627](https://github.com/owncloud/web/pull/4627)

   We integrated the new oc-table-files component from our design system. This includes
   breaking changes in how we load resources in our files app. We refactored our files app codebase
   into views, so that only subcomponents live in the components directory.

   https://github.com/owncloud/web/pull/4627

* Enhancement - A11y improvements for files app bar: [#4786](https://github.com/owncloud/web/issues/4786)

   If we select resources in the files list, an action context menu appears, to improve a11y we need
   an aria live region element to announce that.

   https://github.com/owncloud/web/issues/4786
   https://github.com/owncloud/web/pull/4833

* Enhancement - Enable files app search bar to be toggleable on a per-route basis: [#4815](https://github.com/owncloud/web/pull/4815)

   Permits the search bar in the files app to be toggleable on a per-route basis as shown or hidden.

   https://github.com/owncloud/web/pull/4815

* Enhancement - Add web-pkg package: [#4907](https://github.com/owncloud/web/pull/4907)

   We added web-pkg as a new package. It is supposed to be the central location for reuse of generic
   functionality.

   https://github.com/owncloud/web/pull/4907

* Enhancement - Implement live region updates on route changes: [#4812](https://github.com/owncloud/web/pull/4812)

   https://github.com/owncloud/web/issues/4346
   https://github.com/owncloud/web/pull/4812

* Enhancement - Use list for displaying added people: [#4915](https://github.com/owncloud/web/pull/4915)

   We've changed the HTML elements in the people accordion when adding new people. People added
   via people autocomplete are now displayed in a list element to use correct structure for screen
   readers.

   https://github.com/owncloud/web/pull/4915

* Enhancement - Runtime theming: [#4822](https://github.com/owncloud/web/pull/4822)

   It's now possible to specify a custom theme and have logos, brand slogan and colors changed to
   modify the appearance of your ownCloud web frontend.

   https://github.com/owncloud/web/issues/2362
   https://github.com/owncloud/web/pull/4822

* Enhancement - Add "Shared via link" page: [#4881](https://github.com/owncloud/web/pull/4881)

   We've added a new page called "Shared via link". This page displays a files list containing only
   resources shared via public links.

   https://github.com/owncloud/web/pull/4881

* Enhancement - Use ODS translations: [#4934](https://github.com/owncloud/web/pull/4934)

   Some ODS components were using their own translation strings which were available in the ODS
   but not exported there/imported in the web project. Now, we import the translation strings
   from the ODS package and merge them with the web translations.

   https://github.com/owncloud/web/pull/4934

Changelog for ownCloud Web [2.1.0] (2021-03-24)
=======================================
The following sections list the changes in ownCloud web 2.1.0 relevant to
ownCloud admins and users.

[2.1.0]: https://github.com/owncloud/web/compare/v2.0.2...v2.1.0

Summary
-------

* Bugfix - Fix missing translations in application menu: [#4830](https://github.com/owncloud/web/pull/4830)
* Bugfix - NODE_ENV based on rollup mode: [#4819](https://github.com/owncloud/web/issues/4819)
* Bugfix - Remove unsupported shareType: [#4809](https://github.com/owncloud/web/pull/4809)
* Enhancement - A11y improvements for meta attributes: [#4342](https://github.com/owncloud/web/issues/4342)
* Enhancement - Set locale on moment-js to render translated strings: [#4826](https://github.com/owncloud/web/pull/4826)
* Enhancement - Use pre-signed url download for password protected shares: [#38376](https://github.com/owncloud/core/pull/38376)

Details
-------

* Bugfix - Fix missing translations in application menu: [#4830](https://github.com/owncloud/web/pull/4830)

   https://github.com/owncloud/web/pull/4830

* Bugfix - NODE_ENV based on rollup mode: [#4819](https://github.com/owncloud/web/issues/4819)

   The NODE_ENV was set to production by default, now we use development if rollup is started in
   watch mode so that the vue devtools can be used.

   https://github.com/owncloud/web/issues/4819
   https://github.com/owncloud/web/pull/4820

* Bugfix - Remove unsupported shareType: [#4809](https://github.com/owncloud/web/pull/4809)

   We don't support 'userGroup' (originally 'contact', shareType `2`) on the backend side
   anymore, so we delete it on the frontend, too.

   https://github.com/owncloud/web/pull/4809

* Enhancement - A11y improvements for meta attributes: [#4342](https://github.com/owncloud/web/issues/4342)

   For a11y the html language attribute will be set dynamically <html lang="xx"/>. For a11y the
   title will be set automatically following the schema: sub item (e.G file) - route (e.g All
   Files) - general name (e.g ownCloud)

   https://github.com/owncloud/web/issues/4342
   https://github.com/owncloud/web/issues/4338
   https://github.com/owncloud/web/pull/4811

* Enhancement - Set locale on moment-js to render translated strings: [#4826](https://github.com/owncloud/web/pull/4826)

   For i18n purposes we set the moment-js locale to the current selected locale (language) this
   allows us to show translated string for example in the updated column in the All files list
   (web-app-files package)

   https://github.com/owncloud/web/pull/4826

* Enhancement - Use pre-signed url download for password protected shares: [#38376](https://github.com/owncloud/core/pull/38376)

   Replaced the blob download with a normal download using a pre-signed url provided by the
   backend.

   https://github.com/owncloud/core/pull/38376
   https://github.com/owncloud/web/pull/4689

Changelog for ownCloud Web [2.0.2] (2021-03-08)
=======================================
The following sections list the changes in ownCloud web 2.0.2 relevant to
ownCloud admins and users.

[2.0.2]: https://github.com/owncloud/web/compare/v2.0.1...v2.0.2

Summary
-------

* Change - Suppress redirect error during authorization: [#4759](https://github.com/owncloud/web/pull/4759)

Details
-------

* Change - Suppress redirect error during authorization: [#4759](https://github.com/owncloud/web/pull/4759)

   We've suppressed the error appearing in the console which warned about redirect happening
   after the oidc callback page. This error is being shown because after the oidc callback has
   successfully processed the authorization request we are redirecting to the `/` path which
   immediately does another redirect to the extension set as default one. In the context of Vue
   router, this is considered an error even though for us it is a valid use case. The error is only
   informative thus no issue is going to surface if we suppress it. This way we are getting closer to
   a clean console without errors.

   https://github.com/owncloud/web/pull/4759

Changelog for ownCloud Web [2.0.1] (2021-02-18)
=======================================
The following sections list the changes in ownCloud web 2.0.1 relevant to
ownCloud admins and users.

[2.0.1]: https://github.com/owncloud/web/compare/v2.0.0...v2.0.1

Summary
-------

* Bugfix - Fix oc10 deployment after switch to rollup: [#4757](https://github.com/owncloud/web/pull/4757)
* Bugfix - Fix showing white page with no message if the config could not be parsed: [#4636](https://github.com/owncloud/web/issues/4636)
* Bugfix - Allow search in additional share info: [#1656](https://github.com/owncloud/ocis/issues/1656)

Details
-------

* Bugfix - Fix oc10 deployment after switch to rollup: [#4757](https://github.com/owncloud/web/pull/4757)

   Our first release of the oc10 app after the switch to rollup as bundler had a bug as it didn't
   reflect the new folder structure of the app in the allowed folders. This has been fixed by
   updating the allowed folders.

   https://github.com/owncloud/web/pull/4757

* Bugfix - Fix showing white page with no message if the config could not be parsed: [#4636](https://github.com/owncloud/web/issues/4636)

   When the config file could not be parsed because of some mistake in the JSON, an empty page
   without any error message would be shown to the user. We've fixed that behavior and showing now
   an error page and details of the error in the console.

   https://github.com/owncloud/web/issues/4636
   https://github.com/owncloud/web/pull/4749

* Bugfix - Allow search in additional share info: [#1656](https://github.com/owncloud/ocis/issues/1656)

   We fixed that searching for a potential sharee didn't look at the additional share info.

   https://github.com/owncloud/ocis/issues/1656
   https://github.com/owncloud/web/pull/4753

Changelog for ownCloud Web [2.0.0] (2021-02-16)
=======================================
The following sections list the changes in ownCloud web 2.0.0 relevant to
ownCloud admins and users.

[2.0.0]: https://github.com/owncloud/web/compare/v1.0.1...v2.0.0

Summary
-------

* Change - Switch from webpack to rollup: [#4584](https://github.com/owncloud/web/pull/4584)
* Change - Update ODS to 2.1.2: [#4594](https://github.com/owncloud/web/pull/4594)

Details
-------

* Change - Switch from webpack to rollup: [#4584](https://github.com/owncloud/web/pull/4584)

   We replaced the bundler that we used so far (webpack) with rollup and reorganized the project
   structure. This hopefully makes the project structure easier to understand and thus help with
   onboarding. Another improvement is that the overall bundle size is much smaller now.

   https://github.com/owncloud/web/pull/4584

* Change - Update ODS to 2.1.2: [#4594](https://github.com/owncloud/web/pull/4594)

   We updated the ownCloud Design System to 2.1.2. See the linked releases for details.

   https://github.com/owncloud/web/pull/4594
   https://github.com/owncloud/owncloud-design-system/releases/tag/v2.1.0
   https://github.com/owncloud/owncloud-design-system/releases/tag/v2.1.1
   https://github.com/owncloud/owncloud-design-system/releases/tag/v2.1.2

Changelog for ownCloud Web [1.0.1] (2021-01-08)
=======================================
The following sections list the changes in ownCloud web 1.0.1 relevant to
ownCloud admins and users.

[1.0.1]: https://github.com/owncloud/web/compare/v1.0.0...v1.0.1

Summary
-------

* Bugfix - Fully clickable sidebar toggle button: [#4130](https://github.com/owncloud/web/issues/4130)
* Bugfix - Allow server URL without trailing slash: [#4536](https://github.com/owncloud/web/pull/4536)
* Change - Rename confirmation of copy action: [#4590](https://github.com/owncloud/web/pull/4590)
* Change - Allow to disable previews in file lists: [#4513](https://github.com/owncloud/web/pull/4513)
* Change - Add controllers for oc10 app deployment: [#4537](https://github.com/owncloud/web/pull/4537)

Details
-------

* Bugfix - Fully clickable sidebar toggle button: [#4130](https://github.com/owncloud/web/issues/4130)

   The button for hiding/showing the left sidebar (burger menu) was not fully clickable. We fixed
   this by removing a negative margin that pulled the rest of the topbar over the button.

   https://github.com/owncloud/web/issues/4130
   https://github.com/owncloud/web/pull/4572

* Bugfix - Allow server URL without trailing slash: [#4536](https://github.com/owncloud/web/pull/4536)

   The server URL in the config was leading to issues resolving resources when it had no trailing
   slash. We are now checking if the trailing slash is missing and add it upon applying the config if
   needed.

   https://github.com/owncloud/web/pull/4536

* Change - Rename confirmation of copy action: [#4590](https://github.com/owncloud/web/pull/4590)

   We've changed the label of the confirmation button in copy view. Instead of "Copy here", we used
   "Paste here".

   https://github.com/owncloud/web/pull/4590

* Change - Allow to disable previews in file lists: [#4513](https://github.com/owncloud/web/pull/4513)

   We introduced a new config option to disable previews. To do so, set `"disablePreviews": true`
   to the config.json file.

   https://github.com/owncloud/web/pull/4513

* Change - Add controllers for oc10 app deployment: [#4537](https://github.com/owncloud/web/pull/4537)

   We added a config endpoint for when ownCloud Web is deployed as ownCloud 10 app. The config.json
   file must not be placed in the apps folder because it would cause the app integrity check to fail.
   In addition to the config endpoint we added a wildcard endpoint for serving static assets (js
   bundles, css, etc) of the ownCloud Web javascript application by their paths.

   https://github.com/owncloud/web/pull/4537

Changelog for ownCloud Web [1.0.0] (2020-12-16)
=======================================
The following sections list the changes in ownCloud web 1.0.0 relevant to
ownCloud admins and users.

[1.0.0]: https://github.com/owncloud/web/compare/v0.29.0...v1.0.0

Summary
-------

* Bugfix - Do not use origin location to open editors: [#4500](https://github.com/owncloud/web/pull/4500)
* Bugfix - Enable route checks for file actions: [#986](https://github.com/owncloud/ocis/issues/986)
* Bugfix - Fix role selection for public links: [#4504](https://github.com/owncloud/web/pull/4504)
* Bugfix - Fix navigation rendering: [#1031](https://github.com/owncloud/ocis/issues/1031)
* Bugfix - Hide modals on logout: [#1064](https://github.com/owncloud/ocis/issues/1064)
* Enhancement - Add the option to decline accepted shares: [#985](https://github.com/owncloud/ocis/issues/985)
* Enhancement - Show status of accepted shares: [#985](https://github.com/owncloud/ocis/issues/985)
* Enhancement - Add oc10 app build artifact: [#4427](https://github.com/owncloud/web/pull/4427)
* Enhancement - Extend default apps: [#4493](https://github.com/owncloud/web/pull/4493)
* Enhancement - Add custom configuration to the draw.io app: [#4337](https://github.com/owncloud/phoenix/pull/4337)
* Enhancement - Add support for .vsdx files in the draw.io app: [#4337](https://github.com/owncloud/phoenix/pull/4337)
* Enhancement - Position of main dom node: [#1052](https://github.com/owncloud/ocis/issues/1052)
* Enhancement - Wait for all required data: [#884](https://github.com/owncloud/ocis/issues/884)
* Enhancement - Update ODS to 2.0.3: [#4488](https://github.com/owncloud/web/pull/4488)
* Enhancement - Update ODS to 2.0.4: [#45001](https://github.com/owncloud/web/pull/45001)

Details
-------

* Bugfix - Do not use origin location to open editors: [#4500](https://github.com/owncloud/web/pull/4500)

   When opening the editors view in a new tab, we were using the origin of location. This would break
   in case we have Web deployed to a different path than root e.g. `http://owncloud/apps/web`.

   https://github.com/owncloud/web/pull/4500

* Bugfix - Enable route checks for file actions: [#986](https://github.com/owncloud/ocis/issues/986)

   The checks on which route an extension is enabled were not active (and inverted). We fixed this
   so that editors only appear on configured routes now.

   https://github.com/owncloud/ocis/issues/986
   https://github.com/owncloud/web/pull/4436

* Bugfix - Fix role selection for public links: [#4504](https://github.com/owncloud/web/pull/4504)

   The dropdown for the role selection in public links was not working anymore - the model didn't
   react to selections. Fixed it by bringing back a field that was accidentally removed.

   https://github.com/owncloud/web/pull/4504

* Bugfix - Fix navigation rendering: [#1031](https://github.com/owncloud/ocis/issues/1031)

   - ADD_NAV_ITEM mutation now gets copied instead of referenced to trigger a state change. -
   applicationsList navItem item needs a copy instead of mutating the base item - check for
   route.path instead of route name in ADD_NAV_ITEM which can change over time

   https://github.com/owncloud/ocis/issues/1031
   https://github.com/owncloud/ocis/issues/1043
   https://github.com/owncloud/phoenix/pull/4430

* Bugfix - Hide modals on logout: [#1064](https://github.com/owncloud/ocis/issues/1064)

   Hide shown modal if user gets logged out while it's visible

   https://github.com/owncloud/ocis/issues/1064
   https://github.com/owncloud/web/pull/4472

* Enhancement - Add the option to decline accepted shares: [#985](https://github.com/owncloud/ocis/issues/985)

   Declined shares could be accepted retroactively but accepted shares could not be declined.

   https://github.com/owncloud/ocis/issues/985

* Enhancement - Show status of accepted shares: [#985](https://github.com/owncloud/ocis/issues/985)

   The status column of accepted shares was blank.

   https://github.com/owncloud/ocis/issues/985

* Enhancement - Add oc10 app build artifact: [#4427](https://github.com/owncloud/web/pull/4427)

   We've added a build step to the release process which creates an ownCloud Web bundle which can be
   deployed as an app to ownCloud 10.

   https://github.com/owncloud/web/pull/4427

* Enhancement - Extend default apps: [#4493](https://github.com/owncloud/web/pull/4493)

   When release tarballs are created, we are copying the config.json.dist into them as a default
   config. In that file were so far only "files" app enabled. This adds also "media viewer" and
   "draw-io" into apps enabled by default.

   https://github.com/owncloud/web/pull/4493

* Enhancement - Add custom configuration to the draw.io app: [#4337](https://github.com/owncloud/phoenix/pull/4337)

   Added mechanism to specify custom configuration instead of using a hardcoded one. The new
   settings include support for a custom draw.io server, enabling autosave and using a specific
   theme.

   https://github.com/owncloud/phoenix/issues/4328
   https://github.com/owncloud/phoenix/pull/4337

* Enhancement - Add support for .vsdx files in the draw.io app: [#4337](https://github.com/owncloud/phoenix/pull/4337)

   Added the support to open .vsdx files (Microsoft Visio Files) directly from OwnCloud, instead
   of creating a new diagram to import the file from local storage.

   https://github.com/owncloud/phoenix/issues/4327
   https://github.com/owncloud/phoenix/pull/4337

* Enhancement - Position of main dom node: [#1052](https://github.com/owncloud/ocis/issues/1052)

   Div#main is now positioned relative, this way child apps are able to orientate their
   containers absolute to it.

   https://github.com/owncloud/ocis/issues/1052
   https://github.com/owncloud/web/pull/4489
   https://github.com/owncloud/owncloud-design-system/pull/1002

* Enhancement - Wait for all required data: [#884](https://github.com/owncloud/ocis/issues/884)

   Before this we rendered the ui no matter if every required data already is loaded or not. For
   example the current users language from the ocis settings service. One potential problem was
   the flickering in the ui or that the default language was shown before it switches to the
   settings language of current user. Instead we now show a loading screen and wait for everything
   that is required before rendering anything else.

   https://github.com/owncloud/ocis/issues/884
   https://github.com/owncloud/ocis/issues/1043

* Enhancement - Update ODS to 2.0.3: [#4488](https://github.com/owncloud/web/pull/4488)

   We've updated the ownCloud design system to version 2.0.3.

   https://github.com/owncloud/web/pull/4488
   https://github.com/owncloud/owncloud-design-system/releases/tag/v2.0.3

* Enhancement - Update ODS to 2.0.4: [#45001](https://github.com/owncloud/web/pull/45001)

   We've updated the ownCloud design system to version 2.0.4.

   https://github.com/owncloud/web/pull/45001
   https://github.com/owncloud/owncloud-design-system/releases/tag/v2.0.4

Changelog for ownCloud Web [0.29.0] (2020-12-07)
=======================================
The following sections list the changes in ownCloud web 0.29.0 relevant to
ownCloud admins and users.

[0.29.0]: https://github.com/owncloud/web/compare/v0.28.0...v0.29.0

Summary
-------

* Bugfix - Public link glitches: [#1028](https://github.com/owncloud/ocis/issues/1028)
* Change - Use labels to display share info: [#4410](https://github.com/owncloud/web/pull/4410)
* Enhancement - Display full public and private links: [#4410](https://github.com/owncloud/web/pull/4410)

Details
-------

* Bugfix - Public link glitches: [#1028](https://github.com/owncloud/ocis/issues/1028)

   We fixed a couple of glitches with public links: - Creating a folder in a public link context was
   showing an error message although the folder was created correctly. This was happening
   because reloading the current folder didn't take the public link context into account. - For
   public links with editor role the batch actions at the top of the files list were not showing. The
   public links route didn't have a specific flag for showing the batch actions. - Quick actions
   for sharing are not available in public link contexts by design. The check printed an error in
   the javascript console though. We made this check silent now.

   https://github.com/owncloud/ocis/issues/1028
   https://github.com/owncloud/web/pull/4425

* Change - Use labels to display share info: [#4410](https://github.com/owncloud/web/pull/4410)

   We've changed the way of displaying share information for public links and people. Every
   information is now displayed in its own label.

   https://github.com/owncloud/web/pull/4410

* Enhancement - Display full public and private links: [#4410](https://github.com/owncloud/web/pull/4410)

   Below the names of public and private links we've added the respective full URL so that users can
   copy it without the copy to clipboard button.

   https://github.com/owncloud/web/pull/4410

Changelog for ownCloud Web [0.28.0] (2020-12-04)
=======================================
The following sections list the changes in ownCloud web 0.28.0 relevant to
ownCloud admins and users.

[0.28.0]: https://github.com/owncloud/web/compare/v0.27.0...v0.28.0

Summary
-------

* Bugfix - Don't break file/folder names in text editor: [#4391](https://github.com/owncloud/web/pull/4391)
* Change - Configurable home path: [#4411](https://github.com/owncloud/web/pull/4411)
* Change - Show dedicated 404 page for invalid resource references: [#4411](https://github.com/owncloud/web/pull/4411)

Details
-------

* Bugfix - Don't break file/folder names in text editor: [#4391](https://github.com/owncloud/web/pull/4391)

   The label in the text editor that displays the path of the active file was removing the first
   character instead of trimming leading slashes. This might have lead to situations where
   actual characters were removed. We fixed this by only removing leading slashes instead of
   blindly removing the first character.

   https://github.com/owncloud/web/pull/4391

* Change - Configurable home path: [#4411](https://github.com/owncloud/web/pull/4411)

   We introduced a config.json option `homeFolder` which let's you specify a default location
   when opening the `All files` view. Please refer to the documentation for details.

   https://github.com/owncloud/web/pull/4411
   https://owncloud.github.io/clients/web/getting-started/

* Change - Show dedicated 404 page for invalid resource references: [#4411](https://github.com/owncloud/web/pull/4411)

   When visiting a public link or the `All files` page with an invalid resource in the URL (e.g.
   because it was deleted in the meantime) we now show a dedicated page which explains that the
   resource could not be found and offers a link to go back to the respective root (»All files«
   home location or the root of the public link). The breadcrumbs have been made available on
   invalid resources as well, so that those could be used for more precise navigation instead of
   jumping back to the root.

   https://github.com/owncloud/web/pull/4411

Changelog for ownCloud Web [0.27.0] (2020-11-24)
=======================================
The following sections list the changes in ownCloud web 0.27.0 relevant to
ownCloud admins and users.

[0.27.0]: https://github.com/owncloud/web/compare/v0.26.0...v0.27.0

Summary
-------

* Bugfix - Unavailable extensions causing route duplication: [#4382](https://github.com/owncloud/web/pull/4382)
* Change - Configurable default extension: [#4382](https://github.com/owncloud/web/pull/4382)
* Change - Load extensions config: [#4380](https://github.com/owncloud/web/pull/4380)

Details
-------

* Bugfix - Unavailable extensions causing route duplication: [#4382](https://github.com/owncloud/web/pull/4382)

   There was an error in the extension loading handlers which caused routes to be loaded multiple
   times when extensions from the config.json were unavailable. We hardened the extension
   loading handlers to just skip those extensions.

   https://github.com/owncloud/web/pull/4382

* Change - Configurable default extension: [#4382](https://github.com/owncloud/web/pull/4382)

   We introduced a config option in the config.json file which allows to configure the default
   extension for ownCloud Web. Any of the configured extension ids can be chosen as default
   extension. If none is provided, we fall back to the files extension.

   https://github.com/owncloud/web/pull/4382

* Change - Load extensions config: [#4380](https://github.com/owncloud/web/pull/4380)

   We've started loading the config of extensions which can now be defined as an object in the
   `external_apps` in the config.json.

   https://github.com/owncloud/web/pull/4380

Changelog for ownCloud Web [0.26.0] (2020-11-23)
=======================================
The following sections list the changes in ownCloud web 0.26.0 relevant to
ownCloud admins and users.

[0.26.0]: https://github.com/owncloud/web/compare/v0.25.0...v0.26.0

Summary
-------

* Bugfix - Fix edit public link view: [#4374](https://github.com/owncloud/web/pull/4374)
* Bugfix - Icon mappings: [#4357](https://github.com/owncloud/web/pull/4357)
* Enhancement - Use handler of file editors: [#4324](https://github.com/owncloud/web/pull/4324)
* Enhancement - Add custom icons in the new file menu: [#4375](https://github.com/owncloud/web/pull/4375)
* Enhancement - Theme redirect and access denied pages: [#4373](https://github.com/owncloud/web/pull/4373)
* Enhancement - Update ODS to 2.0.0: [#4373](https://github.com/owncloud/web/pull/4373)

Details
-------

* Bugfix - Fix edit public link view: [#4374](https://github.com/owncloud/web/pull/4374)

   We've fixed the issue that edit public link view in the sidebar was overlapping with the
   versions accordion.

   https://github.com/owncloud/web/pull/4374

* Bugfix - Icon mappings: [#4357](https://github.com/owncloud/web/pull/4357)

   The file type icon mappings contained some mappings to non-existing icon files. We fixed
   those.

   https://github.com/owncloud/ocis/issues/905
   https://github.com/owncloud/web/pull/4357

* Enhancement - Use handler of file editors: [#4324](https://github.com/owncloud/web/pull/4324)

   In case the extension is a file editor which defines a custom handler, we are triggering that
   handler instead of trying to open any assigned route.

   https://github.com/owncloud/web/pull/4324

* Enhancement - Add custom icons in the new file menu: [#4375](https://github.com/owncloud/web/pull/4375)

   We've added an option to display own icon in the new file menu.

   https://github.com/owncloud/web/pull/4375

* Enhancement - Theme redirect and access denied pages: [#4373](https://github.com/owncloud/web/pull/4373)

   We've adjusted the theme on OIDC redirect and access denied pages to use correct logo and
   background. We've also added those two values into the theming capabilities.

   https://github.com/owncloud/web/pull/4373

* Enhancement - Update ODS to 2.0.0: [#4373](https://github.com/owncloud/web/pull/4373)

   We've updated the ownCloud design system to version 2.0.0.

   https://github.com/owncloud/web/pull/4373
   https://github.com/owncloud/owncloud-design-system/releases/tag/v2.0.0

Changelog for ownCloud Web [0.25.0] (2020-11-16)
=======================================
The following sections list the changes in ownCloud web 0.25.0 relevant to
ownCloud admins and users.

[0.25.0]: https://github.com/owncloud/web/compare/v0.24.0...v0.25.0

Summary
-------

* Bugfix - Make available file actions (more) aware of the page context: [#4255](https://github.com/owncloud/web/pull/4255)
* Bugfix - Fix loginAsUser: [#4297](https://github.com/owncloud/web/pull/4297)
* Change - File actions as accordion item in right sidebar: [#4255](https://github.com/owncloud/web/pull/4255)
* Enhancement - Added support for OpenID Connect Dynamic Client Registration 1.0: [#4286](https://github.com/owncloud/web/pull/4286)

Details
-------

* Bugfix - Make available file actions (more) aware of the page context: [#4255](https://github.com/owncloud/web/pull/4255)

   The list of available file actions sometimes contained actions which should not be possible
   and sometimes was missing actions that should be possible. Most important examples are that
   copy/move should not be available on `shared with me` and `shared with others` pages (but they
   were) and that the set of file actions from the `All files` page should also be available for the
   favorites page (but were not).

   https://github.com/owncloud/web/pull/4255

* Bugfix - Fix loginAsUser: [#4297](https://github.com/owncloud/web/pull/4297)

   LoginAsUser wasn't waiting until the loading finished. Added an additional check

   https://github.com/owncloud/web/pull/4297

* Change - File actions as accordion item in right sidebar: [#4255](https://github.com/owncloud/web/pull/4255)

   We moved the menu items from `file actions` dropdown menu (the "three dots menu") as accordion
   item into the right sidebar and made it the default item to be opened when clicking the three
   dots. For the sake of consistency we now also made the right sidebar available for the `Deleted
   files` page, where we offer the actions accordion item with a `Restore` and `Delete` action.

   https://github.com/owncloud/web/pull/4255

* Enhancement - Added support for OpenID Connect Dynamic Client Registration 1.0: [#4286](https://github.com/owncloud/web/pull/4286)

   OwnCloud Web can use the dynamic client registration protocol to exchange client id and client
   secret with the IdP

   https://github.com/owncloud/web/pull/4286
   https://github.com/owncloud/web/pull/4306

Changelog for ownCloud Web [0.24.0] (2020-11-06)
=======================================
The following sections list the changes in ownCloud web 0.24.0 relevant to
ownCloud admins and users.

[0.24.0]: https://github.com/owncloud/web/compare/v0.23.0...v0.24.0

Summary
-------

* Bugfix - Fix browse to files page in the ui tests: [#4281](https://github.com/owncloud/web/issues/4281)
* Enhancement - Display collaborators type: [#4203](https://github.com/owncloud/web/pull/4203)

Details
-------

* Bugfix - Fix browse to files page in the ui tests: [#4281](https://github.com/owncloud/web/issues/4281)

   When the ui tests where executing the "the user has browsed to the files page" step then it
   wouldn't wait until the files were loaded.

   https://github.com/owncloud/web/issues/4281

* Enhancement - Display collaborators type: [#4203](https://github.com/owncloud/web/pull/4203)

   We've added a new line into the collaborators autocomplete and list in the sidebar to display
   their type.

   https://github.com/owncloud/web/pull/4203

Changelog for ownCloud Web [0.23.0] (2020-10-30)
=======================================
The following sections list the changes in ownCloud web 0.23.0 relevant to
ownCloud admins and users.

[0.23.0]: https://github.com/owncloud/web/compare/v0.22.0...v0.23.0

Summary
-------

* Change - App sidebar accordion instead of tabs: [#4249](https://github.com/owncloud/web/pull/4249)

Details
-------

* Change - App sidebar accordion instead of tabs: [#4249](https://github.com/owncloud/web/pull/4249)

   We replaced the tabs in the right app-sidebar with an accordion.

   https://github.com/owncloud/web/pull/4249

Changelog for ownCloud Web [0.22.0] (2020-10-26)
=======================================
The following sections list the changes in ownCloud web 0.22.0 relevant to
ownCloud admins and users.

[0.22.0]: https://github.com/owncloud/web/compare/v0.21.0...v0.22.0

Summary
-------

* Change - Set icon for unknown file types to "file": [#4237](https://github.com/owncloud/web/pull/4237)
* Change - Attach share permission to roles: [#4216](https://github.com/owncloud/web/pull/4216)
* Change - Update ODS to v1.12.2: [#4239](https://github.com/owncloud/web/pull/4239)
* Enhancement - Auto-close alerts: [#4236](https://github.com/owncloud/web/pull/4236)

Details
-------

* Change - Set icon for unknown file types to "file": [#4237](https://github.com/owncloud/web/pull/4237)

   We've changed the icon for unknown file types to "file".

   https://github.com/owncloud/web/pull/4237
   https://owncloud.design/#/Design%20Tokens/Icon

* Change - Attach share permission to roles: [#4216](https://github.com/owncloud/web/pull/4216)

   We've attached the share permission of collaborators to roles. There is no longer a share
   additional permission.

   https://github.com/owncloud/web/pull/4216

* Change - Update ODS to v1.12.2: [#4239](https://github.com/owncloud/web/pull/4239)

   We updated ODS to v1.12.2. Please refer to the changelog of ODS.

   https://github.com/owncloud/web/pull/4239
   https://github.com/owncloud/owncloud-design-system/releases/tag/v1.12.2

* Enhancement - Auto-close alerts: [#4236](https://github.com/owncloud/web/pull/4236)

   We've added a property which enables alerts to be automatically closed. When enabling the
   auto-close, it will get assigned timeout of 5 seconds. Default timeout can be overwritten
   inside of the `autoClose` object.

   https://github.com/owncloud/web/pull/4236

Changelog for ownCloud Web [0.21.0] (2020-10-21)
=======================================
The following sections list the changes in ownCloud web 0.21.0 relevant to
ownCloud admins and users.

[0.21.0]: https://github.com/owncloud/web/compare/v0.20.0...v0.21.0

Summary
-------

* Bugfix - OIDC logout: [#266](https://github.com/owncloud/product/issues/266)
* Bugfix - Do not display "empty folder" message when there is any content: [#263](https://github.com/owncloud/product/issues/263)
* Change - Sensible default apps in example configs: [#4155](https://github.com/owncloud/web/pull/4155)

Details
-------

* Bugfix - OIDC logout: [#266](https://github.com/owncloud/product/issues/266)

   We've fixed the bug that the user sometimes got immediately logged back into the web UI after
   clicking on logout.

   https://github.com/owncloud/product/issues/266
   https://github.com/owncloud/web/pull/4211

* Bugfix - Do not display "empty folder" message when there is any content: [#263](https://github.com/owncloud/product/issues/263)

   We've fixed that when some of the file/share lists were being loaded, the "empty folder"
   message sometimes briefly appeared even though the list wasn't empty.

   https://github.com/owncloud/product/issues/263
   https://github.com/owncloud/web/pull/4162

* Change - Sensible default apps in example configs: [#4155](https://github.com/owncloud/web/pull/4155)

   We adapted the example configs for oc10 and owncloud so that the files and media-viewer apps are
   enabled by default.

   https://github.com/owncloud/web/pull/4155

Changelog for ownCloud Web [0.20.0] (2020-10-08)
=======================================
The following sections list the changes in ownCloud web 0.20.0 relevant to
ownCloud admins and users.

[0.20.0]: https://github.com/owncloud/web/compare/v0.19.0...v0.20.0

Summary
-------

* Change - Enable autoredirect to the IdP: [#4138](https://github.com/owncloud/web/pull/4138)

Details
-------

* Change - Enable autoredirect to the IdP: [#4138](https://github.com/owncloud/web/pull/4138)

   We've added a key into the theme to enable autoredirect to the IdP when entering ocis-web
   instead of displaying the login page first. The default value is set to true.

   https://github.com/owncloud/web/pull/4138

Changelog for ownCloud Web [0.19.0] (2020-10-06)
=======================================
The following sections list the changes in ownCloud web 0.19.0 relevant to
ownCloud admins and users.

[0.19.0]: https://github.com/owncloud/web/compare/v0.18.0...v0.19.0

Summary
-------

* Change - Customizable menu association: [#4133](https://github.com/owncloud/web/pull/4133)

Details
-------

* Change - Customizable menu association: [#4133](https://github.com/owncloud/web/pull/4133)

   We now allow the redirect navItems and links into the user menu. This can be done by simply
   assigning the `"menu": "user"` to the respective navItem. It works for both extensions and
   external links (`applications` key in config.json).

   https://github.com/owncloud/web/pull/4133

Changelog for ownCloud Web [0.18.0] (2020-10-05)
=======================================
The following sections list the changes in ownCloud web 0.18.0 relevant to
ownCloud admins and users.

[0.18.0]: https://github.com/owncloud/web/compare/v0.17.0...v0.18.0

Summary
-------

* Change - Change sharing wording: [#4120](https://github.com/owncloud/web/pull/4120)
* Enhancement - Update owncloud-design-system to v1.12.1: [#4120](https://github.com/owncloud/web/pull/4120)

Details
-------

* Change - Change sharing wording: [#4120](https://github.com/owncloud/web/pull/4120)

   Renamed "Share" action to "Add people" and header column in the shared with list from "People"
   to "Shared with".

   https://github.com/owncloud/web/pull/4120

* Enhancement - Update owncloud-design-system to v1.12.1: [#4120](https://github.com/owncloud/web/pull/4120)

   We've updated our design system to version 1.12.1. To see all new changes which this update
   brings, please check the changelog below.

   https://github.com/owncloud/web/pull/4120
   https://github.com/owncloud/owncloud-design-system/releases/tag/v1.12.1

Changelog for ownCloud Web [0.17.0] (2020-09-25)
=======================================
The following sections list the changes in ownCloud web 0.17.0 relevant to
ownCloud admins and users.

[0.17.0]: https://github.com/owncloud/web/compare/v0.16.0...v0.17.0

Summary
-------

* Bugfix - Added missing tooltips: [#4081](https://github.com/owncloud/web/pull/4081)
* Bugfix - Make file previews properly fit: [#232](https://github.com/owncloud/product/issues/232)
* Bugfix - Adjust behavior of public link password field: [#4077](https://github.com/owncloud/web/pull/4077)
* Change - Adjustments to roles selection dropdown: [#4080](https://github.com/owncloud/web/pull/4080)
* Change - Rename "trash bin" to "deleted files": [#4071](https://github.com/owncloud/web/pull/4071)
* Change - Add default action to click on file name: [#234](https://github.com/owncloud/product/issues/234)
* Change - Improve external links in app switcher: [#4092](https://github.com/owncloud/web/pull/4092)
* Change - More descriptive loading state: [#4099](https://github.com/owncloud/web/pull/4099)
* Change - Moved bottom actions menu into actions dropdown: [#234](https://github.com/owncloud/product/issues/234)
* Change - Renamed collaborators to people: [#4070](https://github.com/owncloud/web/pull/4070)
* Change - Update ODS to 1.11.0: [#4086](https://github.com/owncloud/web/pull/4086)
* Change - Shortened button label for creating public links: [#4072](https://github.com/owncloud/web/pull/4072)
* Enhancement - Remember public link password on page refresh: [#4083](https://github.com/owncloud/web/pull/4083)

Details
-------

* Bugfix - Added missing tooltips: [#4081](https://github.com/owncloud/web/pull/4081)

   We've added tooltips for the following:

   - top bar: notifications button and application switcher - file list: share indicators and
   quick actions - sharing in sidebar: action icons like edit, delete, copy

   https://github.com/owncloud/product/issues/231
   https://github.com/owncloud/web/pull/4081

* Bugfix - Make file previews properly fit: [#232](https://github.com/owncloud/product/issues/232)

   We've fixed the file preview to prevent overflowing vertically and also added CSS property to
   make sure the ratio is preserved

   https://github.com/owncloud/product/issues/232
   https://github.com/owncloud/web/pull/4073

* Bugfix - Adjust behavior of public link password field: [#4077](https://github.com/owncloud/web/pull/4077)

   The UX of the public link password field has been improved. The field is focussed automatically
   and the enter key submits the password. Also, in case of wrong password, an error message is now
   displayed.

   https://github.com/owncloud/product/issues/231
   https://github.com/owncloud/web/pull/4077

* Change - Adjustments to roles selection dropdown: [#4080](https://github.com/owncloud/web/pull/4080)

   The role description text from the roles selection button has been removed, but is still
   visible when opening the dropdown. The dropdown now also has a chevron icon to make it clearer
   that it is a dropdown.

   https://github.com/owncloud/product/issues/231
   https://github.com/owncloud/web/pull/4080

* Change - Rename "trash bin" to "deleted files": [#4071](https://github.com/owncloud/web/pull/4071)

   We've renamed the "trash bin" to the more appropriate wording "deleted files".

   https://github.com/owncloud/product/issues/231
   https://github.com/owncloud/web/pull/4071

* Change - Add default action to click on file name: [#234](https://github.com/owncloud/product/issues/234)

   When clicking on the file name in the files list, a default action is triggered which opens the
   first available file editor or viewer. If no file editor or viewer is available, the default
   action falls back to download.

   https://github.com/owncloud/product/issues/234
   https://github.com/owncloud/web/pull/4076
   https://github.com/owncloud/web/pull/4097

* Change - Improve external links in app switcher: [#4092](https://github.com/owncloud/web/pull/4092)

   We have added an option to set the link target in external application links (defaults to
   `_blank`). The app switcher now shows all native extensions first and items based on
   application links last.

   https://github.com/owncloud/web/pull/4092

* Change - More descriptive loading state: [#4099](https://github.com/owncloud/web/pull/4099)

   When browsing the different variations of the files list we removed the loader component at the
   top in favor of a spinner in the center of the viewport. The spinner has one line of text which
   describes what kind of data is being loaded.

   https://github.com/owncloud/web/pull/4099

* Change - Moved bottom actions menu into actions dropdown: [#234](https://github.com/owncloud/product/issues/234)

   We've removed the bottom file actions menu and moved all actions into the actions dropdown in
   the files list.

   https://github.com/owncloud/product/issues/234
   https://github.com/owncloud/web/pull/4076

* Change - Renamed collaborators to people: [#4070](https://github.com/owncloud/web/pull/4070)

   All visible occurrences of "collaborator" or "collaborators" have been replaced by "person"
   or "people" respectively. Additionally, the action "Add Collaborator" was changed to
   "Share".

   https://github.com/owncloud/product/issues/231
   https://github.com/owncloud/web/pull/4070

* Change - Update ODS to 1.11.0: [#4086](https://github.com/owncloud/web/pull/4086)

   We updated owncloud design system (ODS) to 1.11.0. This brings some features and required some
   changes: - Buttons: - require to be placed in a grid or with uk-flex for side by side positioning,
   - don't have an icon property anymore, - have a slot so that content of the button can be just
   anything - placement of the content in the button can be modified with new props
   `justify-content` and `gap` - new icons, which are used in the sidebar and for quick actions -
   sidebar has a property for hiding the navigation. It doesn't have internal logic anymore for
   hiding the navigation automatically.

   https://github.com/owncloud/web/pull/4086

* Change - Shortened button label for creating public links: [#4072](https://github.com/owncloud/web/pull/4072)

   The label of the button for creating public links in the links panel has been shortened to
   "Public link" instead of "Add public link" since the plus sign already implies adding. An Aria
   label has been added for clarification when using screen readers.

   https://github.com/owncloud/web/issues/231
   https://github.com/owncloud/web/pull/4072

* Enhancement - Remember public link password on page refresh: [#4083](https://github.com/owncloud/web/pull/4083)

   When refreshing the page in the file list of a public link share, the user doesn't need to enter
   the password again. This only applies for the current page and the password is forgotten by the
   browser again upon closing or switching to another site.

   https://github.com/owncloud/product/issues/231
   https://github.com/owncloud/web/pull/4083

Changelog for ownCloud Web [0.16.0] (2020-08-24)
=======================================
The following sections list the changes in ownCloud web 0.16.0 relevant to
ownCloud admins and users.

[0.16.0]: https://github.com/owncloud/web/compare/v0.15.0...v0.16.0

Summary
-------

* Change - Add default external apps for ocis: [#3967](https://github.com/owncloud/web/pull/3967)
* Enhancement - Add info about number of selected items and their size: [#122](https://github.com/owncloud/product/issues/122)

Details
-------

* Change - Add default external apps for ocis: [#3967](https://github.com/owncloud/web/pull/3967)

   We are enabling the settings-ui and accounts-ui by default now for ocis.

   https://github.com/owncloud/web/pull/3967

* Enhancement - Add info about number of selected items and their size: [#122](https://github.com/owncloud/product/issues/122)

   We've added information about the number of selected items and their size above the files list
   next to batch actions.

   https://github.com/owncloud/product/issues/122
   https://github.com/owncloud/web/pull/3850

Changelog for ownCloud Web [0.15.0] (2020-08-19)
=======================================
The following sections list the changes in ownCloud web 0.15.0 relevant to
ownCloud admins and users.

[0.15.0]: https://github.com/owncloud/web/compare/v0.14.0...v0.15.0

Summary
-------

* Change - Adapt to new ocis-settings data model: [#3806](https://github.com/owncloud/web/pull/3806)

Details
-------

* Change - Adapt to new ocis-settings data model: [#3806](https://github.com/owncloud/web/pull/3806)

   Ocis-settings introduced UUIDs and less verbose endpoint and message type names. This PR
   adjusts web accordingly.

   https://github.com/owncloud/web/pull/3806
   https://github.com/owncloud/owncloud-sdk/pull/520
   https://github.com/owncloud/ocis-settings/pull/46

Changelog for ownCloud Web [0.14.0] (2020-08-17)
=======================================
The following sections list the changes in ownCloud web 0.14.0 relevant to
ownCloud admins and users.

[0.14.0]: https://github.com/owncloud/web/compare/v0.13.0...v0.14.0

Summary
-------

* Bugfix - Fix display name when using oCIS as backend: [#3938](https://github.com/owncloud/web/pull/3938)
* Change - Differentiate between user-id and username: [#440](https://github.com/owncloud/ocis/issues/440)
* Change - Provide option for hiding the search bar: [#116](https://github.com/owncloud/product/issues/116)
* Change - Move information about current folder below the files list: [#120](https://github.com/owncloud/product/issues/120)
* Change - Use pre-signed URLs in media viewer: [#3803](https://github.com/owncloud/web/pull/3803)
* Change - Move quota indication to the left sidebar: [#121](https://github.com/owncloud/product/issues/121)
* Change - Move docs about hugo usage to ocis: [#3828](https://github.com/owncloud/web/pull/3828)
* Change - Get rid of static "Shared with:" label: [#123](https://github.com/owncloud/product/issues/123)
* Change - Large file downloads support with URL signing: [#3797](https://github.com/owncloud/web/pull/3797)
* Enhancement - Enable playing videos in media viewer: [#3803](https://github.com/owncloud/web/pull/3803)

Details
-------

* Bugfix - Fix display name when using oCIS as backend: [#3938](https://github.com/owncloud/web/pull/3938)

   We've fixed the display name when running ocis-web with oCIS as backend. The display name is now
   again displayed in the top bar and in the account page.

   https://github.com/owncloud/web/pull/3938

* Change - Differentiate between user-id and username: [#440](https://github.com/owncloud/ocis/issues/440)

   With oCIS user-id and username are not the same as is the case in ownCloud 10. We've started
   differentiating between them to correctly display all information in the accounts page. If
   the username is not available (oC10), we fall back to using user-id as the username.

   https://github.com/owncloud/ocis/issues/440
   https://github.com/owncloud/web/pull/3938

* Change - Provide option for hiding the search bar: [#116](https://github.com/owncloud/product/issues/116)

   We introduced a new `options.hideSearchBar` config variable which can be used to disable the
   search bar entirely.

   https://github.com/owncloud/product/issues/116
   https://github.com/owncloud/web/pull/3817

* Change - Move information about current folder below the files list: [#120](https://github.com/owncloud/product/issues/120)

   We've moved the information about current folder directly below the files list. Previously
   this information was always displayed on the bottom of the screen.

   https://github.com/owncloud/product/issues/120
   https://github.com/owncloud/web/pull/3849

* Change - Use pre-signed URLs in media viewer: [#3803](https://github.com/owncloud/web/pull/3803)

   We've started using pre-signed URLs if supported in media viewer to display images instead of
   fetching them.

   https://github.com/owncloud/web/pull/3803
   https://github.com/owncloud/web/pull/3844

* Change - Move quota indication to the left sidebar: [#121](https://github.com/owncloud/product/issues/121)

   We've moved the quota indication from the bottom of the files list to the footer of the left
   sidebar.

   https://github.com/owncloud/product/issues/121
   https://github.com/owncloud/web/pull/3849

* Change - Move docs about hugo usage to ocis: [#3828](https://github.com/owncloud/web/pull/3828)

   Since our documentation about how to work with hugo (for documentation) is a cross-extension
   topic, we have moved it to our main ocis docs.

   https://github.com/owncloud/web/pull/3828

* Change - Get rid of static "Shared with:" label: [#123](https://github.com/owncloud/product/issues/123)

   We removed the static "Shared with:" text label in the indicator row of file items. From now on,
   if a file item has no indicators, it will fall back to the one-row layout (resource name
   vertically centered).

   https://github.com/owncloud/product/issues/123
   https://github.com/owncloud/web/pull/3808

* Change - Large file downloads support with URL signing: [#3797](https://github.com/owncloud/web/pull/3797)

   When the backend supports URL signing we now download with a signed url instead of downloading
   as BLOB.

   https://github.com/owncloud/web/pull/3797

* Enhancement - Enable playing videos in media viewer: [#3803](https://github.com/owncloud/web/pull/3803)

   We've added a capability to the media viewer extension to play videos.

   https://github.com/owncloud/web/pull/3803
   https://github.com/owncloud/web/pull/3833
   https://github.com/owncloud/web/pull/3844
   https://github.com/owncloud/web/pull/3848

Changelog for ownCloud Web [0.13.0] (2020-07-17)
=======================================
The following sections list the changes in ownCloud web 0.13.0 relevant to
ownCloud admins and users.

[0.13.0]: https://github.com/owncloud/web/compare/v0.12.0...v0.13.0

Summary
-------

* Bugfix - Fix translations string: [#3766](https://github.com/owncloud/web/pull/3766)
* Enhancement - Add dev docs for releases: [#3186](https://github.com/owncloud/web/pull/3186)
* Enhancement - Enable changing sidebar logo via theming: [#3782](https://github.com/owncloud/web/issues/3782)

Details
-------

* Bugfix - Fix translations string: [#3766](https://github.com/owncloud/web/pull/3766)

   Allow better translations of various strings.

   https://github.com/owncloud/web/pull/3766
   https://github.com/owncloud/web/pull/3769

* Enhancement - Add dev docs for releases: [#3186](https://github.com/owncloud/web/pull/3186)

   We added documentation on the steps involved to release web.

   https://github.com/owncloud/web/pull/3186
   https://github.com/owncloud/web/pull/3767

* Enhancement - Enable changing sidebar logo via theming: [#3782](https://github.com/owncloud/web/issues/3782)

   We've added a key into the theme which enables using different logo in the sidebar.

   https://github.com/owncloud/web/issues/3782
   https://github.com/owncloud/web/pull/3783

Changelog for ownCloud Web [0.12.0] (2020-07-10)
=======================================
The following sections list the changes in ownCloud web 0.12.0 relevant to
ownCloud admins and users.

[0.12.0]: https://github.com/owncloud/web/compare/v0.11.2...v0.12.0

Summary
-------

* Bugfix - Fix navigation to the root folder from location picker: [#3756](https://github.com/owncloud/web/pull/3756)
* Change - Don't fallback to appId in case the route of file action is not defined: [#69](https://github.com/owncloud/product/issues/69)
* Change - Do not display outline when the files list is focused: [#3747](https://github.com/owncloud/web/issues/3747)
* Change - No file drop if upload is not allowed or no space is left: [#3677](https://github.com/owncloud/web/pull/3677)
* Enhancement - Add ability to copy files and folders into a different location: [#102](https://github.com/owncloud/product/issues/102)
* Enhancement - Add favorites capabilities: [#354](https://github.com/owncloud/ocis/issues/354)
* Enhancement - Add ability to move files and folders into a different location: [#101](https://github.com/owncloud/product/issues/101)

Details
-------

* Bugfix - Fix navigation to the root folder from location picker: [#3756](https://github.com/owncloud/web/pull/3756)

   The target location in the location picker was appending a whitespace when trying to go to root
   folder. This resulted in an error when trying to load such folder. We've removed the whitespace
   to fix the navigation.

   https://github.com/owncloud/web/pull/3756

* Change - Don't fallback to appId in case the route of file action is not defined: [#69](https://github.com/owncloud/product/issues/69)

   When opening a file in a editor or a viewer the path was falling back to an appId. This made it
   impossible to navigate via the file actions into an app which doesn't have duplicate appId in
   the route. We've stopped falling back to this value and in case that the route of the file action
   is not defined, we use the root path of the app.

   https://github.com/owncloud/product/issues/69
   https://github.com/owncloud/ocis/issues/356
   https://github.com/owncloud/web/pull/3740

* Change - Do not display outline when the files list is focused: [#3747](https://github.com/owncloud/web/issues/3747)

   The files list was displaying outline when it received focus after a click. Since the focus is
   meant only programmatically, the outline was not supposed to be displayed.

   https://github.com/owncloud/web/issues/3747
   https://github.com/owncloud/web/issues/3551
   https://github.com/owncloud/web/pull/3752

* Change - No file drop if upload is not allowed or no space is left: [#3677](https://github.com/owncloud/web/pull/3677)

   https://github.com/owncloud/web/pull/3677

* Enhancement - Add ability to copy files and folders into a different location: [#102](https://github.com/owncloud/product/issues/102)

   We've added copy action to the files list. The copy action is executed via a new page called
   location picker.

   https://github.com/owncloud/product/issues/102
   https://github.com/owncloud/product/issues/108
   https://github.com/owncloud/web/pull/3749

* Enhancement - Add favorites capabilities: [#354](https://github.com/owncloud/ocis/issues/354)

   We've added a check of favorites capabilities to enable disabling of favorites list and
   favorite action.

   https://github.com/owncloud/ocis/issues/354
   https://github.com/owncloud/web/pull/3754

* Enhancement - Add ability to move files and folders into a different location: [#101](https://github.com/owncloud/product/issues/101)

   We've added move action to the files list which enables move of resources into different
   locations. The move operation is executed in a new page called Location picker.

   https://github.com/owncloud/product/issues/101
   https://github.com/owncloud/web/pull/3739

Changelog for ownCloud Web [0.11.2] (2020-07-03)
=======================================
The following sections list the changes in ownCloud web 0.11.2 relevant to
ownCloud admins and users.

[0.11.2]: https://github.com/owncloud/web/compare/v0.11.1...v0.11.2

Summary
-------

* Bugfix - Remove anchor on last breadcrumb segment: [#3722](https://github.com/owncloud/web/issues/3722)

Details
-------

* Bugfix - Remove anchor on last breadcrumb segment: [#3722](https://github.com/owncloud/web/issues/3722)

   The last segment of the breadcrumb was clickable, while it's expected that nothing happens (as
   it is the current path). We fixed that, the last breadcrumb element is not clickable anymore.

   https://github.com/owncloud/web/issues/3722
   https://github.com/owncloud/web/issues/2965
   https://github.com/owncloud/web/issues/1883
   https://github.com/owncloud/web/pull/3723

Changelog for ownCloud Web [0.11.1] (2020-06-29)
=======================================
The following sections list the changes in ownCloud web 0.11.1 relevant to
ownCloud admins and users.

[0.11.1]: https://github.com/owncloud/web/compare/v0.11.0...v0.11.1

Summary
-------

* Bugfix - Public upload now keeps modified time: [#3686](https://github.com/owncloud/web/pull/3686)
* Bugfix - Do not expand the width of resource name over it's content: [#3685](https://github.com/owncloud/web/issues/3685)
* Change - Use "Shared with" as a label for indicators: [#3688](https://github.com/owncloud/web/pull/3688)
* Enhancement - Update owncloud-sdk to 1.0.0-663: [#3690](https://github.com/owncloud/web/pull/3690)

Details
-------

* Bugfix - Public upload now keeps modified time: [#3686](https://github.com/owncloud/web/pull/3686)

   The public upload for public links now keeps the modification time of local files. This aligns
   the behavior with non-public file upload.

   https://github.com/owncloud/web/pull/3686

* Bugfix - Do not expand the width of resource name over it's content: [#3685](https://github.com/owncloud/web/issues/3685)

   The width of the resource name in the files list was expanded more than the actual width of it's
   content. This caused that when clicked outside of the resource name, the action to navigate or
   open the resource has been triggered instead of opening the sidebar. We've fixed the width that
   it is now equal to the width of the content.

   https://github.com/owncloud/web/issues/3685
   https://github.com/owncloud/web/pull/3687

* Change - Use "Shared with" as a label for indicators: [#3688](https://github.com/owncloud/web/pull/3688)

   Instead of "State" we've started using the "Shared with" as a label for the indicators in the
   files list. This is only intermediate solution because the indicators can be extended by other
   indicators which don't have to be related to sharing.

   https://github.com/owncloud/web/pull/3688

* Enhancement - Update owncloud-sdk to 1.0.0-663: [#3690](https://github.com/owncloud/web/pull/3690)

   We've updated the owncloud-sdk to version 1.0.0-663. This version stops rejecting sharing
   promises if the passed shareID is not an integer.

   https://github.com/owncloud/web/pull/3690

Changelog for ownCloud Web [0.11.0] (2020-06-26)
=======================================
The following sections list the changes in ownCloud web 0.11.0 relevant to
ownCloud admins and users.

[0.11.0]: https://github.com/owncloud/web/compare/v0.10.0...v0.11.0

Summary
-------

* Bugfix - Fix file type icons for uppercase file extensions: [#3670](https://github.com/owncloud/web/pull/3670)
* Bugfix - Fix empty settings values: [#3602](https://github.com/owncloud/web/pull/3602)
* Bugfix - Set default permissions to public link quick action: [#3675](https://github.com/owncloud/web/issues/3675)
* Bugfix - Set empty object when resetting current sidebar tab: [#3676](https://github.com/owncloud/web/issues/3676)
* Bugfix - Set expiration date only if it is supported: [#3674](https://github.com/owncloud/web/issues/3674)
* Bugfix - Add missing question mark to delete confirmation dialog in trashbin: [#3566](https://github.com/owncloud/web/pull/3566)
* Change - Bring new modal component: [#2263](https://github.com/owncloud/web/issues/2263)
* Change - Move create new button: [#3622](https://github.com/owncloud/web/pull/3622)
* Change - Move status indicators under the resource name: [#3617](https://github.com/owncloud/web/pull/3617)
* Change - Remove sidebar quickAccess: [#80](https://github.com/owncloud/product/issues/80)
* Change - Rework account dropdown: [#82](https://github.com/owncloud/product/issues/82)
* Change - Unite files list status indicators: [#3567](https://github.com/owncloud/web/pull/3567)
* Change - Use correct logo: [#786](https://github.com/owncloud/owncloud-design-system/issues/786)
* Enhancement - Send mtime with uploads: [#2969](https://github.com/owncloud/web/issues/2969)
* Enhancement - Use TUS settings from capabilities: [#177](https://github.com/owncloud/ocis-reva/issues/177)
* Enhancement - Add collaborators quick action: [#3573](https://github.com/owncloud/web/pull/3573)
* Enhancement - Dynamically loaded nav items: [#3497](https://github.com/owncloud/web/issues/3497)
* Enhancement - Load and display quick actions: [#3573](https://github.com/owncloud/web/pull/3573)

Details
-------

* Bugfix - Fix file type icons for uppercase file extensions: [#3670](https://github.com/owncloud/web/pull/3670)

   https://github.com/owncloud/web/pull/3670

* Bugfix - Fix empty settings values: [#3602](https://github.com/owncloud/web/pull/3602)

   We've updated owncloud-sdk to version 1.0.0-638 which makes sure that an empty array gets
   returned whenever there are no settings values for the authenticated user. Previously having
   no settings values broke our detection of whether settings values finished loading.

   https://github.com/owncloud/ocis-settings/issues/24
   https://github.com/owncloud/web/pull/3602

* Bugfix - Set default permissions to public link quick action: [#3675](https://github.com/owncloud/web/issues/3675)

   We've set a default permissions when creating a new public link via the quick actions. The
   permissions are set to `1`.

   https://github.com/owncloud/web/issues/3675
   https://github.com/owncloud/web/pull/3678

* Bugfix - Set empty object when resetting current sidebar tab: [#3676](https://github.com/owncloud/web/issues/3676)

   We've changed the argument from `null` to an empty object when resetting the current tab of the
   sidebar.

   https://github.com/owncloud/web/issues/3676
   https://github.com/owncloud/web/pull/3678

* Bugfix - Set expiration date only if it is supported: [#3674](https://github.com/owncloud/web/issues/3674)

   We've stopped setting expiration date in collaborators panel if it is not supported.

   https://github.com/owncloud/web/issues/3674
   https://github.com/owncloud/web/pull/3679

* Bugfix - Add missing question mark to delete confirmation dialog in trashbin: [#3566](https://github.com/owncloud/web/pull/3566)

   We've added missing question mark to the delete confirmation dialog inside of the trashbin.

   https://github.com/owncloud/web/pull/3566

* Change - Bring new modal component: [#2263](https://github.com/owncloud/web/issues/2263)

   We've updated our modal component with a new one coming from ODS.

   https://github.com/owncloud/web/issues/2263
   https://github.com/owncloud/web/pull/3378

* Change - Move create new button: [#3622](https://github.com/owncloud/web/pull/3622)

   We've moved the create new button in the files app bar to the left directly next to breadcrumbs.

   https://github.com/owncloud/web/pull/3622

* Change - Move status indicators under the resource name: [#3617](https://github.com/owncloud/web/pull/3617)

   We've moved the sharing status indicators from an own column in the files list to a second row
   under the resource name.

   https://github.com/owncloud/web/pull/3617

* Change - Remove sidebar quickAccess: [#80](https://github.com/owncloud/product/issues/80)

   We have removed the sidebar quickAccess extension point. To create an quick access to the
   sidebar, we need to use the quickActions extension point.

   https://github.com/owncloud/product/issues/80
   https://github.com/owncloud/web/pull/3586

* Change - Rework account dropdown: [#82](https://github.com/owncloud/product/issues/82)

   We've removed user avatar, user email and version from the account dropdown. The log out button
   has been changed into a link. All links in account dropdown are now inside of a list.

   https://github.com/owncloud/product/issues/82
   https://github.com/owncloud/web/pull/3605

* Change - Unite files list status indicators: [#3567](https://github.com/owncloud/web/pull/3567)

   We've merged direct and indirect status indicators in the files list. With this change, we
   focus on the important information of the indicator (e.g. resource is shared). Any additional
   information can then be displayed in the related tab of the sidebar.

   https://github.com/owncloud/web/pull/3567

* Change - Use correct logo: [#786](https://github.com/owncloud/owncloud-design-system/issues/786)

   We've changed the ownCloud logo which is used in the default theme. The previous logo had an
   incorrect font-weight.

   https://github.com/owncloud/owncloud-design-system/issues/786
   https://github.com/owncloud/web/pull/3604

* Enhancement - Send mtime with uploads: [#2969](https://github.com/owncloud/web/issues/2969)

   When uploading a file, the modification time is now sent along. This means that the uploaded
   file will have the same modification time like the one it had on disk. This aligns the behavior
   with the desktop client which also keeps the mtime.

   https://github.com/owncloud/web/issues/2969
   https://github.com/owncloud/web/pull/3377

* Enhancement - Use TUS settings from capabilities: [#177](https://github.com/owncloud/ocis-reva/issues/177)

   The TUS settings advertise the maximum chunk size, so we now use the smallest chunk size from the
   one configured in config.json and the one from the capabilities.

   If the capabilities report that one should use the X-HTTP-Override-Method header, the upload
   will now use a POST request for uploads with that header set instead of PATCH.

   https://github.com/owncloud/ocis-reva/issues/177
   https://github.com/owncloud/web/pull/3568

* Enhancement - Add collaborators quick action: [#3573](https://github.com/owncloud/web/pull/3573)

   We've added a new quick action which opens the new collaborators tab in the files list sidebar.

   https://github.com/owncloud/web/pull/3573

* Enhancement - Dynamically loaded nav items: [#3497](https://github.com/owncloud/web/issues/3497)

   We have moved the navItems from application configuration into a store module. We extended
   it's functionality by introducing statically and dynamically loaded navItems. This way
   navItems can be loaded based on extension data, as soon as the extension becomes active. Please
   note that having at least one static navItem (coming from the appInfo object of an extension) is
   still a requirement for the extension appearing in the app switcher.

   https://github.com/owncloud/web/issues/3497
   https://github.com/owncloud/web/pull/3570

* Enhancement - Load and display quick actions: [#3573](https://github.com/owncloud/web/pull/3573)

   We've added an extension point into files apps for quick actions. By creating and exporting an
   object called quickActions, developers can define an action which will be then displayed in
   the files list.

   https://github.com/owncloud/web/pull/3573

Changelog for ownCloud Web [0.10.0] (2020-05-26)
=======================================
The following sections list the changes in ownCloud web 0.10.0 relevant to
ownCloud admins and users.

[0.10.0]: https://github.com/owncloud/web/compare/v0.9.0...v0.10.0

Summary
-------

* Bugfix - Fix share indicators click to open the correct panel: [#3324](https://github.com/owncloud/web/issues/3324)
* Bugfix - Set server config to ocis proxy in example config file: [#3454](https://github.com/owncloud/web/pull/3454)
* Change - Removed favorite button from file list and added it in the sidebar: [#1987](https://github.com/owncloud/web/issues/1987)
* Change - Make settings available in web: [#3484](https://github.com/owncloud/web/pull/3484)
* Change - Use language setting: [#3484](https://github.com/owncloud/web/pull/3484)
* Change - Permanently visible branded left navigation sidebar: [#3395](https://github.com/owncloud/web/issues/3395)

Details
-------

* Bugfix - Fix share indicators click to open the correct panel: [#3324](https://github.com/owncloud/web/issues/3324)

   When clicking on a share indicator inside a file list row, the correct share panel will now be
   displayed.

   https://github.com/owncloud/web/issues/3324
   https://github.com/owncloud/web/pull/3420

* Bugfix - Set server config to ocis proxy in example config file: [#3454](https://github.com/owncloud/web/pull/3454)

   We fixed the ocis example config to point to the default oCIS Proxy address instead of the
   default Web service address.

   https://github.com/owncloud/web/pull/3454

* Change - Removed favorite button from file list and added it in the sidebar: [#1987](https://github.com/owncloud/web/issues/1987)

   We've removed the favorite star button in the file list and added instead a functionality to the
   before non-working star button in the file's sidebar. We also added a new action in the file
   action dropdown menu which allows you to toggle the favorite status of your file.

   https://github.com/owncloud/web/issues/1987
   https://github.com/owncloud/web/pull/3336

* Change - Make settings available in web: [#3484](https://github.com/owncloud/web/pull/3484)

   We upgraded to a new owncloud-sdk version which provides loading settings from the settings
   service, if available. The settings values are available throughout web and all extensions.

   https://github.com/owncloud/web/pull/3484

* Change - Use language setting: [#3484](https://github.com/owncloud/web/pull/3484)

   We've changed web to make use of the language the authenticated user has chosen in the settings.

   https://github.com/owncloud/web/pull/3484

* Change - Permanently visible branded left navigation sidebar: [#3395](https://github.com/owncloud/web/issues/3395)

   We've made left navigation sidebar permanently visible and moved branding (logo and brand
   color) into it.

   https://github.com/owncloud/web/issues/3395
   https://github.com/owncloud/web/pull/3442

Changelog for ownCloud Web [0.9.0] (2020-04-27)
=======================================
The following sections list the changes in ownCloud web 0.9.0 relevant to
ownCloud admins and users.

[0.9.0]: https://github.com/owncloud/web/compare/v0.8.0...v0.9.0

Summary
-------

* Bugfix - Remove deleted files from search result: [#3266](https://github.com/owncloud/web/pull/3266)
* Bugfix - Show token string if link name is empty in FileLinkSidebar: [#3297](https://github.com/owncloud/web/pull/3297)
* Bugfix - Remove duplicate error display in input prompt: [#3342](https://github.com/owncloud/web/pull/3342)
* Bugfix - Fix translation message extraction from plain javascript files: [#3346](https://github.com/owncloud/web/pull/3346)
* Bugfix - Fix name of selected extension on broken apps: [#3376](https://github.com/owncloud/web/pull/3376)
* Change - Update owncloud-sdk: [#3369](https://github.com/owncloud/web/pull/3369)
* Enhancement - Add chunked upload with tus-js-client: [#67](https://github.com/owncloud/web/issues/67)

Details
-------

* Bugfix - Remove deleted files from search result: [#3266](https://github.com/owncloud/web/pull/3266)

   Deleted file has been removed from filesSearched state by adding a new mutation. Also, filter
   condition in remove file mutations has been changed from object reference to unique file id.

   https://github.com/owncloud/web/issues/3043
   https://github.com/owncloud/web/issues/3044
   https://github.com/owncloud/web/pull/3266

* Bugfix - Show token string if link name is empty in FileLinkSidebar: [#3297](https://github.com/owncloud/web/pull/3297)

   Owncloud-js-client was parsing empty link name xml attribute as empty object. The empty
   object was changed with an empty string. Also, FileLinkSidebar behaviour fixed by showing
   token as name for the link shares without a name.

   https://github.com/owncloud/web/issues/2517
   https://github.com/owncloud/web/pull/3297

* Bugfix - Remove duplicate error display in input prompt: [#3342](https://github.com/owncloud/web/pull/3342)

   Validation errors within the input prompt dialog were showing up twice. One of them is a
   leftover from the old version. We've fixed the dialog by removing the old validation error
   type.

   https://github.com/owncloud/web/pull/3342

* Bugfix - Fix translation message extraction from plain javascript files: [#3346](https://github.com/owncloud/web/pull/3346)

   https://github.com/Polyconseil/easygettext/issues/81
   https://github.com/owncloud/web/pull/3346

* Bugfix - Fix name of selected extension on broken apps: [#3376](https://github.com/owncloud/web/pull/3376)

   With the edge case of a broken app in config.json, the top bar is broken, because appInfo can't be
   loaded. We made ocis-web more robust by just showing the extension id in the top bar when the
   appInfo is not available.

   https://github.com/owncloud/web/pull/3376

* Change - Update owncloud-sdk: [#3369](https://github.com/owncloud/web/pull/3369)

   Updated owncloud-sdk to v1.0.0-604

   https://github.com/owncloud/web/pull/3369

* Enhancement - Add chunked upload with tus-js-client: [#67](https://github.com/owncloud/web/issues/67)

   Whenever the backend server advertises TUS support, uploading files will use TUS as well for
   uploading, which makes it possible to resume failed uploads. It is also possible to optionally
   set a chunk size by setting a numeric value for "uploadChunkSize" in bytes in config.json.

   https://github.com/owncloud/web/issues/67
   https://github.com/owncloud/web/pull/3345

Changelog for ownCloud Web [0.8.0] (2020-04-14)
=======================================
The following sections list the changes in ownCloud web 0.8.0 relevant to
ownCloud admins and users.

[0.8.0]: https://github.com/owncloud/web/compare/v0.7.0...v0.8.0

Summary
-------

* Bugfix - Display errors when saving collaborator fails: [#3176](https://github.com/owncloud/web/issues/3176)
* Bugfix - Fix media-viewer on private pages: [#3288](https://github.com/owncloud/web/pull/3288)
* Bugfix - Fix oidc redirect after logout: [#3285](https://github.com/owncloud/web/issues/3285)
* Bugfix - Update owncloud-sdk 1.0.0-544: [#3292](https://github.com/owncloud/web/pull/3292)
* Bugfix - Set a higher timeout for requirejs: [#3293](https://github.com/owncloud/web/pull/3293)
* Enhancement - Visual improvement to errors in input prompts: [#1906](https://github.com/owncloud/web/issues/1906)
* Enhancement - Add state to app urls: [#3294](https://github.com/owncloud/web/pull/3294)

Details
-------

* Bugfix - Display errors when saving collaborator fails: [#3176](https://github.com/owncloud/web/issues/3176)

   When saving a collaborator has failed, the UI was still behaving like it saved everything
   successfully. This has been fixed by displaying the errors at the top of the collaborator
   editing form and staying in the editing view.

   https://github.com/owncloud/web/issues/3176
   https://github.com/owncloud/web/pull/3241

* Bugfix - Fix media-viewer on private pages: [#3288](https://github.com/owncloud/web/pull/3288)

   Media-viewer incorrectly assumed it was on a public page when opened from a private page.

   https://github.com/owncloud/web/pull/3288

* Bugfix - Fix oidc redirect after logout: [#3285](https://github.com/owncloud/web/issues/3285)

   After the logout the idp sent a redirect to `<redirectUri>?state=` which was then redirected
   to `<redirectUri>?state=#/login` by web. Having the query parameters in between broke the
   application. To prevent the whole login url `<baseUrl>#/login` should be sent then the query
   parameter will be appended to the end.

   https://github.com/owncloud/web/issues/3285

* Bugfix - Update owncloud-sdk 1.0.0-544: [#3292](https://github.com/owncloud/web/pull/3292)

   This sdk version is much smaller in size

   https://github.com/owncloud/web/pull/3292

* Bugfix - Set a higher timeout for requirejs: [#3293](https://github.com/owncloud/web/pull/3293)

   In slow networks requirejs requests can timeout. The timeout is now set to a higher value (200
   secs)

   https://github.com/owncloud/web/pull/3293

* Enhancement - Visual improvement to errors in input prompts: [#1906](https://github.com/owncloud/web/issues/1906)

   We've adjusted the input prompts to show a visually less prominent text below the input field.
   Also, error messages now appear with a small delay, so that those happening during typing get
   ignored (e.g. trailing whitespace is not allowed in folder names and previously caused an
   error to show on every typed blank).

   https://github.com/owncloud/web/issues/1906
   https://github.com/owncloud/web/pull/3240

* Enhancement - Add state to app urls: [#3294](https://github.com/owncloud/web/pull/3294)

   Currently opened file can be added to app routes so reloading the page can be made to work For now
   it's only implemented in mediaviewer

   https://github.com/owncloud/web/pull/3294

Changelog for ownCloud Web [0.7.0] (2020-03-30)
=======================================
The following sections list the changes in ownCloud web 0.7.0 relevant to
ownCloud admins and users.

[0.7.0]: https://github.com/owncloud/web/compare/v0.6.0...v0.7.0

Summary
-------

* Bugfix - Fix logout when no tokens are known anymore: [#2961](https://github.com/owncloud/web/pull/2961)
* Bugfix - Files list status indicators are now appearing without any delay: [#2973](https://github.com/owncloud/web/issues/2973)
* Bugfix - Fix file actions menu when using OCIS backend: [#3214](https://github.com/owncloud/web/issues/3214)
* Bugfix - Do not remove first character of etag: [#3274](https://github.com/owncloud/web/pull/3274)
* Change - Don't import whole core-js bundle directly into core: [#3173](https://github.com/owncloud/web/pull/3173)
* Enhancement - Added thumbnails in file list: [#276](https://github.com/owncloud/web/issues/276)

Details
-------

* Bugfix - Fix logout when no tokens are known anymore: [#2961](https://github.com/owncloud/web/pull/2961)

   Single Log Out requires the id_token and in cases where this token is no longer known calling the
   SLO endpoint will result in an error.

   This has been fixed.

   https://github.com/owncloud/web/pull/2961

* Bugfix - Files list status indicators are now appearing without any delay: [#2973](https://github.com/owncloud/web/issues/2973)

   We've stopped loading file list status indicators asynchronously to prevent them from
   appearing delayed. They appear now at the same time as the file list.

   https://github.com/owncloud/web/issues/2973
   https://github.com/owncloud/web/pull/3213

* Bugfix - Fix file actions menu when using OCIS backend: [#3214](https://github.com/owncloud/web/issues/3214)

   When using OCIS as backend, the ids of resources is a string instead of integer. So we cannot
   embed those into DOM node ids and need to use another alternative. This fix introduces a unique
   viewId which is only there to provide uniqueness across the current list and should not be used
   for any data related operation.

   This fixes the file actions menu when using OCIS as backend.

   https://github.com/owncloud/web/issues/3214
   https://github.com/owncloud/ocis-web/issues/51

* Bugfix - Do not remove first character of etag: [#3274](https://github.com/owncloud/web/pull/3274)

   When stripping away double quotes in etag of the file thumbnails, we accidentally removed
   first character as well. We've stopped removing that character.

   https://github.com/owncloud/web/pull/3274

* Change - Don't import whole core-js bundle directly into core: [#3173](https://github.com/owncloud/web/pull/3173)

   We've stopped importing whole core-js bundle directly into core and instead load only used
   parts with babel.

   https://github.com/owncloud/web/pull/3173

* Enhancement - Added thumbnails in file list: [#276](https://github.com/owncloud/web/issues/276)

   Thumbnails are now displayed in the file list for known file types. When no thumbnail was
   returned, fall back to the file type icon.

   https://github.com/owncloud/web/issues/276
   https://github.com/owncloud/web/pull/3187

Changelog for ownCloud Web [0.6.0] (2020-03-16)
=======================================
The following sections list the changes in ownCloud web 0.6.0 relevant to
ownCloud admins and users.

[0.6.0]: https://github.com/owncloud/web/compare/v0.5.0...v0.6.0

Summary
-------

* Bugfix - Indirect share info now visible in favorite and other file lists: [#3040](https://github.com/owncloud/web/issues/3040)
* Bugfix - Fixed layout of file lists: [#3100](https://github.com/owncloud/web/pull/3100)
* Bugfix - Changed share icons to collaborators icons: [#3116](https://github.com/owncloud/web/pull/3116)
* Bugfix - Sorted collaborators column, deduplicate public entry: [#3137](https://github.com/owncloud/web/issues/3137)
* Bugfix - Use end of the day in expiration date: [#3158](https://github.com/owncloud/web/pull/3158)
* Change - Moved collaborators additional info on own row and removed type row: [#3130](https://github.com/owncloud/web/pull/3130)
* Change - New sort order for collaborators and public links: [#3136](https://github.com/owncloud/web/pull/3136)
* Change - Stop support for deployment of Web as an ownCloud app: [#3162](https://github.com/owncloud/web/pull/3162)
* Change - Align columns in file lists to the right: [#3036](https://github.com/owncloud/web/issues/3036)
* Enhancement - Expiration date for collaborators: [#2543](https://github.com/owncloud/web/issues/2543)

Details
-------

* Bugfix - Indirect share info now visible in favorite and other file lists: [#3040](https://github.com/owncloud/web/issues/3040)

   When open the share panel of other flat file lists like the favorites, the collaborators list
   and link list are now showing the same entries like in the "All files" list, which includes
   indirect shares (via) that were previously missing.

   https://github.com/owncloud/web/issues/3040
   https://github.com/owncloud/web/pull/3135

* Bugfix - Fixed layout of file lists: [#3100](https://github.com/owncloud/web/pull/3100)

   A recent library update in ODS for the recycle scroller seem to have changed the logic or
   calculation of the height.

   This fix accommodates for that change and restores the row height to a correct value.

   The shared file lists are now more responsive, the collaborators/owner and share time columns
   are now hidden on small screens.

   https://github.com/owncloud/web/pull/3100

* Bugfix - Changed share icons to collaborators icons: [#3116](https://github.com/owncloud/web/pull/3116)

   Adjust icon in files app navigation bar and also in the file actions dropdown to use the group
   icon.

   https://github.com/owncloud/web/pull/3116

* Bugfix - Sorted collaborators column, deduplicate public entry: [#3137](https://github.com/owncloud/web/issues/3137)

   The collaborators column that appears in the "shared with others" section are now sorted:
   first by share type (user, group, link, remote) and then by display name using natural sort.
   Additionally, if there is more than one public link for the resource, the text "Public" only
   appears once in the collaborators column.

   https://github.com/owncloud/web/issues/3137
   https://github.com/owncloud/web/pull/3171

* Bugfix - Use end of the day in expiration date: [#3158](https://github.com/owncloud/web/pull/3158)

   We've changed the expiration date field in the collaborators list to the end of the day.

   https://github.com/owncloud/web/pull/3158

* Change - Moved collaborators additional info on own row and removed type row: [#3130](https://github.com/owncloud/web/pull/3130)

   We've moved collaborators additional info on own row under the name of collaborator and
   removed collaborator type row.

   https://github.com/owncloud/web/pull/3130

* Change - New sort order for collaborators and public links: [#3136](https://github.com/owncloud/web/pull/3136)

   We've changed the sort order for collaborators and public links. Collaborators are now sorted
   by: collaborator type, is collaborator direct, display name and creation date. Public links
   are now sorted by: is public link direct, display name and creation date.

   https://github.com/owncloud/web/pull/3136

* Change - Stop support for deployment of Web as an ownCloud app: [#3162](https://github.com/owncloud/web/pull/3162)

   We've stopped supporting deployment of Web as an ownCloud app. In the release is no longer
   available Web ownCloud 10 app package.

   https://github.com/owncloud/web/pull/3162

* Change - Align columns in file lists to the right: [#3036](https://github.com/owncloud/web/issues/3036)

   We've aligned columns in all file lists to the right so it is easier for the user to compare them.

   https://github.com/owncloud/web/issues/3036
   https://github.com/owncloud/web/pull/3163

* Enhancement - Expiration date for collaborators: [#2543](https://github.com/owncloud/web/issues/2543)

   We've added an expiration date for collaborators. Users can choose an expiration date for
   users and groups. After the date is reached the collaborator is automatically removed. Admins
   can set default expiration date or enforce it.

   https://github.com/owncloud/web/issues/2543
   https://github.com/owncloud/web/pull/3086

Changelog for ownCloud Web [0.5.0] (2020-03-02)
=======================================
The following sections list the changes in ownCloud web 0.5.0 relevant to
ownCloud admins and users.

[0.5.0]: https://github.com/owncloud/web/compare/v0.4.0...v0.5.0

Summary
-------

* Bugfix - Various fixes for files app in responsive mode: [#2998](https://github.com/owncloud/web/issues/2998)
* Bugfix - Responsive buttons layout in app bar when multiple files are selected: [#3011](https://github.com/owncloud/web/issues/3011)
* Bugfix - Fix accessible labels that said $gettext: [#3039](https://github.com/owncloud/web/pull/3039)
* Bugfix - Fix console warning about search query in public page: [#3041](https://github.com/owncloud/web/pull/3041)
* Bugfix - Moved resharers to the top of owner collaborator entry: [#3850](https://github.com/owncloud/web/issues/3850)
* Change - Moved sidebar navigation under top bar: [#3077](https://github.com/owncloud/web/pull/3077)
* Enhancement - Added ability to click file list columns for sorting: [#1854](https://github.com/owncloud/web/issues/1854)
* Enhancement - Improved collaborators column in shared file lists: [#2924](https://github.com/owncloud/web/issues/2924)
* Enhancement - Display decimals in resource size column only for MBs or higher: [#2986](https://github.com/owncloud/web/issues/2986)
* Enhancement - Different message in overwrite dialog when versioning is enabled: [#3047](https://github.com/owncloud/web/issues/3047)
* Enhancement - Current user entry in collaborators list in sidebar: [#3808](https://github.com/owncloud/web/issues/3808)

Details
-------

* Bugfix - Various fixes for files app in responsive mode: [#2998](https://github.com/owncloud/web/issues/2998)

   Fixed properly alignment of header columns with the body of the files table which stays even
   after resizing. Removed the column label for the actions column as it looks nicer.

   https://github.com/owncloud/web/issues/2998
   https://github.com/owncloud/web/pull/2999

* Bugfix - Responsive buttons layout in app bar when multiple files are selected: [#3011](https://github.com/owncloud/web/issues/3011)

   We've fixed the responsive buttons layout in files app bar when multiple files are selected
   where bulk actions where overlapping and height of the buttons was increased.

   https://github.com/owncloud/web/issues/3011
   https://github.com/owncloud/web/pull/3083

* Bugfix - Fix accessible labels that said $gettext: [#3039](https://github.com/owncloud/web/pull/3039)

   Fixed three accessible aria labels that were saying "$gettext" instead of their actual
   translated text.

   https://github.com/owncloud/web/pull/3039

* Bugfix - Fix console warning about search query in public page: [#3041](https://github.com/owncloud/web/pull/3041)

   Fixed console warning about the search query attribute not being available whenever the
   search fields are not visible, for example when accessing a public link page.

   https://github.com/owncloud/web/pull/3041

* Bugfix - Moved resharers to the top of owner collaborator entry: [#3850](https://github.com/owncloud/web/issues/3850)

   For received shares, the resharers user display names are now shown on top of the owner entry in
   the collaborators list, with a reshare icon, instead of having their own entry in the
   collaborators list.

   This makes the reshare situation more clear and removes the ambiguity about the formerly
   displayed "resharer" role which doesn't exist.

   https://github.com/owncloud/web/issues/3850

* Change - Moved sidebar navigation under top bar: [#3077](https://github.com/owncloud/web/pull/3077)

   We've adjusted the position of the sidebar navigation to be under the top bar.

   https://github.com/owncloud/web/pull/3077

* Enhancement - Added ability to click file list columns for sorting: [#1854](https://github.com/owncloud/web/issues/1854)

   The sorting mode of the file list can now be changed by clicking on the column headers.

   https://github.com/owncloud/web/issues/1854

* Enhancement - Improved collaborators column in shared file lists: [#2924](https://github.com/owncloud/web/issues/2924)

   Fixed issue with the collaborators column where only one was being displayed in the "shared
   with you" file list. This is done by properly aggregating all share entries under each file
   entry for the list, which now also includes group shares and link shares.

   Improved the look of the collaborators by adding avatars and icons there for the shares in the
   collaborators and owner columns.

   https://github.com/owncloud/web/issues/2924
   https://github.com/owncloud/web/pull/3049

* Enhancement - Display decimals in resource size column only for MBs or higher: [#2986](https://github.com/owncloud/web/issues/2986)

   We've stopped displaying decimals in resource size column for sizes smaller than 1 MB. We've
   also started displaying only one decimal.

   https://github.com/owncloud/web/issues/2986
   https://github.com/owncloud/web/pull/3051

* Enhancement - Different message in overwrite dialog when versioning is enabled: [#3047](https://github.com/owncloud/web/issues/3047)

   We've added a new message in the overwrite dialog when versioning is enabled. This message is
   intended to make it clear that the resource won't be overwritten but a new version of it will be
   created.

   https://github.com/owncloud/web/issues/3047
   https://github.com/owncloud/web/pull/3050

* Enhancement - Current user entry in collaborators list in sidebar: [#3808](https://github.com/owncloud/web/issues/3808)

   We've added a new entry into the collaborators list in sidebar which contains current user.

   https://github.com/owncloud/web/issues/3808
   https://github.com/owncloud/web/pull/3060

Changelog for ownCloud Web [0.4.0] (2020-02-14)
=======================================
The following sections list the changes in ownCloud web 0.4.0 relevant to
ownCloud admins and users.

[0.4.0]: https://github.com/owncloud/web/compare/v0.3.0...v0.4.0

Summary
-------

* Bugfix - Fix collaborator selection on new collaborator shares: [#1186](https://github.com/owncloud/web/issues/1186)
* Bugfix - Prevent loader in sidebar on add/remove: [#2937](https://github.com/owncloud/web/issues/2937)
* Bugfix - Fix issue with translate function for pending shares: [#3012](https://github.com/owncloud/web/issues/3012)
* Bugfix - Properly manage escaping of all translations: [#3032](https://github.com/owncloud/web/pull/3032)
* Change - Improve UI/UX of collaborator forms: [#1186](https://github.com/owncloud/web/issues/1186)
* Change - Display only items for current extension in sidebar menu: [#2746](https://github.com/owncloud/web/issues/2746)
* Change - Removed filter button in files list header: [#2971](https://github.com/owncloud/web/issues/2971)
* Change - File actions now always behind three dots button: [#2974](https://github.com/owncloud/web/pull/2974)
* Change - Improve ownCloud Design System (ODS): [#2989](https://github.com/owncloud/web/issues/2989)
* Change - Improve visual appearance of upload progress: [#3742](https://github.com/owncloud/enterprise/issues/3742)
* Enhancement - Add empty folder message in file list views: [#1910](https://github.com/owncloud/web/issues/1910)
* Enhancement - Fixed header for files tables: [#1952](https://github.com/owncloud/web/issues/1952)

Details
-------

* Bugfix - Fix collaborator selection on new collaborator shares: [#1186](https://github.com/owncloud/web/issues/1186)

   When typing text into the search box for new collaborators, selecting a user and a group with
   identical names was not possible. This was due to the fact that when one (group or user) got
   selected, the other was excluded because of a matching name. Fixed by including the share type
   (group or user) in matching.

   https://github.com/owncloud/web/issues/1186

* Bugfix - Prevent loader in sidebar on add/remove: [#2937](https://github.com/owncloud/web/issues/2937)

   When adding or removing a public link or collaborator, the respective list view sidebar panels
   briefly hid the panel and showed a loader instead. The UI is supposed to show a visual transition
   of a new list item into the list on adding, as well as a visual transition out of the list on
   deletion. This is fixed now by not triggering the loading state on add and remove actions
   anymore. A loading state is only meant to appear when the user navigates to the shares of another
   file/folder.

   https://github.com/owncloud/web/issues/2937
   https://github.com/owncloud/web/pull/2952

* Bugfix - Fix issue with translate function for pending shares: [#3012](https://github.com/owncloud/web/issues/3012)

   The pending shares was wrongly passing in a translation function, which caused translations
   to be missing in the error message but also it broke the general translation sync process with
   Transifex. Thanks to this change the translations will be up to date again.

   https://github.com/owncloud/web/issues/3012
   https://github.com/owncloud/web/pull/3014

* Bugfix - Properly manage escaping of all translations: [#3032](https://github.com/owncloud/web/pull/3032)

   We've stopped escaping translations which contained resource names or user names because
   they can contain special characters which were then not properly displayed. We've done this
   only with translations which are using mustache syntax which does escaping on its own so we
   don't introduce potential XSS vulnerability. For all other translations, we've explicitly
   set the escaping.

   https://github.com/owncloud/web/pull/3032

* Change - Improve UI/UX of collaborator forms: [#1186](https://github.com/owncloud/web/issues/1186)

   Applied several UI/UX improvements to the collaborator forms (adding and editing). - Showing
   avatars for selected collaborators on a new share and fixed styling/layouting of said
   collaborators in the list. - Added sensible margins on text about missing permissions for
   re-sharing in the sharing sidebar. - Fixed alignment of displayed collaborator in editing
   view for collaborators. - Removed separators from the forms that were cluttering the view. -
   Moved role description on role selection (links and collaborators) into the form element. Not
   shown below the form element anymore.

   https://github.com/owncloud/web/issues/1186

* Change - Display only items for current extension in sidebar menu: [#2746](https://github.com/owncloud/web/issues/2746)

   We've filtered out nav items in the sidebar menu. Now only items for current extension will be
   displayed. In case the extension has only one nav item, the sidebar menu is hidden and instead of
   menu button is displayed the name of extension.

   https://github.com/owncloud/web/issues/2746
   https://github.com/owncloud/web/pull/3013

* Change - Removed filter button in files list header: [#2971](https://github.com/owncloud/web/issues/2971)

   Removed the confusing filter button in the files list header, so the following are now removed
   as well: - ability to toggle files and folders visibility which wasn't that useful and not
   really a requirement - filter text box as it is is redundant as one can already use the global
   search box - ability to hide dot files, we'll look into providing this again in the future with an
   improved UI

   https://github.com/owncloud/web/issues/2971

* Change - File actions now always behind three dots button: [#2974](https://github.com/owncloud/web/pull/2974)

   The inline file actions button didn't look very nice and made the UI look cluttered. This change
   hides them behind a three dots button on the line, the same that was already visible in
   responsive mode. The three dots button also now has no more border and looks nicer.

   https://github.com/owncloud/web/issues/2998
   https://github.com/owncloud/web/pull/2974

* Change - Improve ownCloud Design System (ODS): [#2989](https://github.com/owncloud/web/issues/2989)

   During the work on this release, there have been several changes in ODS which directly affect
   Web. - Proper text truncate in breadcrumb component. This fixes the mobile view of the current
   folder breadcrumb in the top bar. - New icon sizes `xlarge` and `xxlarge` in oc-icon component.
   Those are used for the `No content` messages e.g. when navigating to an empty folder. - Provide
   new icon size `xsmall` and align spinner-sizes with icon-sizes. The `xsmall` icon size turned
   out to be prettier in some places. The size alignments fixed layout glitches when removing
   collaborators or public links. - Fix aria label on spinner in oc-autocomplete. Warning were
   cluttering the JavaScript console when adding collaborators. - Reset input on selection in
   oc-autocomplete, when `fillOnSelection=false`. This makes sure that when a new
   collaborator has been selected, the search input field goes back to being blank for a new
   search.

   https://github.com/owncloud/web/issues/2989
   https://github.com/owncloud/owncloud-design-system/pull/630
   https://github.com/owncloud/owncloud-design-system/pull/632
   https://github.com/owncloud/owncloud-design-system/pull/633
   https://github.com/owncloud/owncloud-design-system/pull/634
   https://github.com/owncloud/owncloud-design-system/pull/635

* Change - Improve visual appearance of upload progress: [#3742](https://github.com/owncloud/enterprise/issues/3742)

   - Changed the layout of the upload progress to be a narrow standalone full width row below the app
   top bar. - Transformed textual information into a single row below the progress bar and made it
   very clear that it can be clicked to show upload progress details. - Changed layout of upload
   progress details list items, so that the progress bars always have the same width. - Changed
   visuals of all progress bars in upload context to have a narrow outline and the percentage
   numbers inside of the progress bars. - Fixed the calculation of the overall upload progress to
   be weighted by file sizes instead of just adding up percentages and dividing by number of
   uploads.

   https://github.com/owncloud/enterprise/issues/3742

* Enhancement - Add empty folder message in file list views: [#1910](https://github.com/owncloud/web/issues/1910)

   Whenever a folder contains no entries in any of the file list views, a message is now shown
   indicating that the folder is empty, or that there are no favorites, etc.

   https://github.com/owncloud/web/issues/1910
   https://github.com/owncloud/web/pull/2975

* Enhancement - Fixed header for files tables: [#1952](https://github.com/owncloud/web/issues/1952)

   We've made the header of files tables fixed so it is easier to know the meaning of table columns.

   https://github.com/owncloud/web/issues/1952
   https://github.com/owncloud/web/pull/2995

Changelog for ownCloud Web [0.3.0] (2020-01-31)
=======================================
The following sections list the changes in ownCloud web 0.3.0 relevant to
ownCloud admins and users.

[0.3.0]: https://github.com/owncloud/web/compare/v0.2.7...v0.3.0

Summary
-------

* Bugfix - Transform route titles into real h1 headings: [#2681](https://github.com/owncloud/web/pull/2681)
* Bugfix - Prevent jumpy behavior when loading user avatars: [#2921](https://github.com/owncloud/web/issues/2921)
* Change - Bring UI/UX of file links sidebar in line with sharing sidebar: [#1907](https://github.com/owncloud/web/issues/1907)
* Change - Join users and groups into a single list in collaborators sidebar: [#2900](https://github.com/owncloud/web/issues/2900)
* Change - Adjusted labels in files list: [#2902](https://github.com/owncloud/web/pull/2902)
* Enhancement - Add share indicator for direct and indirect shares in file list: [#2060](https://github.com/owncloud/web/issues/2060)
* Enhancement - Add files list status indicators extension point: [#2895](https://github.com/owncloud/web/issues/2895)
* Enhancement - Add theme option to disable default files list status indicators: [#2895](https://github.com/owncloud/web/issues/2895)
* Enhancement - Show indirect outgoing shares in shares panel: [#2897](https://github.com/owncloud/web/issues/2897)
* Enhancement - Add owner and resharer in collaborators list: [#2898](https://github.com/owncloud/web/issues/2898)

Details
-------

* Bugfix - Transform route titles into real h1 headings: [#2681](https://github.com/owncloud/web/pull/2681)

   We transformed spans that held the page title to h1 elements. In the case of the file list, a h1 is
   existing for accessibility reasons but can only be perceived via a screen reader.

   https://github.com/owncloud/web/pull/2681

* Bugfix - Prevent jumpy behavior when loading user avatars: [#2921](https://github.com/owncloud/web/issues/2921)

   When loading a user avatar, the container size was smaller so as soon as the avatar was loaded, it
   resulted in jumpy behavior. This is fixed now by applying the same size to the loading spinner
   element.

   https://github.com/owncloud/web/issues/2921
   https://github.com/owncloud/web/pull/2927

* Change - Bring UI/UX of file links sidebar in line with sharing sidebar: [#1907](https://github.com/owncloud/web/issues/1907)

   We adapted the UI/UX of the file links sidebar to be in line with the UI/UX of the collaborators
   sidebar. The order of the two sidebars has been reversed (collaborators first, file links
   second). We added info messages to support a clear understanding of the purpose of both private
   and public links. Most notably the file links sidebar has no inline forms anymore.

   https://github.com/owncloud/web/issues/1907
   https://github.com/owncloud/web/issues/1307
   https://github.com/owncloud/web/pull/2841
   https://github.com/owncloud/web/pull/2917

* Change - Join users and groups into a single list in collaborators sidebar: [#2900](https://github.com/owncloud/web/issues/2900)

   Users and groups were shown as two separate lists (users, then groups) in the collaborators
   sidebar. This separation is now removed, i.e. there is only one list with all collaborators,
   sorted by display name (lower case, ascending). On equal names groups are shown first.

   https://github.com/owncloud/web/issues/2900

* Change - Adjusted labels in files list: [#2902](https://github.com/owncloud/web/pull/2902)

   Renamed "Modification time" to "Updated" to make it look less technical. Replace "Create new"
   with "New" in the "New" menu as it makes it look less cluttered when trying to spot a matching
   entry.

   https://github.com/owncloud/web/pull/2902
   https://github.com/owncloud/web/pull/2905

* Enhancement - Add share indicator for direct and indirect shares in file list: [#2060](https://github.com/owncloud/web/issues/2060)

   We've added the ability for the user to directly see whether a resource is shared in the file
   list. For this, share indicators in the form of a group icon and link icon will appear in a new
   column near the shared resource. The blue color of an icon tells whether outgoing shares exist
   directly on the resource. The grey color of an icon tells that incoming or outgoing shares exist
   on any of the parent folders.

   https://github.com/owncloud/web/issues/2060
   https://github.com/owncloud/web/issues/2894
   https://github.com/owncloud/web/pull/2877

* Enhancement - Add files list status indicators extension point: [#2895](https://github.com/owncloud/web/issues/2895)

   We've added the ability for the extension to inject custom status indicator into files list.
   New indicators will then appear next to the default one.

   https://github.com/owncloud/web/issues/2895
   https://github.com/owncloud/web/pull/2928

* Enhancement - Add theme option to disable default files list status indicators: [#2895](https://github.com/owncloud/web/issues/2895)

   We've added the option into the theme to disable default files list status indicators.

   https://github.com/owncloud/web/issues/2895
   https://github.com/owncloud/web/pull/2928

* Enhancement - Show indirect outgoing shares in shares panel: [#2897](https://github.com/owncloud/web/issues/2897)

   Whenever outgoing shares exist on any parent resource from the currently viewed resource, the
   shares panel will now show these outgoing shares with a link to jump to the matching parent
   resource. This applies to both indirect collaborators shares and also to indirect public link
   shares.

   https://github.com/owncloud/web/issues/2897
   https://github.com/owncloud/web/pull/2929
   https://github.com/owncloud/web/pull/2932

* Enhancement - Add owner and resharer in collaborators list: [#2898](https://github.com/owncloud/web/issues/2898)

   The top of the collaborators list now display new entries for the resource owner and the
   resharer when applicable, and also visible when viewing a child resource of a shared folder
   (indirect share).

   https://github.com/owncloud/web/issues/2898
   https://github.com/owncloud/web/pull/2915
   https://github.com/owncloud/web/pull/2918

Changelog for ownCloud Web [0.2.7] (2020-01-14)
=======================================
The following sections list the changes in ownCloud web 0.2.7 relevant to
ownCloud admins and users.

[0.2.7]: https://github.com/owncloud/web/compare/v0.2.6...v0.2.7

Summary
-------

* Bugfix - Display files list only if there is at least one item: [#2745](https://github.com/owncloud/web/issues/2745)
* Bugfix - Register store which is imported instead of required: [#2837](https://github.com/owncloud/web/issues/2837)
* Enhancement - Internal links in app switcher: [#2838](https://github.com/owncloud/web/issues/2838)

Details
-------

* Bugfix - Display files list only if there is at least one item: [#2745](https://github.com/owncloud/web/issues/2745)

   Vue virtual scroll was throwing an error in console in case that the files list was empty. We
   prevent this error by displaying the files list only if there is at least one item.

   https://github.com/owncloud/web/issues/2745

* Bugfix - Register store which is imported instead of required: [#2837](https://github.com/owncloud/web/issues/2837)

   As some extensions export store not as a module we need to handle that case as well.

   https://github.com/owncloud/web/issues/2837

* Enhancement - Internal links in app switcher: [#2838](https://github.com/owncloud/web/issues/2838)

   In case extensions integrates itself into Phoenix core and not as own SPA we need to handle the
   navigation via router-link inside of Web core SPA.

   https://github.com/owncloud/web/issues/2838

## [0.2.6]
### Added
- Skip to component, id attribute for <main> https://github.com/owncloud/web/pull/2326
- Focus management regarding off canvas main nav https://github.com/owncloud/web/pull/2101
- Publish docker on tag https://github.com/owncloud/web/pull/2485
- New collaborators flow https://github.com/owncloud/web/pull/2450
- Hide quota on external storage https://github.com/owncloud/web/pull/2652
- Focus management for uploads https://github.com/owncloud/web/pull/2542
- File actions can be defined using config settings https://github.com/owncloud/web/pull/2651
- Files table virtual scroller https://github.com/owncloud/web/pull/2280
- Virtual scroll in trash bin https://github.com/owncloud/web/pull/2809

### Fixed
- Wrong method for copy action of public link https://github.com/owncloud/web/pull/2363
- Token refresh flow https://github.com/owncloud/web/pull/2472
- App tar balls need to contain top level folder named like the app itself https://github.com/owncloud/web/pull/2449
- Scroll behavior on mozilla firefox https://github.com/owncloud/web/pull/2475
- Steps order on release/publish https://github.com/owncloud/web/pull/2491
- Don't re-filter autocomplete collaborators results for remote user https://github.com/owncloud/web/pull/2569
- Limit concurrent uploads to one https://github.com/owncloud/web/pull/2653
- Extend share id check in public links https://github.com/owncloud/web/pull/2494
- Made the trashbin table responsive https://github.com/owncloud/web/pull/2287
- Hide checkbox label in files list https://github.com/owncloud/web/pull/2680
- Share flow accessibility https://github.com/owncloud/web/pull/2622
- Remove empty parentheses in shared with others list https://github.com/owncloud/web/pull/2725
- Do not hide collaborator if another entry with the same name exists if they are not the same type https://github.com/owncloud/web/pull/2724
- Display breadcrumb if rootFolder is set with no value https://github.com/owncloud/web/pull/2811
- Include avatar placeholder in relevant places https://github.com/owncloud/web/pull/2783

### Changed
- Decouple base file list into a separate component https://github.com/owncloud/web/pull/2318
- Switched the storage of the auth service from local to session storage https://github.com/owncloud/web/pull/2416
- Don't build the docker image in the release make file https://github.com/owncloud/web/pull/2495
- Use owncloud-sdk for uploading files https://github.com/owncloud/web/pull/2239
- Refactor collaborators to use helper classes and to map permissions https://github.com/owncloud/web/pull/2373
- Moved private link icon to "links" section https://github.com/owncloud/web/pull/2496
- Separate app switcher from app navigation sidebar https://github.com/owncloud/web/pull/2669

## [0.2.5]
### Added
- IE11 support https://github.com/owncloud/web/pull/2082
- Draw.io app integration https://github.com/owncloud/web/pull/2083
- New file menu entries for different file types https://github.com/owncloud/web/pull/2111
- Drone starlark https://github.com/owncloud/web/pull/2112
- Rename and delete will be disallowed in case the parent folder has no permissions fot these two operations https://github.com/owncloud/web/pull/2129
- Progress bar for upload https://github.com/owncloud/web/pull/2176
- Handle errors while deleting and renaming files https://github.com/owncloud/web/pull/2177
- Logout option on access denied page https://github.com/owncloud/web/pull/2178
- Download feedback spinner https://github.com/owncloud/web/pull/2179
- Remove rootFolder from breadcrumbs https://github.com/owncloud/web/pull/2196
- Send header X-Requested-With: XMLHttpRequest in all requests https://github.com/owncloud/web/pull/2197
- X-Frame-Options and Content-Security-Policy https://github.com/owncloud/web/pull/2311

### Fixed
- IE11 support for media viewer app https://github.com/owncloud/web/pull/2086
- Files drop when link password is set https://github.com/owncloud/web/pull/2096
- Detection of public pages despite existing auth https://github.com/owncloud/web/pull/2097
- Public link access in incognito mode https://github.com/owncloud/web/pull/2110
- Password handling in public links https://github.com/owncloud/web/pull/2117
- More close options to file actions menu https://github.com/owncloud/web/pull/2161
- Reset search value on clear action https://github.com/owncloud/web/pull/2198
- Prevent duplicate token refresh calls https://github.com/owncloud/web/pull/2205
- Use PQueue to run only one create folder promise in folder upload https://github.com/owncloud/web/pull/2210
- Upon token refresh do not perform full login on sdk level https://github.com/owncloud/web/pull/2211
- Exit link on access denied page https://github.com/owncloud/web/pull/2220
- Structure of folders in folder upload https://github.com/owncloud/web/pull/2224
- Remove file from progress after download on IE11 https://github.com/owncloud/web/pull/2310
- Properly reset capabilities on logout https://github.com/owncloud/web/pull/2116

### Changed
- For mounted folders use the full url as private link https://github.com/owncloud/web/pull/2170
- Store route in vuex before login in case user is unauthorized https://github.com/owncloud/web/pull/2170
- Use currentFolder path in breadcrumbs https://github.com/owncloud/web/pull/2196
- Switch to show instead of if in upload progress bar https://github.com/owncloud/web/pull/2206
- Key of file action buttons to ariaLabel https://github.com/owncloud/web/pull/2219
- Trigger add to progress before the folders creation https://github.com/owncloud/web/pull/2221
- Handle remove from progress in its own mutation https://github.com/owncloud/web/pull/2225
- Use oidc-client 1.9.1 https://github.com/owncloud/web/pull/2261

### Security
- Added sanitization to markdown editor app https://github.com/owncloud/web/pull/2233

### Removed
- Drag and drop in ie11 because of compatibility issues https://github.com/owncloud/web/pull/2128

## [0.2.4]
### Added
- Private link for the current folder to the app bar https://github.com/owncloud/web/pull/2009

### Fixed
- Clear state in case of error in authorisation https://github.com/owncloud/web/pull/2079
- Hide comma before mdate if there is no size https://github.com/owncloud/web/pull/2073
- Don't perform OIDC logout in case of error in authorisation https://github.com/owncloud/web/pull/2072


### Changed
- Use sharetype keys that are human readable instead of number https://github.com/owncloud/web/pull/2071

## [0.2.3]
### Added
- Set X-Requested-With header - required ownCloud 10.3 https://github.com/owncloud/web/pull/1984
- Use 2 spaces instead of tab for feature files https://github.com/owncloud/web/pull/2004
- Handle OAuth/OpenIdConnect error in callback request query string https://github.com/owncloud/web/pull/2011
- Enable loading apps from external sites https://github.com/owncloud/web/pull/1986
- Add default client side sort https://github.com/owncloud/web/pull/1972

### Fixed
- Public link permissions mix up https://github.com/owncloud/web/pull/1985
- Downgrade vuex-persist to 2.0.1 to fix IE11 issues https://github.com/owncloud/web/pull/2007

## [0.2.2]
### Added
- Show error message when user tries to upload a folder in IE11 https://github.com/owncloud/web/pull/1956
- Error message if the folder or file name is empty in create dialog and added default value https://github.com/owncloud/web/pull/1938
- Bookmarks to menu https://github.com/owncloud/web/pull/1949

### Fixed
- Redirect to access denied page if the user doesn't have access to Web instance https://github.com/owncloud/web/pull/1939
- Redirect to private link after user has logged in https://github.com/owncloud/web/pull/1900
- Breaking of link to help desk on new line https://github.com/owncloud/web/pull/1940

## [0.2.1]
### Added
- Download feedback https://github.com/owncloud/web/pull/1895

### Fixed
- Download of files shared with password-protected public links https://github.com/owncloud/web/issues/1808
- Search button on mobile devices https://github.com/owncloud/web/pull/1893
- Collapsing of alert messages after they have been closed https://github.com/owncloud/web/pull/1881

## [0.2.0]
### Added
- Collaborators (replacement for shares)
- Public and private links
- Shared with me and Shared with others lists
- Favorites page
- Trash bin page

## [0.1.0]
### Added
- Initial early alpha release

[Unreleased]: https://github.com/owncloud/web/compare/0.1.0...master
[0.1.0]: https://github.com/owncloud/web/compare/d1cfc2d5f82202ac30c91e903e4810f42650c183...0.1.0
