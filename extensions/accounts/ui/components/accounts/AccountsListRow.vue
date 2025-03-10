<template>
  <oc-tr>
    <oc-td align-h="center">
      <oc-checkbox
        class="oc-ml-s"
        size="large"
        :value="selectedAccounts"
        :option="account"
        @input="TOGGLE_SELECTION_ACCOUNT(account)"
        :label="selectAccountLabel"
        hide-label
      />
    </oc-td>
    <oc-td>
      <avatar
        :user-name="account.displayName || account.onPremisesSamAccountName"
        :userid="account.id"
        :width="35"
      />
    </oc-td>
    <oc-td v-text="account.onPremisesSamAccountName" />
    <oc-td v-text="account.displayName || '-'" />
    <oc-td v-text="account.mail" />
    <oc-td>
      <oc-button
        :id="`accounts-roles-select-trigger-${account.id}`"
        class="accounts-roles-select-trigger"
        appearance="outline"
      >
        <span class="oc-flex oc-flex-middle accounts-roles-current-role">
          {{ currentRole ? currentRole.displayName : $gettext("Select role") }}
          <oc-icon name="arrow-down-s" aria-hidden="true" />
        </span>
      </oc-button>
      <oc-drop
        :drop-id="`accounts-roles-select-dropdown-${account.id}`"
        :toggle="`#accounts-roles-select-trigger-${account.id}`"
        mode="click"
        close-on-click
        :options="{ delayHide: 0 }"
      >
        <ul class="oc-list">
          <li v-for="role in roles" :key="role.id">
            <oc-radio
              class="accounts-roles-dropdown-role"
              v-model="currentRole"
              :option="role"
              @input="changeRole(role.id)"
              :label="role.displayName"
            />
          </li>
        </ul>
      </oc-drop>
    </oc-td>
    <oc-td align-h="center">
      <oc-icon
        v-if="account.accountEnabled"
        key="account-icon-enabled"
        name="user-follow"
        variation="success"
        :aria-label="$gettext('Account is activated')"
        class="accounts-status-indicator-enabled"
      />
      <oc-icon
        v-else
        key="account-icon-disabled"
        name="user-unfollow"
        variation="danger"
        :aria-label="$gettext('Account is blocked')"
        class="accounts-status-indicator-disabled"
      />
    </oc-td>
  </oc-tr>
</template>

<script>
import { mapGetters, mapState, mapActions, mapMutations } from 'vuex'
import { isObjectEmpty } from '../../helpers/utils'
import { injectAuthToken } from '../../helpers/auth'
// eslint-disable-next-line camelcase
import { RoleService_AssignRoleToUser, RoleService_ListRoleAssignments } from '../../client/settings'
import Avatar from './Avatar.vue'

export default {
  name: 'AccountsListRow',

  components: { Avatar },

  props: {
    account: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      currentRole: null
    }
  },

  computed: {
    ...mapGetters(['user', 'getServerForJsClient']),
    ...mapState('Accounts', ['roles', 'selectedAccounts']),

    selectAccountLabel () {
      const translated = this.$gettext('Select %{ account }')

      return this.$gettextInterpolate(translated, { account: this.account.displayName }, true)
    }
  },

  created () {
    this.getUsersCurrentRole()
  },

  methods: {
    ...mapActions(['showMessage']),
    ...mapMutations('Accounts', ['TOGGLE_SELECTION_ACCOUNT']),

    async changeRole (roleId) {
      injectAuthToken(this.user.token)

      const response = await RoleService_AssignRoleToUser({
        $domain: this.getServerForJsClient,
        body: {
          account_uuid: this.account.id,
          role_id: roleId
        }
      })

      if (response.status === 201) {
        const roleId = response.data.assignment.roleId
        this.currentRole = this.roles.find(role => {
          return role.id === roleId
        })
      } else {
        this.showMessage({
          title: this.$gettext('Failed to change role.'),
          desc: response.statusText,
          status: 'danger'
        })
      }
    },

    async getUsersCurrentRole () {
      injectAuthToken(this.user.token)

      const response = await RoleService_ListRoleAssignments({
        $domain: this.getServerForJsClient,
        body: {
          account_uuid: this.account.id
        }
      })

      if (response.status === 201) {
        const assignedRole = response.data

        if (isObjectEmpty(assignedRole)) {
          return
        }

        this.currentRole = this.roles.find(role => {
          return role.id === assignedRole.assignments[0].roleId
        })
      }
    }
  }
}
</script>
