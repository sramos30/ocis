/*
 * Copyright (C) by Klaas Freitag <freitag@owncloud.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 */

#ifndef _THEME_H
#define _THEME_H

#include <QFileInfo>
#include <QObject>
#include "syncresult.h"

class QIcon;
class QString;
class QObject;
class QPixmap;
class QColor;
class QPaintDevice;

namespace OCC {

class SyncResult;

/**
 * @brief The Theme class
 * @ingroup libsync
 */
class OWNCLOUDSYNC_EXPORT Theme : public QObject
{
    Q_OBJECT
public:
    enum class VersionFormat {
        Plain,
        Url,
        RichText,
        OneLiner
    };
    Q_ENUM(VersionFormat);

    /* returns a singleton instance. */
    static Theme *instance();

    ~Theme() override;

    /**
     * @brief appNameGUI - Human readable application name.
     *
     * Use and redefine this if the human readable name contains spaces,
     * special chars and such.
     *
     * By default, the name is derived from the APPLICATION_NAME
     * cmake variable.
     *
     * @return QString with human readable app name.
     */
    virtual QString appNameGUI() const;

    /**
     * @brief appName - Application name (short)
     *
     * Use and redefine this as an application name. Keep it straight as
     * it is used for config files etc. If you need a more sophisticated
     * name in the GUI, redefine appNameGUI.
     *
     * By default, the name is derived from the APPLICATION_SHORTNAME
     * cmake variable, and should be the same. This method is only
     * reimplementable for legacy reasons.
     *
     * Warning: Do not modify this value, as many things, e.g. settings
     * depend on it! You most likely want to modify \ref appNameGUI().
     *
     * @return QString with app name.
     */
    virtual QString appName() const;

    /**
     * @brief configFileName
     * @return the name of the config file.
     */
    virtual QString configFileName() const;

#ifndef TOKEN_AUTH_ONLY
    /**
     * Wehther we allow a fallback to a vanilla icon
     */
    enum class IconType {
        BrandedIcon,
        BrandedIconWithFallbackToVanillaIcon,
        VanillaIcon
    };

    /**
      * get an sync state icon
      */
    QIcon syncStateIcon(const SyncResult &status, bool sysTray = false, bool sysTrayMenuVisible = false) const;
    QIcon syncStateIcon(SyncResult::Status result, bool sysTray = false, bool sysTrayMenuVisible = false) const;


    virtual QIcon folderDisabledIcon() const;
    virtual QIcon folderOfflineIcon(bool sysTray = false, bool sysTrayMenuVisible = false) const;
    virtual QIcon applicationIcon() const;
    virtual QIcon aboutIcon() const;

    /**
     * Whether use the dark icon theme
     * The function also ensures the theme supports the dark theme
     */
    bool isUsingDarkTheme() const;

    /**
    * Whether the branding allows the dark theme
    */
    bool allowDarkTheme() const;
#endif

    virtual QString statusHeaderText(SyncResult::Status) const;

    /**
     * Characteristics: bool if more than one sync folder is allowed
     */
    virtual bool singleSyncFolder() const;

    /**
     * When true, client works with multiple accounts.
     */
    virtual bool multiAccount() const;

    /**
    * URL to documentation.
    *
    * This is opened in the browser when the "Help" action is selected from the tray menu.
    *
    * If the function is overridden to return an empty string the action is removed from
    * the menu.
    *
    * Defaults to ownCloud's client documentation website.
    */
    virtual QString helpUrl() const;

    /**
     * The url to use for showing help on conflicts.
     *
     * If the function is overridden to return an empty string no help link will be shown.
     *
     * Defaults to helpUrl() + "conflicts.html", which is a page in ownCloud's client
     * documentation website. If helpUrl() is empty, this function will also return the
     * empty string.
     */
    virtual QString conflictHelpUrl() const;

    /**
     * Setting a value here will pre-define the server url.
     *
     * The respective UI controls will be disabled
     * Deprecated: Use overrideServerUrlV2 as it allows overrides
     */
    Q_DECL_DEPRECATED_X("Use overrideServerUrlV2")
    virtual QString overrideServerUrl() const;

    /** Same as overrideServerUrl allows override by
     *  setting $OWNCLOUD_OVERRIDE_SERVER_URL
     */
    QString overrideServerUrlV2() const;

    /**
     * This is only usefull when previous version had a different overrideServerUrl
     * with a different auth type in that case You should then specify "http" or "shibboleth".
     * Normaly this should be left empty.
     */
    virtual QString forceConfigAuthType() const;

