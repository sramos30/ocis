/* eslint-disable camelcase */
import { AccountsService_ListAccounts, AccountsService_UpdateAccount } from '../client/accounts'
import { RoleService_ListRoles } from '../client/settings'
/* eslint-enable camelcase */
import { injectAuthToken } from '../helpers/auth'

const state = {
  config: null,
  initialized: false,
  accounts: {},
  roles: null,
  selectedAccounts: []
}

const getters = {
  config: state => state.config,
  isInitialized: state => state.initialized,
  getAccountsSorted: state => {
    return Object.values(state.accounts).sort((a1, a2) => {
      if (a1.onPremisesSamAccountName === a2.onPremisesSamAccountName) {
        return a1.id.localeCompare(a2.id)
      }
      return a1.onPremisesSamAccountName.localeCompare(a2.onPremisesSamAccountName)
    })
  },
  areAllAccountsSelected: state => state.accounts.length === state.selectedAccounts.length
}

const mutations = {
  LOAD_CONFIG (state, config) {
    state.config = config
  },
  SET_INITIALIZED (state, value) {
    state.initialized = value
  },
  SET_ACCOUNTS (state, accounts) {
    state.accounts = accounts
  },
  SET_ROLES (state, roles) {
    state.roles = roles
  },
  TOGGLE_SELECTION_ACCOUNT (state, account) {
    const accountIndex = state.selectedAccounts.indexOf(account)

    accountIndex > -1 ? state.selectedAccounts.splice(accountIndex, 1) : state.selectedAccounts.push(account)
  },
  SET_SELECTED_ACCOUNTS (state, accounts) {
    state.selectedAccounts = accounts
  },

  UPDATE_ACCOUNT (state, updatedAccount) {
    const accountIndex = state.accounts.findIndex(account => account.id === updatedAccount.id)

    state.accounts.splice(accountIndex, 1, updatedAccount)
  },

  RESET_ACCOUNTS_SELECTION (state) {
    state.selectedAccounts = []
  }
}

const actions = {
  loadConfig ({ commit }, config) {
    commit('LOAD_CONFIG', config)
  },

  async initialize ({ commit, dispatch }) {
    await dispatch('fetchAccounts')
    await dispatch('fetchRoles')
    commit('SET_INITIALIZED', true)
  },

  async fetchAccounts ({ commit, dispatch, rootGetters }) {
    injectAuthToken(rootGetters.user.token)
    const response = await AccountsService_ListAccounts({
      $domain: rootGetters.configuration.server,
      body: {}
    })
    if (response.status === 201) {
      const accounts = response.data.accounts
      commit('SET_ACCOUNTS', accounts || [])
    } else {
      dispatch('showMessage', {
        title: 'Failed to fetch accounts.',
        desc: response.statusText,
        status: 'danger'
      }, { root: true })
    }
  },

  async fetchRoles ({ commit, dispatch, rootGetters }) {
    injectAuthToken(rootGetters.user.token)

    const response = await RoleService_ListRoles({
      $domain: rootGetters.configuration.server,
      body: {}
    })

    if (response.status === 201) {
      const roles = response.data.bundles

      commit('SET_ROLES', roles || [])
    } else {
      dispatch('showMessage', {
        title: 'Failed to fetch roles.',
        desc: response.statusText,
        status: 'danger'
      }, { root: true })
    }
  },

  toggleSelectionAll ({ commit, getters, state }) {
    getters.areAllAccountsSelected ? commit('RESET_ACCOUNTS_SELECTION') : commit('SET_SELECTED_ACCOUNTS', [...state.accounts])
  },

  async toggleAccountStatus ({ commit, dispatch, state, rootGetters }, status) {
    const failedAccounts = []
    injectAuthToken(rootGetters.user.token)

    for (const account of state.selectedAccounts) {
      if (account.accountEnabled === status) {
        continue
      }

      const response = await AccountsService_UpdateAccount({
        $domain: rootGetters.configuration.server,
        body: {
          account: {
            id: account.id,
            accountEnabled: status
          },
          update_mask: {
            paths: ['AccountEnabled']
          }
        }
      })

      if (response.status === 201) {
        commit('UPDATE_ACCOUNT', { ...account, accountEnabled: status })
      } else {
        failedAccounts.push({ account: account.diisplayName, statusText: response.statusText })
      }
    }

    if (failedAccounts.length === 1) {
      const failedMessageTitle = status ? 'Failed to enable account.' : 'Failed to disable account.'

      dispatch('showMessage', {
        title: failedMessageTitle,
        desc: failedAccounts[0].statusText,
        status: 'danger'
      }, { root: true })
    }

    if (failedAccounts.length > 1) {
      const failedMessageTitle = status ? 'Failed to enable accounts.' : 'Failed to disable accounts.'
      const failedMessageDesc = status ? 'Could not enable multiple accounts.' : 'Could not disable multiple accounts.'

      dispatch('showMessage', {
        title: failedMessageTitle,
        desc: failedMessageDesc,
        status: 'danger'
      }, { root: true })
    }

    commit('RESET_ACCOUNTS_SELECTION')
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
