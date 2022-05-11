import {
  isLocationCommonActive,
  isLocationPublicActive,
  isLocationSpacesActive
} from '../../router'
import isFilesAppActive from './helpers/isFilesAppActive'
import path from 'path'
import first from 'lodash-es/first'
import { archiverService } from '../../services'

export default {
  mixins: [isFilesAppActive],
  computed: {
    $_downloadArchive_items() {
      return [
        {
          name: 'download-archive',
          icon: 'inbox-archive',
          handler: this.$_downloadArchive_trigger,
          label: () => {
            return this.$gettext('Download')
          },
          isEnabled: ({ resources }) => {
            if (
              this.$_isFilesAppActive &&
              !isLocationSpacesActive(this.$router, 'files-spaces-personal-home') &&
              !isLocationSpacesActive(this.$router, 'files-spaces-project') &&
              !isLocationPublicActive(this.$router, 'files-public-files') &&
              !isLocationCommonActive(this.$router, 'files-common-favorites')
            ) {
              return false
            }
            if (resources.length === 0) {
              return false
            }
            if (resources.length === 1 && !resources[0].isFolder) {
              return false
            }
            if (!archiverService.available) {
              return false
            }
            if (
              !archiverService.fileIdsSupported &&
              isLocationCommonActive(this.$router, 'files-common-favorites')
            ) {
              return false
            }
            const downloadDisabled = resources.some((resource) => {
              return !resource.canDownload()
            })
            return !downloadDisabled
          },
          canBeDefault: true,
          componentType: 'oc-button',
          class: 'oc-files-actions-download-archive-trigger'
        }
      ]
    }
  },
  methods: {
    async $_downloadArchive_trigger({ resources }) {
      const fileOptions = archiverService.fileIdsSupported
        ? {
            fileIds: resources.map((resource) => resource.fileId)
          }
        : {
            dir: path.dirname(first(resources).path) || '/',
            files: resources.map((resource) => resource.name)
          }
      await archiverService
        .triggerDownload({
          ...fileOptions,
          ...(isLocationPublicActive(this.$router, 'files-public-files') && {
            publicToken: this.$route.params.item.split('/')[0]
          })
        })
        .catch((e) => {
          console.error(e)
          this.showMessage({
            title: this.$ngettext(
              'Failed to download the selected folder.', // on single selection only available for folders
              'Failed to download the selected files.', // on multi selection available for files+folders
              this.selectedFiles.length
            ),
            status: 'danger'
          })
        })
    }
  }
}
