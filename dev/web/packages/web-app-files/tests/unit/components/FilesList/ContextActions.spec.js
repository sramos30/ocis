import Vuex from 'vuex'
import DesignSystem from 'owncloud-design-system'
import stubs from '@/tests/unit/stubs/index.js'
import { createLocalVue, mount } from '@vue/test-utils'
import ContextActions from '../../../../src/components/FilesList/ContextActions.vue'
import GetTextPlugin from 'vue-gettext'
import fixtureMimeTypes from '@files/tests/__fixtures__/mimeTypes.js'

const localVue = createLocalVue()
localVue.use(DesignSystem)
localVue.use(Vuex)
localVue.use(GetTextPlugin, {
  translations: 'does-not-matter.json',
  silent: true
})

const exampleApps = [
  { name: 'exampleName1', icon: 'exampleIcon1' },
  { name: 'exampleName2', icon: 'exampleIcon2' },
  { name: 'exampleName3', icon: 'exampleIcon3' }
]

const mockMenuSections = [
  {
    name: 'context',
    items: [
      {
        icon: 'file-text',
        canBeDefault: true,
        handler: jest.fn(),
        label: () => 'Open in editor',
        componentType: 'oc-button',
        selector: '.oc-files-actions-markdown-editor-trigger',
        class: 'oc-files-actions-markdown-editor-trigger'
      },
      ...exampleApps.map((app) => {
        return {
          img: app.icon,
          canBeDefault: true,
          handler: jest.fn(),
          label: () => 'Open in ' + app.name,
          componentType: 'oc-button',
          selector: `.oc-files-actions-${app.name}-trigger`,
          class: `oc-files-actions-${app.name}-trigger`
        }
      }),
      {
        icon: 'download',
        canBeDefault: true,
        handler: jest.fn(),
        label: () => 'Download',
        componentType: 'oc-button',
        selector: '.oc-files-actions-download-file-trigger',
        class: 'oc-files-actions-download-file-trigger'
      },
      {
        icon: 'links',
        handler: jest.fn(),
        label: () => 'Create link',
        componentType: 'oc-button',
        selector: '.oc-files-actions-create-public-link-trigger',
        class: 'oc-files-actions-create-public-link-trigger'
      },
      {
        icon: 'group',
        handler: jest.fn(),
        label: () => 'Share',
        componentType: 'oc-button',
        selector: '.oc-files-actions-show-shares-trigger',
        class: 'oc-files-actions-show-shares-trigger'
      }
    ]
  },
  {
    name: 'actions',
    items: [
      {
        icon: 'pencil',
        handler: jest.fn(),
        label: () => 'Edit',
        componentType: 'oc-button',
        selector: '.oc-files-actions-rename-trigger',
        class: 'oc-files-actions-rename-trigger'
      },
      {
        icon: 'folder-shared',
        handler: jest.fn(),
        label: () => 'Move',
        componentType: 'oc-button',
        selector: '.oc-files-actions-move-trigger',
        class: 'oc-files-actions-move-trigger'
      },
      {
        icon: 'file-copy',
        handler: jest.fn(),
        label: () => 'Copy',
        componentType: 'oc-button',
        selector: '.oc-files-actions-copy-trigger',
        class: 'oc-files-actions-copy-trigger'
      },
      {
        icon: 'delete-bin-5',
        handler: jest.fn(),
        label: () => 'Delete',
        componentType: 'oc-button',
        selector: '.oc-files-actions-delete-trigger',
        class: 'oc-files-actions-delete-trigger'
      },
      {
        icon: 'slideshow',
        handler: jest.fn(),
        label: () => 'All actions',
        componentType: 'oc-button',
        selector: '.oc-files-actions-show-actions-trigger',
        class: 'oc-files-actions-show-actions-trigger'
      }
    ]
  },
  {
    name: 'sidebar',
    items: [
      {
        icon: 'information',
        handler: jest.fn(),
        label: () => 'Details',
        componentType: 'oc-button',
        selector: '.oc-files-actions-show-details-trigger',
        class: 'oc-files-actions-show-details-trigger'
      }
    ]
  }
]

const filesPersonalRoute = { name: 'files-personal' }

describe('ContextActions', () => {
  describe('action handlers', () => {
    afterEach(() => {
      jest.clearAllMocks()
    })
    it('renders action handlers as clickable elements', async () => {
      const wrapper = getWrapper(
        filesPersonalRoute,
        {
          name: 'exampleFile',
          extension: 'jpg',
          mimeType: 'application/fileFormat2',
          type: 'file'
        },
        exampleApps
      )

      for (const section of mockMenuSections) {
        for (const item of section.items) {
          const buttonElement = wrapper.find(item.selector)
          expect(buttonElement.exists()).toBeTruthy()
          await buttonElement.trigger('click')
          expect(item.handler).toHaveBeenCalledTimes(1)
        }
      }
    })
  })

  describe('menu items', () => {
    it('renders a list of actions for a file', () => {
      const wrapper = getWrapper(filesPersonalRoute, {
        name: 'exampleFile',
        extension: 'jpg',
        mimeType: 'application/fileFormat2',
        type: 'file'
      })

      expect(wrapper).toMatchSnapshot()
    })

    it('renders a list of actions for a folder', () => {
      const wrapper = getWrapper(filesPersonalRoute, {
        name: 'exampleFolder',
        extension: '',
        type: 'folder'
      })

      expect(wrapper).toMatchSnapshot()
    })
  })
})

function getWrapper(route, { filename, extension, type = '', mimeType }, availableApps = []) {
  const mountStubs = { ...stubs, 'oc-button': false }

  return mount(ContextActions, {
    localVue,
    store: createStore(),
    data() {
      return {
        appList: availableApps
      }
    },
    stubs: mountStubs,
    mocks: {
      $route: route,
      publicPage: () => false
    },
    provide: {
      currentSpace: {
        value: {}
      }
    },
    propsData: {
      items: [
        {
          id: 'a93f8adf==',
          fileId: 'a93f8adf==',
          name: filename,
          path: type === 'file' ? `/${filename}.${extension}` : `/${filename}`,
          mimeType,
          extension,
          type,
          canDownload: () => true,
          isReceivedShare: () => true,
          canBeDeleted: () => true,
          canRename: () => true
        }
      ]
    },
    computed: {
      menuSections: () => mockMenuSections
    }
  })
}

function createStore(state) {
  return new Vuex.Store({
    getters: {
      capabilities: jest.fn(() => ({
        files: {
          app_providers: [
            {
              apps_url: '/app/list',
              enabled: true,
              open_url: '/app/open'
            }
          ]
        }
      }))
    },
    modules: {
      External: {
        state: {
          ...state
        },
        namespaced: true,
        getters: {
          mimeTypes: () => {
            return fixtureMimeTypes
          }
        }
      },
      Files: {
        state: {
          ...state
        },
        namespaced: true,
        getters: {
          currentFolder: () => '/'
        }
      }
    }
  })
}
