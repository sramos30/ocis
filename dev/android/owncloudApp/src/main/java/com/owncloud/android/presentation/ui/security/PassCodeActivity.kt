/**
 * ownCloud Android client application
 *
 * @author Bartek Przybylski
 * @author masensio
 * @author David A. Velasco
 * @author Christian Schabesberger
 * @author David González Verdugo
 * @author Abel García de Prada
 * @author Juan Carlos Garrote Gascón
 * Copyright (C) 2011 Bartek Przybylski
 * Copyright (C) 2021 ownCloud GmbH.
 * <p>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2,
 * as published by the Free Software Foundation.
 * <p>
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.owncloud.android.presentation.ui.security

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.KeyEvent
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.isVisible
import com.owncloud.android.BuildConfig
import com.owncloud.android.R
import com.owncloud.android.databinding.PasscodelockBinding
import com.owncloud.android.domain.utils.Event
import com.owncloud.android.extensions.hideSoftKeyboard
import com.owncloud.android.extensions.showBiometricDialog
import com.owncloud.android.interfaces.BiometricStatus
import com.owncloud.android.interfaces.IEnableBiometrics
import com.owncloud.android.presentation.ui.settings.fragments.SettingsSecurityFragment.Companion.EXTRAS_LOCK_ENFORCED
import com.owncloud.android.presentation.viewmodels.security.BiometricViewModel
import com.owncloud.android.presentation.viewmodels.security.PassCodeViewModel
import com.owncloud.android.utils.DocumentProviderUtils.Companion.notifyDocumentProviderRoots
import com.owncloud.android.utils.PreferenceUtils
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber
import java.util.Arrays

class PassCodeActivity : AppCompatActivity(), IEnableBiometrics {

    // ViewModel
    private val passCodeViewModel by viewModel<PassCodeViewModel>()
    private val biometricViewModel by viewModel<BiometricViewModel>()

    private var _binding: PasscodelockBinding? = null
    val binding get() = _binding!!

    private lateinit var passCodeEditTexts: Array<EditText?>
    private lateinit var passCodeDigits: Array<String?>
    private var confirmingPassCode = false
    private var bChange = true // to control that only one blocks jump
    private val resultIntent = Intent()

    /**
     * Initializes the activity.
     *
     * @param savedInstanceState    Previously saved state - irrelevant in this case
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        subscribeToViewModel()

        _binding = PasscodelockBinding.inflate(layoutInflater)

        /// protection against screen recording
        if (!BuildConfig.DEBUG) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } // else, let it go, or taking screenshots & testing will not be possible

        setContentView(binding.root)

        passCodeEditTexts = arrayOfNulls(passCodeViewModel.getPassCode()?.length ?: passCodeViewModel.getNumberOfPassCodeDigits())
        passCodeDigits = arrayOfNulls((passCodeViewModel.getPassCode()?.length ?: passCodeViewModel.getNumberOfPassCodeDigits()))

        // Allow or disallow touches with other visible windows
        binding.passcodeLockLayout.filterTouchesWhenObscured =
            PreferenceUtils.shouldDisallowTouchesWithOtherVisibleWindows(this)
        binding.explanation.filterTouchesWhenObscured =
            PreferenceUtils.shouldDisallowTouchesWithOtherVisibleWindows(this)

        inflatePasscodeTxtLine()

        if (passCodeViewModel.getNumberOfAttempts() >= NUM_ATTEMPTS_WITHOUT_TIMER) {
            lockScreen()
        }

        when (intent.action) {
            ACTION_CHECK -> {
                /// this is a pass code request; the user has to input the right value
                binding.header.text = getString(R.string.pass_code_enter_pass_code)
                binding.explanation.visibility = View.INVISIBLE
                setCancelButtonEnabled(false) // no option to cancel
            }
            ACTION_REQUEST_WITH_RESULT -> {
                if (savedInstanceState != null) {
                    confirmingPassCode = savedInstanceState.getBoolean(KEY_CONFIRMING_PASSCODE)
                    passCodeDigits = savedInstanceState.getStringArray(KEY_PASSCODE_DIGITS)!!
                }
                if (confirmingPassCode) {
                    //the app was in the passcode confirmation
                    requestPassCodeConfirmation()
                } else {
                    if (intent.extras?.getBoolean(EXTRAS_MIGRATION) == true) {
                        binding.header.text =
                            getString(R.string.pass_code_configure_your_pass_code_migration, passCodeViewModel.getNumberOfPassCodeDigits())
                    } else {
                        /// pass code preference has just been activated in Preferences;
                        // will receive and confirm pass code value
                        binding.header.text = getString(R.string.pass_code_configure_your_pass_code)
                    }
                    binding.explanation.visibility = View.VISIBLE
                    when {
                        intent.extras?.getBoolean(EXTRAS_MIGRATION) == true -> {
                            setCancelButtonEnabled(false)
                        }
                        intent.extras?.getBoolean(EXTRAS_LOCK_ENFORCED) == true -> {
                            setCancelButtonEnabled(false)
                        }
                        else -> setCancelButtonEnabled(true)
                    }
                }
            }
            ACTION_CHECK_WITH_RESULT -> {
                /// pass code preference has just been disabled in Preferences;
                // will confirm user knows pass code, then remove it
                binding.header.text = getString(R.string.pass_code_remove_your_pass_code)
                binding.explanation.visibility = View.INVISIBLE
                setCancelButtonEnabled(true)
            }
            else -> {
                throw IllegalArgumentException(R.string.illegal_argument_exception_message.toString() + " ")
            }
        }

        setTextListeners()
    }

    private fun inflatePasscodeTxtLine() {
        val passcodeTxtLayout = findViewById<LinearLayout>(R.id.passCodeTxtLayout)
        val numberOfPasscodeDigits = (passCodeViewModel.getPassCode()?.length ?: passCodeViewModel.getNumberOfPassCodeDigits())
        for (i in 0 until numberOfPasscodeDigits) {
            val txt = layoutInflater.inflate(R.layout.passcode_edit_text, passcodeTxtLayout, false) as EditText
            passcodeTxtLayout.addView(txt)
            passCodeEditTexts[i] = txt
        }
        passCodeEditTexts.first()?.requestFocus()
        window.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE
        )
    }

    /**
     * Enables or disables the cancel button to allow the user interrupt the ACTION
     * requested to the activity.
     *
     * @param enabled       'True' makes the cancel button available, 'false' hides it.
     */
    private fun setCancelButtonEnabled(enabled: Boolean) {
        if (enabled) {
            binding.cancel.apply {
                visibility = View.VISIBLE
                setOnClickListener { finish() }
            }
        } else {
            binding.cancel.apply {
                visibility = View.INVISIBLE
                setOnClickListener(null)
            }
        }
    }

    /**
     * Binds the appropriate listeners to the input boxes receiving each digit of the pass code.
     */
    private fun setTextListeners() {
        val numberOfPasscodeDigits = (passCodeViewModel.getPassCode()?.length ?: passCodeViewModel.getNumberOfPassCodeDigits())
        for (i in 0 until numberOfPasscodeDigits) {
            passCodeEditTexts[i]?.addTextChangedListener(PassCodeDigitTextWatcher(i, i == numberOfPasscodeDigits - 1))
            if (i > 0) {
                passCodeEditTexts[i]?.setOnKeyListener { _: View, keyCode: Int, _: KeyEvent? ->
                    if (keyCode == KeyEvent.KEYCODE_DEL && bChange) {  // TODO WIP: event should be used to control what's exactly happening with DEL, not any custom field...
                        passCodeEditTexts[i - 1]?.apply {
                            isEnabled = true
                            setText("")
                            requestFocus()
                        }
                        if (!confirmingPassCode) {
                            passCodeDigits[i - 1] = ""
                        }
                        bChange = false
                    } else if (!bChange) {
                        bChange = true
                    }
                    false
                }
            }
            passCodeEditTexts[i]?.onFocusChangeListener = OnFocusChangeListener { _: View, _: Boolean ->
                /// TODO WIP: should take advantage of hasFocus to reduce processing
                for (j in 0 until i) {
                    if (passCodeEditTexts[j]?.text.toString() == "") {  // TODO WIP validation
                        // could be done in a global way, with a single OnFocusChangeListener for all the
                        // input fields
                        passCodeEditTexts[j]?.requestFocus()
                        break
                    }
                }
            }
        }
    }

    /**
     * Processes the pass code entered by the user just after the last digit was in.
     *
     * Takes into account the action requested to the activity, the currently saved pass code and
     * the previously typed pass code, if any.
     */
    private fun processFullPassCode() {
        when (intent.action) {
            ACTION_CHECK -> {
                handleActionCheck()
            }
            ACTION_CHECK_WITH_RESULT -> {
                handleActionCheckWithResult()
            }
            ACTION_REQUEST_WITH_RESULT -> {
                handleActionRequestWithResult()
            }
        }
    }

    private fun handleActionCheck() {
        if (passCodeViewModel.checkPassCodeIsValid(passCodeDigits)) {
            /// pass code accepted in request, user is allowed to access the app
            binding.error.visibility = View.INVISIBLE
            passCodeViewModel.setLastUnlockTimestamp()
            hideSoftKeyboard()
            val passCode = passCodeViewModel.getPassCode()
            if (passCode != null && passCode.length < passCodeViewModel.getNumberOfPassCodeDigits()) {
                passCodeViewModel.setMigrationRequired(true)
                passCodeViewModel.removePassCode()
                val intent = Intent(baseContext, PassCodeActivity::class.java)
                intent.apply {
                    action = ACTION_REQUEST_WITH_RESULT
                    flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
                    putExtra(EXTRAS_MIGRATION, true)
                }
                startActivity(intent)
            }
            passCodeViewModel.resetNumberOfAttempts()
            PassCodeManager.onActivityStopped(this)
            finish()
        } else {
            showErrorAndRestart(
                errorMessage = R.string.pass_code_wrong, headerMessage = getString(R.string.pass_code_enter_pass_code),
                explanationVisibility = View.INVISIBLE
            )
            passCodeViewModel.increaseNumberOfAttempts()
            if (passCodeViewModel.getNumberOfAttempts() >= NUM_ATTEMPTS_WITHOUT_TIMER) {
                lockScreen()
            }
        }
    }

    private fun handleActionCheckWithResult() {
        if (passCodeViewModel.checkPassCodeIsValid(passCodeDigits)) {
            passCodeViewModel.removePassCode()
            val resultIntent = Intent()
            setResult(RESULT_OK, resultIntent)
            binding.error.visibility = View.INVISIBLE
            hideSoftKeyboard()
            notifyDocumentProviderRoots(applicationContext)
            finish()
        } else {
            showErrorAndRestart(
                errorMessage = R.string.pass_code_wrong, headerMessage = getString(R.string.pass_code_enter_pass_code),
                explanationVisibility = View.INVISIBLE
            )
        }
    }

    private fun subscribeToViewModel() {
        passCodeViewModel.getTimeToUnlockLiveData.observe(this, Event.EventObserver {
            binding.lockTime.text = getString(R.string.lock_time_try_again, it)
        })
        passCodeViewModel.getFinishedTimeToUnlockLiveData.observe(this, Event.EventObserver {
            binding.lockTime.isVisible = false
            for (editText: EditText? in passCodeEditTexts) {
                editText?.isEnabled = true
            }
            passCodeEditTexts.first()?.requestFocus()
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.showSoftInput(passCodeEditTexts.first(), InputMethodManager.SHOW_IMPLICIT)
        })
    }

    private fun lockScreen() {
        val timeToUnlock = passCodeViewModel.getTimeToUnlockLeft()
        if (timeToUnlock > 0) {
            binding.lockTime.isVisible = true
            for (editText: EditText? in passCodeEditTexts) {
                editText?.isEnabled = false
            }
            passCodeViewModel.initUnlockTimer()
        }
    }

    private fun handleActionRequestWithResult() {
        // enabling pass code
        if (!confirmingPassCode) {
            binding.error.visibility = View.INVISIBLE
            requestPassCodeConfirmation()
        } else if (confirmPassCode()) {
            // confirmed: user typed the same pass code twice
            if (intent.extras?.getBoolean(EXTRAS_MIGRATION) == true) passCodeViewModel.setMigrationRequired(false)
            savePassCodeAndExit()
        } else {
            val headerMessage = if (intent.extras?.getBoolean(EXTRAS_MIGRATION) == true) getString(
                R.string.pass_code_configure_your_pass_code_migration,
                passCodeViewModel.getNumberOfPassCodeDigits()
            )
            else getString(R.string.pass_code_configure_your_pass_code)
            showErrorAndRestart(
                errorMessage = R.string.pass_code_mismatch, headerMessage = headerMessage, explanationVisibility = View.VISIBLE
            )
        }
    }

    private fun showErrorAndRestart(
        errorMessage: Int, headerMessage: String,
        explanationVisibility: Int
    ) {
        Arrays.fill(passCodeDigits, null)
        binding.error.setText(errorMessage)
        binding.error.visibility = View.VISIBLE
        binding.header.text = headerMessage
        binding.explanation.visibility = explanationVisibility
        clearBoxes()
    }

    /**
     * Ask to the user for retyping the pass code just entered before saving it as the current pass
     * code.
     */
    private fun requestPassCodeConfirmation() {
        clearBoxes()
        binding.header.setText(R.string.pass_code_reenter_your_pass_code)
        binding.explanation.visibility = View.INVISIBLE
        confirmingPassCode = true
    }

    /**
     * Compares pass code retyped by the user in the input fields with the value entered just
     * before.
     *
     * @return     'True' if retyped pass code equals to the entered before.
     */
    private fun confirmPassCode(): Boolean {
        confirmingPassCode = false
        var isValid = true
        var i = 0
        while (i < passCodeEditTexts.size && isValid) {
            isValid = passCodeEditTexts[i]?.text.toString() == passCodeDigits[i]
            i++
        }
        return isValid
    }

    /**
     * Sets the input fields to empty strings and puts the focus on the first one.
     */
    private fun clearBoxes() {
        for (passCodeEditText in passCodeEditTexts) {
            passCodeEditText?.apply {
                isEnabled = true
                setText("")
            }
        }
        passCodeEditTexts.first()?.requestFocus()
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(passCodeEditTexts.first(), InputMethodManager.SHOW_IMPLICIT)
    }

    /**
     * Overrides click on the BACK arrow to correctly cancel ACTION_ENABLE or ACTION_DISABLE, while
     * preventing than ACTION_CHECK may be worked around.
     *
     * @param keyCode       Key code of the key that triggered the down event.
     * @param event         Event triggered.
     * @return              'True' when the key event was processed by this method.
     */
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.repeatCount == 0) {
            if ((ACTION_REQUEST_WITH_RESULT == intent.action &&
                        intent.extras?.getBoolean(EXTRAS_LOCK_ENFORCED) != true) ||
                ACTION_CHECK_WITH_RESULT == intent.action
            ) {
                finish()
            } // else, do nothing, but report that the key was consumed to stay alive
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    /**
     * Saves the pass code input by the user as the current pass code.
     */
    private fun savePassCodeAndExit() {
        val passCodeString = StringBuilder()
        for (i in 0 until passCodeViewModel.getNumberOfPassCodeDigits()) {
            passCodeString.append(passCodeDigits[i])
        }
        passCodeViewModel.setPassCode(passCodeString.toString())
        setResult(RESULT_OK, resultIntent)
        notifyDocumentProviderRoots(applicationContext)
        if (biometricViewModel.isBiometricLockAvailable()) {
            showBiometricDialog(this)
        } else {
            PassCodeManager.onActivityStopped(this)
            finish()
        }
    }

    public override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putBoolean(KEY_CONFIRMING_PASSCODE, confirmingPassCode)
        outState.putStringArray(KEY_PASSCODE_DIGITS, passCodeDigits)
    }

    /**
     * Constructor
     *
     * @param index         Position in the pass code of the input field that will be bound to
     * this watcher.
     * @param lastOne       'True' means that watcher corresponds to the last position of the
     * pass code.
     */
    private inner class PassCodeDigitTextWatcher(private val index: Int, private val lastOne: Boolean) : TextWatcher {
        private operator fun next(): Int {
            return if (lastOne) 0 else index.plus(1)
        }

        /**
         * Performs several actions when the user types a digit in an input field:
         * - saves the input digit to the state of the activity; this will allow retyping the
         * pass code to confirm it.
         * - moves the focus automatically to the next field
         * - for the last field, triggers the processing of the full pass code
         *
         * @param changedText     Changed text
         */
        override fun afterTextChanged(changedText: Editable) {
            if (changedText.isNotEmpty()) {
                if (!confirmingPassCode) {
                    passCodeDigits[index] = passCodeEditTexts[index]?.text.toString()
                }
                passCodeEditTexts[next()]?.requestFocus()
                passCodeEditTexts[index]?.isEnabled = false
                if (lastOne) {
                    processFullPassCode()
                }
            } else {
                Timber.d("Text box $index was cleaned")
            }
        }

        override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {
            // nothing to do
        }

        override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
            // nothing to do
        }

        init {
            require(index >= 0) {
                "Invalid index in " + PassCodeDigitTextWatcher::class.java.simpleName +
                        " constructor"
            }
        }
    }

    override fun onOptionSelected(optionSelected: BiometricStatus) {
        when (optionSelected) {
            BiometricStatus.ENABLED_BY_USER -> {
                passCodeViewModel.setBiometricsState(enabled = true)
            }
            BiometricStatus.DISABLED_BY_USER -> {
                passCodeViewModel.setBiometricsState(enabled = false)
            }
        }
        PassCodeManager.onActivityStopped(this)
        finish()
    }

    companion object {
        const val ACTION_REQUEST_WITH_RESULT = "ACTION_REQUEST_WITH_RESULT"
        const val ACTION_CHECK_WITH_RESULT = "ACTION_CHECK_WITH_RESULT"
        const val ACTION_CHECK = "ACTION_CHECK"

        // NOTE: PREFERENCE_SET_PASSCODE must have the same value as settings_security.xml-->android:key for passcode preference
        const val PREFERENCE_SET_PASSCODE = "set_pincode"
        const val PREFERENCE_PASSCODE = "PrefPinCode"
        const val PREFERENCE_MIGRATION_REQUIRED = "PrefMigrationRequired"

        // NOTE: This is required to read the legacy pin code format
        const val PREFERENCE_PASSCODE_D = "PrefPinCode"

        private const val KEY_PASSCODE_DIGITS = "PASSCODE_DIGITS"
        private const val KEY_CONFIRMING_PASSCODE = "CONFIRMING_PASSCODE"

        const val EXTRAS_MIGRATION = "PASSCODE_MIGRATION"
        const val PASSCODE_MIN_LENGTH = 4

        private const val NUM_ATTEMPTS_WITHOUT_TIMER = 3

    }
}