    /**
     * The default folder name without path on the server at setup time.
     */
    virtual QString defaultServerFolder() const;

    /**
     * The default folder name without path on the client side at setup time.
     */
    virtual QString defaultClientFolder() const;

    /**
     * Override to encforce a particular locale, i.e. "de" or "pt_BR"
     */
    virtual QString enforcedLocale() const { return QString(); }

#ifndef TOKEN_AUTH_ONLY
    /** colored, white or black */
    QString systrayIconFlavor(bool mono, bool sysTrayMenuVisible = false) const;

    /** @return color for the setup wizard */
    virtual QColor wizardHeaderTitleColor() const;
    virtual QColor wizardHeaderSubTitleColor() const;

    /** @return color for the setup wizard. */
    virtual QColor wizardHeaderBackgroundColor() const;

    /** @return logo for the setup wizard. */
    virtual QIcon wizardHeaderLogo() const;

    /**
     * The default implementation creates a
     * background based on
     * \ref wizardHeaderTitleColor().
     *
     * @return banner for the setup wizard.
     */
    virtual QPixmap wizardHeaderBanner(const QSize &size) const;
#endif

    /**
     * The SHA sum of the released git commit
     */
    QString gitSHA1(VersionFormat format = VersionFormat::Plain) const;

    /**
     * The used library versions
     */
    QString aboutVersions(VersionFormat format = VersionFormat::Plain) const;

    /**
     * About dialog contents
     */
    virtual QString about() const;
    virtual bool aboutShowCopyright() const;

    /**
     * Define if the systray icons should be using mono design
     */
    void setSystrayUseMonoIcons(bool mono);

    /**
     * Retrieve wether to use mono icons for systray
     */
    bool systrayUseMonoIcons() const;

    /**
     * Check if mono icons are available
     */
    bool monoIconsAvailable() const;

    /**
     * @brief Where to check for new Updates.
     */
    virtual QString updateCheckUrl() const;

    /**
     * Default option for the newBigFolderSizeLimit.
     * Size in MB of the maximum size of folder before we ask the confirmation.
     * Set -1 to never ask confirmation.  0 to ask confirmation for every folder.
     **/
    virtual qint64 newBigFolderSizeLimit() const;

    /**
     * Hide the checkbox that says "Ask for confirmation before synchronizing folders larger than X MB"
     * in the account wizard
     */
    virtual bool wizardHideFolderSizeLimitCheckbox() const;
    /**
     * Hide the checkbox that says "Ask for confirmation before synchronizing external storages"
     * in the account wizard
     */
    virtual bool wizardHideExternalStorageConfirmationCheckbox() const;

    /**
     * Skip the advanced page and create a sync with the default settings
     */
    virtual bool wizardSkipAdvancedPage() const;

    /**
     * Alternative path on the server that provides access to the webdav capabilities
     *
     * Attention: Make sure that this string does NOT have a leading slash and that
     * it has a trailing slash, for example "remote.php/webdav/".
     */
    virtual QString webDavPath() const;

    /**
     * @brief Sharing options
     *
     * Allow link sharing and or user/group sharing
     */
    virtual bool linkSharing() const;
    virtual bool userGroupSharing() const;

    /**
     * If this returns true, the user cannot configure the proxy in the network settings.
     * The proxy settings will be disabled in the configuration dialog.
     * Default returns false.
     */
    virtual bool forceSystemNetworkProxy() const;

    /**
     * @brief How to handle the userID
     *
     * @value UserIDUserName Wizard asks for user name as ID
     * @value UserIDEmail Wizard asks for an email as ID
     * @value UserIDCustom Specify string in \ref customUserID
     */
    enum UserIDType { UserIDUserName = 0,
        UserIDEmail,
        UserIDCustom };

    /** @brief What to display as the userID (e.g. in the wizards)
     *
     *  @return UserIDType::UserIDUserName, unless reimplemented
     */
    virtual UserIDType userIDType() const;

    /**
     * @brief Allows to customize the type of user ID (e.g. user name, email)
     *
     * @note This string cannot be translated, but is still useful for
     *       referencing brand name IDs (e.g. "ACME ID", when using ACME.)
     *
     * @return An empty string, unless reimplemented
     */
    virtual QString customUserID() const;

    /**
     * @brief Demo string to be displayed when no text has been
     *        entered for the user id (e.g. mylogin@company.com)
     *
     * @return An empty string, unless reimplemented
     */
    virtual QString userIDHint() const;

