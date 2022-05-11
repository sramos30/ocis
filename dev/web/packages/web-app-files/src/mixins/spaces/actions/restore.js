import { mapActions, mapGetters, mapMutations, mapState } from 'vuex'
import { clientService } from 'web-pkg/src/services'

export default {
  computed: {
    ...mapGetters(['configuration', 'getToken']),
    ...mapState(['user']),

    $_restore_items() {
      return [
        {
          name: 'restore',
          icon: 'play-circle',
          label: () => {
            return this.$gettext('Enable')
          },
          handler: this.$_restore_trigger,
          isEnabled: ({ resources }) => {
            if (resources.length !== 1) {
              return false
            }

            return resources[0].canRestore({ user: this.user })
          },
          componentType: 'oc-button',
          class: 'oc-files-actions-restore-trigger'
        }
      ]
    }
  },
  methods: {
    ...mapActions([
      'createModal',
      'hideModal',
      'setModalInputErrorMessage',
      'showMessage',
      'toggleModalConfirmButton'
    ]),
    ...mapMutations('Files', ['UPDATE_RESOURCE_FIELD']),

    $_restore_trigger({ resources }) {
      if (resources.length !== 1) {
        return
      }

      const modal = {
        variation: 'passive',
        title: this.$gettext('Restore space') + ' ' + resources[0].name,
        cancelText: this.$gettext('Cancel'),
        confirmText: this.$gettext('Restore'),
        icon: 'alarm-warning',
        message: this.$gettext('Are you sure you want to restore this space?'),
        hasInput: false,
        onCancel: this.hideModal,
        onConfirm: () => this.$_restore_restoreSpace(resources[0].id)
      }

      this.createModal(modal)
    },

    $_restore_restoreSpace(id) {
      const graphClient = clientService.graphAuthenticated(this.configuration.server, this.getToken)
      return graphClient.drives
        .updateDrive(
          id,
          {},
          {
            headers: {
              Restore: true
            }
          }
        )
        .then(() => {
          this.hideModal()
          this.UPDATE_RESOURCE_FIELD({
            id,
            field: 'disabled',
            value: false
          })
          this.showMessage({
            title: this.$gettext('Space was restored successfully')
          })
        })
        .catch((error) => {
          console.error(error)
          this.showMessage({
            title: this.$gettext('Failed to restore space'),
            status: 'danger'
          })
        })
    }
  }
}
