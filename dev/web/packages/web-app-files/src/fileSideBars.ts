import FileDetails from './components/SideBar/Details/FileDetails.vue'
import FileDetailsMultiple from './components/SideBar/Details/FileDetailsMultiple.vue'
import FileActions from './components/SideBar/Actions/FileActions.vue'
import FileVersions from './components/SideBar/Versions/FileVersions.vue'
import FileShares from './components/SideBar/Shares/FileShares.vue'
import FileLinks from './components/SideBar/Links/FileLinks.vue'
import NoSelection from './components/SideBar/NoSelection.vue'
import SpaceActions from './components/SideBar/Actions/SpaceActions.vue'
import SpaceDetails from './components/SideBar/Details/SpaceDetails.vue'
import SpaceShares from './components/SideBar/Shares/SpaceShares.vue'
import { isLocationSpacesActive, isLocationTrashActive, isLocationPublicActive } from './router'
import { spaceRoleEditor, spaceRoleManager } from './helpers/share'
import { Panel } from '../../web-pkg/src/components/sidebar'

import { Resource } from './helpers/resource'
import { User } from './helpers/user'
import Router from 'vue-router'

function $gettext(msg: string): string {
  return msg
}

const panelGenerators: (({
  rootFolder,
  highlightedFile,
  router,
  multipleSelection,
  user,
  capabilities
}: {
  rootFolder: boolean
  highlightedFile: Resource
  router: Router
  multipleSelection: boolean
  user: User
  capabilities: any
}) => Panel)[] = [
  // We don't have file details in the trashbin, yet.
  // Only allow `actions` panel on trashbin route for now.
  ({ rootFolder, highlightedFile }): Panel => ({
    app: 'no-selection-item',
    icon: 'questionnaire-line',
    title: $gettext('Details'),
    component: NoSelection,
    default: () => true,
    get enabled() {
      return rootFolder && highlightedFile?.type !== 'space'
    }
  }),
  ({ router, multipleSelection, rootFolder }) => ({
    app: 'details-item',
    icon: 'questionnaire-line',
    title: $gettext('Details'),
    component: FileDetails,
    default:
      !isLocationTrashActive(router, 'files-trash-personal') &&
      !isLocationTrashActive(router, 'files-trash-spaces-project'),
    get enabled() {
      return (
        !isLocationTrashActive(router, 'files-trash-personal') &&
        !isLocationTrashActive(router, 'files-trash-spaces-project') &&
        !multipleSelection &&
        !rootFolder
      )
    }
  }),
  ({ multipleSelection, rootFolder }) => ({
    app: 'details-multiple-item',
    icon: 'questionnaire-line',
    title: $gettext('Details'),
    component: FileDetailsMultiple,
    default: () => true,
    get enabled() {
      return multipleSelection && !rootFolder
    }
  }),
  ({ router, highlightedFile }) => ({
    app: 'details-space-item',
    icon: 'questionnaire-line',
    title: $gettext('Details'),
    component: SpaceDetails,
    default: isLocationSpacesActive(router, 'files-spaces-projects'),
    get enabled() {
      return highlightedFile?.type === 'space'
    }
  }),
  ({ router, multipleSelection, rootFolder }) => ({
    app: 'actions-item',
    icon: 'slideshow-3',
    title: $gettext('Actions'),
    component: FileActions,
    default:
      isLocationTrashActive(router, 'files-trash-personal') ||
      isLocationTrashActive(router, 'files-trash-spaces-project'),
    get enabled() {
      return !multipleSelection && !rootFolder
    }
  }),
  ({ highlightedFile, user }) => ({
    app: 'space-actions-item',
    icon: 'slideshow-3',
    title: $gettext('Actions'),
    component: SpaceActions,
    get enabled() {
      if (highlightedFile?.type !== 'space') {
        return false
      }
      return [
        ...highlightedFile.spaceRoles[spaceRoleManager.name],
        ...highlightedFile.spaceRoles[spaceRoleEditor.name]
      ].includes(user.uuid)
    }
  }),
  ({ capabilities, router, multipleSelection, rootFolder }) => ({
    app: 'sharing-item',
    icon: 'group',
    title: $gettext('People'),
    component: FileShares,
    get enabled() {
      if (multipleSelection || rootFolder) return false
      if (
        isLocationTrashActive(router, 'files-trash-personal') ||
        isLocationTrashActive(router, 'files-trash-spaces-project') ||
        isLocationPublicActive(router, 'files-public-files')
      ) {
        return false
      }

      if (capabilities.files_sharing) {
        return capabilities.files_sharing.api_enabled
      }
      return false
    }
  }),
  ({ highlightedFile }) => ({
    app: 'space-share-item',
    icon: 'group',
    title: $gettext('Members'),
    component: SpaceShares,
    get enabled() {
      return highlightedFile?.type === 'space'
    }
  }),
  ({ capabilities, router, multipleSelection, rootFolder, highlightedFile }) => ({
    app: 'links-item',
    icon: 'link',
    title: $gettext('Links'),
    component: FileLinks,
    get enabled() {
      if (multipleSelection || (rootFolder && highlightedFile?.type !== 'space')) return false
      if (
        isLocationTrashActive(router, 'files-trash-personal') ||
        isLocationTrashActive(router, 'files-trash-spaces-project') ||
        isLocationPublicActive(router, 'files-public-files')
      ) {
        return false
      }

      if (capabilities.files_sharing) {
        return capabilities.files_sharing.public.enabled
      }
      return false
    }
  }),
  ({ capabilities, highlightedFile, router, multipleSelection, rootFolder }) => ({
    app: 'versions-item',
    icon: 'git-branch',
    title: $gettext('Versions'),
    component: FileVersions,
    get enabled() {
      if (multipleSelection || rootFolder) return false
      if (
        isLocationTrashActive(router, 'files-trash-personal') ||
        isLocationTrashActive(router, 'files-trash-spaces-project') ||
        isLocationPublicActive(router, 'files-public-files')
      ) {
        return false
      }
      return !!capabilities.core && highlightedFile && highlightedFile.type !== 'folder'
    }
  })
]

export default panelGenerators
