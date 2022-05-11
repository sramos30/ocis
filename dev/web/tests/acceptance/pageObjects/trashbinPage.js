const { join } = require('../helpers/path')

module.exports = {
  url: function () {
    return join(this.api.launchUrl, '/files/trash/')
  },
  commands: {
    /**
     * like build-in navigate() but also waits till for the progressbar to appear and disappear
     * @returns {*}
     */
    navigateAndWaitTillLoaded: function () {
      return this.navigate(this.url()).waitForElementPresent(
        this.page.FilesPageElement.filesList().elements.anyAfterLoading
      )
    },
    clearTrashbin: function () {
      return this.waitForElementVisible('@clearTrashbin')
        .initAjaxCounters()
        .click('@clearTrashbin')
        .waitForElementVisible('@dialog')
        .waitForAnimationToFinish() // wait for transition on the modal to finish
        .click('@dialogConfirmBtnEnabled')
        .waitForAjaxCallsToStartAndFinish()
        .waitForElementNotPresent('@dialog')
    },
    restoreSelected: function () {
      return this.waitForElementVisible('@restoreSelectedButton')
        .initAjaxCounters()
        .click('@restoreSelectedButton')
        .waitForOutstandingAjaxCalls()
    },
    deleteSelectedPermanently: function () {
      return this.waitForElementVisible('@deleteSelectedPermanentlyButton')
        .click('@deleteSelectedPermanentlyButton')
        .waitForElementVisible('@dialog')
        .waitForAnimationToFinish() // wait for transition on the modal to finish
        .click('@dialogConfirmBtnEnabled')
        .waitForAjaxCallsToStartAndFinish()
        .waitForElementNotPresent('@dialog')
    }
  },
  elements: {
    dialog: {
      selector: '.oc-modal'
    },
    dialogConfirmBtnEnabled: {
      selector: '.oc-modal-body-actions-confirm:enabled'
    },
    clearTrashbin: {
      selector: '.oc-files-actions-empty-trash-bin-trigger:not([disabled])'
    },
    restoreSelectedButton: {
      selector: '.oc-files-actions-restore-trigger'
    },
    deleteSelectedPermanentlyButton: {
      selector: '.oc-files-actions-delete-permanent-trigger'
    }
  }
}