    /**
     * @brief Postfix that will be enforced in a URL. e.g.
     *        ".myhosting.com".
     *
     * @return An empty string, unless reimplemented
     */
    virtual QString wizardUrlPostfix() const;

    /**
     * @brief String that will be shown as long as no text has been entered by the user.
     *
     * @return An empty string, unless reimplemented
     */
    virtual QString wizardUrlHint() const;

    /**
     * @brief the server folder that should be queried for the quota information
     *
     * This can be configured to show the quota infromation for a different
     * folder than the root. This is the folder on which the client will do
     * PROPFIND calls to get "quota-available-bytes" and "quota-used-bytes"
     *
     * Defaults: "/"
     */
    virtual QString quotaBaseFolder() const;

    /**
     * The OAuth client_id, secret pair.
     * Note that client that change these value cannot connect to un-branded owncloud servers.
     */
    virtual QString oauthClientId() const;
    virtual QString oauthClientSecret() const;

    /**
     * Defaults to http://localhost due to historic reasons,
     * can be set to http://127.0.0.1 reasons.
     * This option is only available with oauth2 not with OpenID Connect.
     */
    virtual QString oauthLocalhost() const;

    /**
     * By default the client tries to get the OAuth access endpoint and the OAuth token endpoint from /.well-known/openid-configuration
     * Setting this allow authentication without a well known url
     *
     * @return QPair<OAuth access endpoint, OAuth token endpoint>
     */
    virtual QPair<QString, QString> oauthOverrideAuthUrl() const;

    /**
     * Returns the required opeidconnect scopes
     */
    virtual QString openIdConnectScopes() const;

    /**
     * Returns the openidconnect promt type
     * It is supposed to be "consent select_account".
     * For Konnect it currently needs to be select_account,
     * which is the current default.
     */
    virtual QString openIdConnectPrompt() const;

    /**
     * @brief What should be output for the --version command line switch.
     *
     * By default, it's a combination of appName(), version(), the GIT SHA1 and some
     * important dependency versions.
     */
    virtual QString versionSwitchOutput() const;

    /**
     * @brief Whether to show the option to create folders using "virtual files".
     *
     * By default, this is the same as enableExperimentalFreatures()
     */
    virtual bool showVirtualFilesOption() const;

    virtual bool forceVirtualFilesOption() const;

    /**
     * @brief Whether to show options considered as experimental.
     *
     * By default, the options are not shown unless experimental options are
     * manually enabled in the configuration file.
     */
    virtual bool enableExperimentalFeatures() const;

    /**
     * Whether to clear cookies before checking status.php
     * This is used with F5 BIG-IP seups.
     */
    virtual bool connectionValidatorClearCookies() const;


    /**
     * Enables the response of V2/GET_CLIENT_ICON, default true.
     * See #9167
     */
    virtual bool enableSocketApiIconSupport() const;


    /**
     * Warn if we find multiple db files in the sync root.
     * This can indicate that the sync dir is shared between multiple clients or accounts
     */
    virtual bool warnOnMultipleDb() const;


    /**
     * Whether to or not to allow multiple sync folder pairs for the same remote folder.
     * Default: true
     */
    virtual bool allowDuplicatedFolderSyncPair() const;

protected:
#ifndef TOKEN_AUTH_ONLY
    QIcon themeUniversalIcon(const QString &name, IconType iconType = IconType::BrandedIcon) const;
    QIcon themeTrayIcon(const QString &name, bool sysTrayMenuVisible = false, IconType iconType = IconType::BrandedIconWithFallbackToVanillaIcon) const;
    QIcon themeIcon(const QString &name, IconType iconType = IconType::BrandedIconWithFallbackToVanillaIcon) const;
#endif
    Theme();

signals:
    void systrayUseMonoIconsChanged(bool);

private:
    Theme(Theme const &);
    Theme &operator=(Theme const &);

    QIcon loadIcon(const QString &flavor, const QString &name, IconType iconType) const;
    // whether or not a theme is available
    bool hasTheme(IconType type, const QString &theme) const;

    static Theme *_instance;
    bool _mono = false;
#ifndef TOKEN_AUTH_ONLY
    mutable QMap<QString, QIcon> _iconCache;
    // <<is vanilla, theme name>, bool
    // caches the availability of themes for branded and unbranded themes
    mutable QMap<QPair<bool, QString>, bool> _themeCache;
    const bool _hasBrandedColored = hasTheme(IconType::BrandedIcon, QStringLiteral("colored"));
    const bool _hasBrandedDark = hasTheme(IconType::BrandedIcon, QStringLiteral("dark"));
#endif
};
}
#endif // _THEME_H
