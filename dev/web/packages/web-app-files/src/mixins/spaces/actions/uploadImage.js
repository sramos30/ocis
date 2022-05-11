import { mapActions, mapGetters, mapMutations, mapState } from 'vuex'
import { clientService } from 'web-pkg/src/services'
import { bus } from 'web-pkg/src/instance'
import { thumbnailService } from '../../../services'

export default {
  data: function () {
    return {
      $_uploadImage_selectedSpace: null
    }
  },
  computed: {
    ...mapState('Files', ['currentFolder']),
    ...mapGetters(['configuration']),
    $_uploadImage_items() {
      return [
        {
          name: 'upload-space-image',
          icon: 'image-add',
          handler: this.$_uploadImage_trigger,
          label: () => {
            return this.$gettext('Edit image')
          },
          isEnabled: ({ resources }) => {
            if (resources.length !== 1) {
              return false
            }

            return resources[0].canEditImage({ user: this.user })
          },
          componentType: 'oc-button',
          class: 'oc-files-actions-upload-space-image-trigger'
        }
      ]
    }
  },
  methods: {
    ...mapMutations('Files', ['UPDATE_RESOURCE_FIELD']),
    ...mapActions(['showMessage']),
    $_uploadImage_trigger({ resources }) {
      if (resources.length !== 1) {
        return
      }

      this.$data.$_uploadImage_selectedSpace = resources[0]
      this.$refs.spaceImageInput.click()
    },
    $_uploadImage_uploadImageSpace(ev) {
      const graphClient = clientService.graphAuthenticated(this.configuration.server, this.getToken)
      const file = ev.currentTarget.files[0]

      if (!file) {
        return
      }

      if (!thumbnailService.isMimetypeSupported(file.type, true)) {
        return this.showMessage({
          title: this.$gettext('The file type is unsupported'),
          status: 'danger'
        })
      }

      const extraHeaders = {}
      if (file.lastModifiedDate) {
        extraHeaders['X-OC-Mtime'] = '' + file.lastModifiedDate.getTime() / 1000
      } else if (file.lastModified) {
        extraHeaders['X-OC-Mtime'] = '' + file.lastModified / 1000
      }

      return this.$client.files
        .putFileContents(
          `/spaces/${this.$data.$_uploadImage_selectedSpace.id}/.space/${file.name}`,
          file,
          {
            headers: extraHeaders,
            overwrite: true
          }
        )
        .then((image) => {
          return graphClient.drives
            .updateDrive(
              this.$data.$_uploadImage_selectedSpace.id,
              {
                special: [
                  {
                    specialFolder: {
                      name: 'image'
                    },
                    id: image['OC-FileId']
                  }
                ]
              },
              {}
            )
            .then(({ data }) => {
              this.UPDATE_RESOURCE_FIELD({
                id: this.$data.$_uploadImage_selectedSpace.id,
                field: 'spaceImageData',
                value: data.special.find((special) => special.specialFolder.name === 'image')
              })
              this.showMessage({
                title: this.$gettext('Space image was uploaded successfully')
              })
              bus.publish('app.files.list.load')
            })
        })
        .catch((error) => {
          console.error(error)
          this.showMessage({
            title: this.$gettext('Failed to upload space image'),
            status: 'danger'
          })
        })
    }
  }
}
