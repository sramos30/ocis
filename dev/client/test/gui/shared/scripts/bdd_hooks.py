# -*- coding: utf-8 -*-

# This file contains hook functions to run as the .feature file is executed.
#
# A common use-case is to use the OnScenarioStart/OnScenarioEnd hooks to
# start and stop an AUT, e.g.
#
# @OnScenarioStart
# def hook(context):
#     startApplication("addressbook")
#
# @OnScenarioEnd
# def hook(context):
#     currentApplicationContext().detach()
#
# See the section 'Performing Actions During Test Execution Via Hooks' in the Squish
# manual for a complete reference of the available API.
import shutil
import urllib.request
import os
import builtins


@OnScenarioStart
def hook(context):
    from configparser import ConfigParser

    CONFIG_ENV_MAP = {
        'localBackendUrl': 'BACKEND_HOST',
        'secureLocalBackendUrl': 'SECURE_BACKEND_HOST',
        'maxSyncTimeout': 'MAX_SYNC_TIMEOUT',
        'minSyncTimeout': 'MIN_SYNC_TIMEOUT',
        'middlewareUrl': 'MIDDLEWARE_URL',
        'clientConfigFile': 'CLIENT_LOG_FILE',
        'clientRootSyncPath': 'CLIENT_ROOT_SYNC_PATH',
    }

    DEFAULT_CONFIG = {
        'localBackendUrl': 'https://localhost:9200/',
        'secureLocalBackendUrl': 'https://localhost:9200/',
        'maxSyncTimeout': 10,
        'minSyncTimeout': 5,
        'middlewareUrl': 'http://localhost:3000/',
        'clientConfigFile': '-',
        'clientRootSyncPath': '/tmp/client-bdd/',
    }

    # read configs from environment variables
    context.userData = {}
    for key, value in CONFIG_ENV_MAP.items():
        context.userData[key] = os.environ.get(value, '')

    # try reading configs from config.ini
    cfg = ConfigParser()
    try:
        cfg.read('../config.ini')
        for key, value in context.userData.items():
            if value == '':
                context.userData[key] = cfg.get('DEFAULT', CONFIG_ENV_MAP[key])
    except Exception as err:
        print(err)

    # Set the default values if empty
    for key, value in context.userData.items():
        if value == '':
            context.userData[key] = DEFAULT_CONFIG[key]
        elif key == 'maxSyncTimeout':
            context.userData[key] = builtins.int(value)
        elif key == 'clientRootSyncPath':
            # make sure there is always one trailing slash
            context.userData[key] = value.rstrip('/') + '/'

    # initially set user sync path to root
    # this path will be changed according to the user added to the client
    # e.g.: /tmp/client-bdd/Alice
    context.userData['currentUserSyncPath'] = context.userData['clientRootSyncPath']

    if not os.path.exists(context.userData['clientRootSyncPath']):
        os.makedirs(context.userData['clientRootSyncPath'])

    req = urllib.request.Request(
        os.path.join(context.userData['middlewareUrl'], 'init'),
        headers={"Content-Type": "application/json"},
        method='POST',
    )
    try:
        urllib.request.urlopen(req)
    except urllib.error.HTTPError as e:
        raise Exception(
            "Step execution through test middleware failed. Error: " + e.read().decode()
        )


@OnScenarioEnd
def hook(context):
    # capture screenshot if there is error in the scenario execution, and if the test is being run in CI
    if test.resultCount("errors") > 0 and os.getenv('CI'):
        import gi

        gi.require_version('Gtk', '3.0')
        from gi.repository import Gdk

        window = Gdk.get_default_root_window()
        pb = Gdk.pixbuf_get_from_window(window, *window.get_geometry())

        filename = context._data["title"].replace(" ", "_") + ".png"
        directory = os.environ["GUI_TEST_REPORT_DIR"] + "/screenshots"

        if not os.path.exists(directory):
            os.makedirs(directory)

        pb.savev(os.path.join(directory, filename), "png", [], [])

    # Detach (i.e. potentially terminate) all AUTs at the end of a scenario
    for ctx in applicationContextList():
        ctx.detach()
        # ToDo wait smarter till the app died
        snooze(context.userData['minSyncTimeout'])

    # delete local files/folders
    for filename in os.listdir(context.userData['clientRootSyncPath']):
        test.log("Deleting: " + filename)
        file_path = os.path.join(context.userData['clientRootSyncPath'], filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))

    # cleanup test server
    req = urllib.request.Request(
        os.path.join(context.userData['middlewareUrl'], 'cleanup'),
        headers={"Content-Type": "application/json"},
        method='POST',
    )
    try:
        urllib.request.urlopen(req)
    except urllib.error.HTTPError as e:
        raise Exception(
            "Step execution through test middleware failed. Error: " + e.read().decode()
        )
