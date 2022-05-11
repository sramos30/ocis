"""oCIS CI definition
"""

# images
ALPINE_GIT = "alpine/git:latest"
CHKO_DOCKER_PUSHRM = "chko/docker-pushrm:1"
DRONE_CLI = "drone/cli:alpine"
MARIADB = "mariadb:10.6"
MELTWATER_DRONE_CACHE = "meltwater/drone-cache:v1"
MINIO_MC = "minio/mc:RELEASE.2021-10-07T04-19-58Z"
OC_CI_ALPINE = "owncloudci/alpine:latest"
OC_CI_BAZEL_BUILDIFIER = "owncloudci/bazel-buildifier:latest"
OC_CI_DRONE_ANSIBLE = "owncloudci/drone-ansible:latest"
OC_CI_DRONE_CANCEL_PREVIOUS_BUILDS = "owncloudci/drone-cancel-previous-builds"
OC_CI_DRONE_SKIP_PIPELINE = "owncloudci/drone-skip-pipeline"
OC_CI_GOLANG = "owncloudci/golang:1.17"
OC_CI_NODEJS = "owncloudci/nodejs:%s"
OC_CI_PHP = "owncloudci/php:%s"
OC_CI_WAIT_FOR = "owncloudci/wait-for:latest"
OC_OC_TEST_MIDDLEWARE = "owncloud/owncloud-test-middleware:1.4.0"
OC_SERVER = "owncloud/server:10"
OC_UBUNTU = "owncloud/ubuntu:18.04"
OSIXIA_OPEN_LDAP = "osixia/openldap:latest"
PLUGINS_CODACY = "plugins/codacy:1"
PLUGINS_DOCKER = "plugins/docker:latest"
PLUGINS_DOWNSTREAM = "plugins/downstream:latest"
PLUGINS_GH_PAGES = "plugins/gh-pages:1"
PLUGINS_GITHUB_RELEASE = "plugins/github-release:1"
PLUGINS_GIT_ACTION = "plugins/git-action:1"
PLUGINS_MANIFEST = "plugins/manifest:1"
PLUGINS_S3 = "plugins/s3:latest"
PLUGINS_SLACK = "plugins/slack:1"
REDIS = "redis:6-alpine"
SELENIUM_STANDALONE_CHROME_DEBUG = "selenium/standalone-chrome-debug:3.141.59"
SONARSOURCE_SONAR_SCANNER_CLI = "sonarsource/sonar-scanner-cli:latest"
THEGEEKLAB_DRONE_GITHUB_COMMENT = "thegeeklab/drone-github-comment:1"

DEFAULT_PHP_VERSION = "7.4"
DEFAULT_NODEJS_VERSION = "14"

# configuration
config = {
    "modules": [
        # if you add a module here please also add it to the root level Makefile
        "accounts",
        "audit",
        "glauth",
        "graph-explorer",
        "graph",
        "idp",
        "ocis-pkg",
        "ocis",
        "ocs",
        "proxy",
        "settings",
        "storage",
        "store",
        "thumbnails",
        "web",
        "webdav",
    ],
    "localApiTests": {
        "skip": False,
        "earlyFail": True,
    },
    "apiTests": {
        "numberOfParts": 10,
        "skip": False,
        "skipExceptParts": [],
        "earlyFail": True,
    },
    "uiTests": {
        "filterTags": "@ocisSmokeTest",
        "skip": False,
        "skipExceptParts": [],
        "earlyFail": True,
    },
    "accountsUITests": {
        "skip": False,
        "earlyFail": True,
    },
    "settingsUITests": {
        "skip": False,
        "earlyFail": True,
    },
    "parallelApiTests": {
        "apiSharing": {
            "suites": [
                "apiShareManagement",
            ],
            "skip": False,
            "earlyFail": True,
            "cron": "nightly",
        },
        "apiWebdav": {
            "suites": [
                "apiWebdavOperations",
            ],
            "skip": False,
            "earlyFail": True,
            "cron": "nightly",
        },
    },
    "rocketchat": {
        "channel": "ocis-internal",
        "from_secret": "private_rocketchat",
    },
    "binaryReleases": {
        "os": ["linux", "darwin", "windows"],
    },
    "dockerReleases": {
        "architectures": ["arm", "arm64", "amd64"],
    },
}

# volume for steps to cache Go dependencies between steps of a pipeline
# GOPATH must be set to /go inside the image, which is the case
stepVolumeGo = \
    {
        "name": "gopath",
        "path": "/go",
    }

# volume for pipeline to cache Go dependencies between steps of a pipeline
# to be used in combination with stepVolumeGo
pipelineVolumeGo = \
    {
        "name": "gopath",
        "temp": {},
    }

stepVolumeOC10Tests = \
    {
        "name": "oC10Tests",
        "path": "/srv/app",
    }

pipelineVolumeOC10Tests = \
    {
        "name": "oC10Tests",
        "temp": {},
    }

def pipelineDependsOn(pipeline, dependant_pipelines):
    if "depends_on" in pipeline.keys():
        pipeline["depends_on"] = pipeline["depends_on"] + getPipelineNames(dependant_pipelines)
    else:
        pipeline["depends_on"] = getPipelineNames(dependant_pipelines)
    return pipeline

def pipelinesDependsOn(pipelines, dependant_pipelines):
    pipes = []
    for pipeline in pipelines:
        pipes.append(pipelineDependsOn(pipeline, dependant_pipelines))

    return pipes

def getPipelineNames(pipelines = []):
    """getPipelineNames returns names of pipelines as a string array

    Args:
      pipelines: array of drone pipelines

    Returns:
      names of the given pipelines as string array
    """
    names = []
    for pipeline in pipelines:
        names.append(pipeline["name"])
    return names

def main(ctx):
    """main is the entrypoint for drone

    Args:
      ctx: drone passes a context with information which the pipeline can be adapted to

    Returns:
      none
    """

    pipelines = []

    test_pipelines = \
        cancelPreviousBuilds() + \
        [buildOcisBinaryForTesting(ctx)] + \
        testOcisModules(ctx) + \
        testPipelines(ctx)

    build_release_pipelines = \
        dockerReleases(ctx) + \
        binaryReleases(ctx) + \
        [releaseSubmodule(ctx)]

    build_release_helpers = [
        changelog(ctx),
        docs(ctx),
    ]

    test_pipelines.append(
        pipelineDependsOn(
            purgeBuildArtifactCache(ctx, "ocis-binary-amd64"),
            testPipelines(ctx),
        ),
    )

    pipelines = test_pipelines + build_release_pipelines + build_release_helpers

    pipelines = \
        pipelines + \
        pipelinesDependsOn(
            example_deploys(ctx),
            pipelines,
        )

    # always append notification step
    pipelines.append(
        pipelineDependsOn(
            notify(ctx),
            pipelines,
        ),
    )

    pipelines += checkStarlark()
    pipelineSanityChecks(ctx, pipelines)
    return pipelines

def testOcisModules(ctx):
    pipelines = []
    for module in config["modules"]:
        pipelines.append(testOcisModule(ctx, module))

    scan_result_upload = uploadScanResults(ctx)
    scan_result_upload["depends_on"] = getPipelineNames(pipelines)

    return pipelines + [scan_result_upload]

def cancelPreviousBuilds():
    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "cancel-previous-builds",
        "clone": {
            "disable": True,
        },
        "steps": [{
            "name": "cancel-previous-builds",
            "image": OC_CI_DRONE_CANCEL_PREVIOUS_BUILDS,
            "settings": {
                "DRONE_TOKEN": {
                    "from_secret": "drone_token",
                },
            },
        }],
        "trigger": {
            "ref": [
                "refs/pull/**",
            ],
        },
    }]

def testPipelines(ctx):
    pipelines = []
    if "skip" not in config["localApiTests"] or not config["localApiTests"]["skip"]:
        pipelines = [
            localApiTests(ctx, "ocis", "apiAccountsHashDifficulty", "default"),
            localApiTests(ctx, "ocis", "apiSpaces", "default"),
            localApiTests(ctx, "ocis", "apiArchiver", "default"),
        ]

    if "skip" not in config["apiTests"] or not config["apiTests"]["skip"]:
        pipelines += apiTests(ctx)

    if "skip" not in config["uiTests"] or not config["uiTests"]["skip"]:
        pipelines += uiTests(ctx)

    if "skip" not in config["accountsUITests"] or not config["accountsUITests"]["skip"]:
        pipelines.append(accountsUITests(ctx))

    if "skip" not in config["settingsUITests"] or not config["settingsUITests"]["skip"]:
        pipelines.append(settingsUITests(ctx))

    if "skip" not in config["parallelApiTests"] or not config["parallelApiTests"]["skip"]:
        pipelines += parallelDeployAcceptancePipeline(ctx)

    return pipelines

def testOcisModule(ctx, module):
    steps = skipIfUnchanged(ctx, "unit-tests") + makeGoGenerate(module) + [
        {
            "name": "golangci-lint",
            "image": OC_CI_GOLANG,
            "commands": [
                "mkdir -p cache/checkstyle",
                "make -C %s ci-golangci-lint" % (module),
                "mv %s/checkstyle.xml cache/checkstyle/%s_checkstyle.xml" % (module, module),
            ],
            "volumes": [stepVolumeGo],
        },
        {
            "name": "test",
            "image": OC_CI_GOLANG,
            "commands": [
                "mkdir -p cache/coverage",
                "make -C %s test" % (module),
                "mv %s/coverage.out cache/coverage/%s_coverage.out" % (module, module),
            ],
            "volumes": [stepVolumeGo],
        },
        {
            "name": "scan-result-cache",
            "image": PLUGINS_S3,
            "settings": {
                "endpoint": {
                    "from_secret": "cache_s3_endpoint",
                },
                "bucket": "cache",
                "source": "cache/**/*",
                "target": "%s/%s" % (ctx.repo.slug, ctx.build.commit + "-${DRONE_BUILD_NUMBER}"),
                "path_style": True,
                "access_key": {
                    "from_secret": "cache_s3_access_key",
                },
                "secret_key": {
                    "from_secret": "cache_s3_secret_key",
                },
            },
        },
    ]

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "linting&unitTests-%s" % (module),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": steps,
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/tags/%s/v*" % (module),
                "refs/pull/**",
            ],
        },
        "volumes": [pipelineVolumeGo],
    }

def buildOcisBinaryForTesting(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build_ocis_binary_for_testing",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": skipIfUnchanged(ctx, "acceptance-tests") +
                 makeNodeGenerate("") +
                 makeGoGenerate("") +
                 build() +
                 rebuildBuildArtifactCache(ctx, "ocis-binary-amd64", "ocis/bin/ocis"),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
        "volumes": [pipelineVolumeGo],
    }

def uploadScanResults(ctx):
    sonar_env = {
        "SONAR_TOKEN": {
            "from_secret": "sonar_token",
        },
    }
    if ctx.build.event == "pull_request":
        sonar_env.update({
            "SONAR_PULL_REQUEST_BASE": "%s" % (ctx.build.target),
            "SONAR_PULL_REQUEST_BRANCH": "%s" % (ctx.build.source),
            "SONAR_PULL_REQUEST_KEY": "%s" % (ctx.build.ref.replace("refs/pull/", "").split("/")[0]),
        })

    fork_handling = []
    if ctx.build.source_repo != "" and ctx.build.source_repo != ctx.repo.slug:
        fork_handling = [
            "git remote add fork https://github.com/%s.git" % (ctx.build.source_repo),
            "git fetch fork",
        ]

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "upload-scan-results",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "clone": {
            "disable": True,  # Sonarcloud does not apply issues on already merged branch
        },
        "steps": [
            {
                "name": "clone",
                "image": ALPINE_GIT,
                "commands": [
                                # Always use the owncloud/ocis repository as base to have an up to date default branch.
                                # This is needed for the skipIfUnchanged step, since it references a commit on master (which could be absent on a fork)
                                "git clone https://github.com/%s.git ." % (ctx.repo.slug),
                            ] + fork_handling +
                            [
                                "git checkout $DRONE_COMMIT",
                            ],
            },
        ] + skipIfUnchanged(ctx, "unit-tests") + [
            {
                "name": "sync-from-cache",
                "image": MINIO_MC,
                "environment": {
                    "MC_HOST_cachebucket": {
                        "from_secret": "cache_s3_connection_url",
                    },
                },
                "commands": [
                    "mkdir -p cache",
                    "mc mirror cachebucket/cache/%s/%s/cache cache/" % (ctx.repo.slug, ctx.build.commit + "-${DRONE_BUILD_NUMBER}"),
                ],
            },
            {
                "name": "codacy",
                "image": PLUGINS_CODACY,
                "settings": {
                    "token": {
                        "from_secret": "codacy_token",
                    },
                },
            },
            {
                "name": "sonarcloud",
                "image": SONARSOURCE_SONAR_SCANNER_CLI,
                "environment": sonar_env,
            },
            {
                "name": "purge-cache",
                "image": MINIO_MC,
                "environment": {
                    "MC_HOST_cachebucket": {
                        "from_secret": "cache_s3_connection_url",
                    },
                },
                "commands": [
                    "mc rm --recursive --force cachebucket/cache/%s/%s/cache" % (ctx.repo.slug, ctx.build.commit + "-${DRONE_BUILD_NUMBER}"),
                ],
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
    }

def localApiTests(ctx, storage, suite, accounts_hash_difficulty = 4):
    early_fail = config["localApiTests"]["earlyFail"] if "earlyFail" in config["localApiTests"] else False

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "localApiTests-%s-%s" % (suite, storage),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": skipIfUnchanged(ctx, "acceptance-tests") + restoreBuildArtifactCache(ctx, "ocis-binary-amd64", "ocis/bin/ocis") +
                 ocisServer(storage, accounts_hash_difficulty, [stepVolumeOC10Tests]) +
                 cloneCoreRepos() + [
            {
                "name": "localApiTests-%s-%s" % (suite, storage),
                "image": OC_CI_PHP % DEFAULT_PHP_VERSION,
                "environment": {
                    "TEST_SERVER_URL": "https://ocis-server:9200",
                    "OCIS_REVA_DATA_ROOT": "%s" % ("/srv/app/tmp/ocis/owncloud/data/" if storage == "owncloud" else ""),
                    "SKELETON_DIR": "/srv/app/tmp/testing/data/apiSkeleton",
                    "OCIS_SKELETON_STRATEGY": "%s" % ("copy" if storage == "owncloud" else "upload"),
                    "TEST_OCIS": "true",
                    "SEND_SCENARIO_LINE_REFERENCES": "true",
                    "STORAGE_DRIVER": storage,
                    "BEHAT_SUITE": suite,
                    "BEHAT_FILTER_TAGS": "~@skip&&~@skipOnOcis-%s-Storage" % ("OC" if storage == "owncloud" else "OCIS"),
                    "PATH_TO_CORE": "/srv/app/testrunner",
                    "EXPECTED_FAILURES_FILE": "/drone/src/tests/acceptance/expected-failures-localAPI-on-%s-storage.md" % (storage.upper()),
                    "UPLOAD_DELETE_WAIT_TIME": "1" if storage == "owncloud" else 0,
                },
                "commands": [
                    "make test-acceptance-api",
                ],
                "volumes": [stepVolumeOC10Tests],
            },
        ] + failEarly(ctx, early_fail),
        "services": redisForOCStorage(storage),
        "depends_on": getPipelineNames([buildOcisBinaryForTesting(ctx)]),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
        "volumes": [pipelineVolumeOC10Tests],
    }

def coreApiTests(ctx, part_number = 1, number_of_parts = 1, storage = "ocis", accounts_hash_difficulty = 4):
    early_fail = config["apiTests"]["earlyFail"] if "earlyFail" in config["apiTests"] else False

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "Core-API-Tests-%s-storage-%s" % (storage, part_number),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": skipIfUnchanged(ctx, "acceptance-tests") + restoreBuildArtifactCache(ctx, "ocis-binary-amd64", "ocis/bin/ocis") +
                 ocisServer(storage, accounts_hash_difficulty, [stepVolumeOC10Tests]) +
                 cloneCoreRepos() + [
            {
                "name": "oC10ApiTests-%s-storage-%s" % (storage, part_number),
                "image": OC_CI_PHP % DEFAULT_PHP_VERSION,
                "environment": {
                    "TEST_SERVER_URL": "https://ocis-server:9200",
                    "OCIS_REVA_DATA_ROOT": "%s" % ("/srv/app/tmp/ocis/owncloud/data/" if storage == "owncloud" else ""),
                    "SKELETON_DIR": "/srv/app/tmp/testing/data/apiSkeleton",
                    "OCIS_SKELETON_STRATEGY": "%s" % ("copy" if storage == "owncloud" else "upload"),
                    "TEST_OCIS": "true",
                    "SEND_SCENARIO_LINE_REFERENCES": "true",
                    "STORAGE_DRIVER": storage,
                    "BEHAT_FILTER_TAGS": "~@skipOnOcis&&~@notToImplementOnOCIS&&~@toImplementOnOCIS&&~comments-app-required&&~@federation-app-required&&~@notifications-app-required&&~systemtags-app-required&&~@local_storage&&~@skipOnOcis-%s-Storage&&~@issue-ocis-3023" % ("OC" if storage == "owncloud" else "OCIS"),
                    "DIVIDE_INTO_NUM_PARTS": number_of_parts,
                    "RUN_PART": part_number,
                    "EXPECTED_FAILURES_FILE": "/drone/src/tests/acceptance/expected-failures-API-on-%s-storage.md" % (storage.upper()),
                    "UPLOAD_DELETE_WAIT_TIME": "1" if storage == "owncloud" else 0,
                },
                "commands": [
                    "make -C /srv/app/testrunner test-acceptance-api",
                ],
                "volumes": [stepVolumeOC10Tests],
            },
        ] + failEarly(ctx, early_fail),
        "services": redisForOCStorage(storage),
        "depends_on": getPipelineNames([buildOcisBinaryForTesting(ctx)]),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
        "volumes": [pipelineVolumeOC10Tests],
    }

def apiTests(ctx):
    pipelines = []
    debugParts = config["apiTests"]["skipExceptParts"]
    debugPartsEnabled = (len(debugParts) != 0)
    for runPart in range(1, config["apiTests"]["numberOfParts"] + 1):
        if (not debugPartsEnabled or (debugPartsEnabled and runPart in debugParts)):
            pipelines.append(coreApiTests(ctx, runPart, config["apiTests"]["numberOfParts"], "ocis"))

    return pipelines

def uiTests(ctx):
    default = {
        "filterTags": "",
        "skip": False,
        "earlyFail": False,
        # only used if 'full-ci' is in build title or if run by cron
        "numberOfParts": 20,
        "skipExceptParts": [],
    }
    params = {}
    pipelines = []

    for item in default:
        params[item] = config["uiTests"][item] if item in config["uiTests"] else default[item]

    filterTags = params["filterTags"]
    earlyFail = params["earlyFail"]

    if ("full-ci" in ctx.build.title.lower() or ctx.build.event == "tag" or ctx.build.event == "cron"):
        numberOfParts = params["numberOfParts"]
        skipExceptParts = params["skipExceptParts"]
        debugPartsEnabled = (len(skipExceptParts) != 0)

        for runPart in range(1, numberOfParts + 1):
            if (not debugPartsEnabled or (debugPartsEnabled and runPart in skipExceptParts)):
                pipelines.append(uiTestPipeline(ctx, "", earlyFail, runPart, numberOfParts))

    # For ordinary PRs, always run the "minimal" UI test pipeline
    # That has its own expected-failures file, and we always want to know that it is correct,
    if (ctx.build.event != "tag"):
        pipelines.append(uiTestPipeline(ctx, filterTags, earlyFail, 1, 2, "ocis", "smoke"))
        pipelines.append(uiTestPipeline(ctx, filterTags, earlyFail, 2, 2, "ocis", "smoke"))

    return pipelines

def uiTestPipeline(ctx, filterTags, early_fail, runPart = 1, numberOfParts = 1, storage = "ocis", uniqueName = "", accounts_hash_difficulty = 4):
    standardFilterTags = "not @skipOnOCIS and not @skip and not @notToImplementOnOCIS and not @federated-server-needed"
    if filterTags == "":
        finalFilterTags = standardFilterTags
        expectedFailuresFileFilterTags = ""
    else:
        finalFilterTags = filterTags + " and " + standardFilterTags
        expectedFailuresFileFilterTags = "-" + filterTags.lstrip("@")

    if uniqueName == "":
        uniqueNameString = ""
    else:
        finalFilterTags = filterTags + " and " + standardFilterTags
        uniqueNameString = "-" + uniqueName

    if numberOfParts == 1:
        pipelineName = "Web-Tests-ocis%s-%s-storage" % (uniqueNameString, storage)
    else:
        pipelineName = "Web-Tests-ocis%s-%s-storage-%s" % (uniqueNameString, storage, runPart)

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": pipelineName,
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": skipIfUnchanged(ctx, "acceptance-tests") + restoreBuildArtifactCache(ctx, "ocis-binary-amd64", "ocis/bin/ocis") +
                 ocisServer(storage, accounts_hash_difficulty, [stepVolumeOC10Tests]) + waitForSeleniumService() + waitForMiddlewareService() + [
            {
                "name": "webUITests",
                "image": OC_CI_NODEJS % DEFAULT_NODEJS_VERSION,
                "environment": {
                    "SERVER_HOST": "https://ocis-server:9200",
                    "BACKEND_HOST": "https://ocis-server:9200",
                    "RUN_ON_OCIS": "true",
                    "OCIS_REVA_DATA_ROOT": "/srv/app/tmp/ocis/owncloud/data",
                    "TESTING_DATA_DIR": "/srv/app/testing/data",
                    "WEB_UI_CONFIG": "/drone/src/tests/config/drone/ocis-config.json",
                    "TEST_TAGS": finalFilterTags,
                    "LOCAL_UPLOAD_DIR": "/uploads",
                    "NODE_TLS_REJECT_UNAUTHORIZED": 0,
                    "RUN_PART": runPart,
                    "DIVIDE_INTO_NUM_PARTS": numberOfParts,
                    "EXPECTED_FAILURES_FILE": "/drone/src/tests/acceptance/expected-failures-webUI-on-%s-storage%s.md" % (storage.upper(), expectedFailuresFileFilterTags),
                    "MIDDLEWARE_HOST": "http://middleware:3000",
                },
                "commands": [
                    ". /drone/src/.drone.env",
                    "git clone -b master --depth=1 https://github.com/owncloud/testing.git /srv/app/testing",
                    "git clone -b $WEB_BRANCH --single-branch --no-tags https://github.com/owncloud/web.git /srv/app/web",
                    "cd /srv/app/web",
                    "git checkout $WEB_COMMITID",
                    "cd tests/acceptance/",
                    "yarn install --immutable",
                    "./run.sh",
                ],
            },
        ] + failEarly(ctx, early_fail),
        "services": selenium() + middlewareService(),
        "volumes": [pipelineVolumeOC10Tests] +
                   [{
                       "name": "uploads",
                       "temp": {},
                   }],
        "depends_on": getPipelineNames([buildOcisBinaryForTesting(ctx)]),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
    }

def accountsUITests(ctx, storage = "ocis", accounts_hash_difficulty = 4):
    early_fail = config["accountsUITests"]["earlyFail"] if "earlyFail" in config["accountsUITests"] else False

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "accountsUITests",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": skipIfUnchanged(ctx, "acceptance-tests") + restoreBuildArtifactCache(ctx, "ocis-binary-amd64", "ocis/bin/ocis") +
                 ocisServer(storage, accounts_hash_difficulty, [stepVolumeOC10Tests]) + waitForSeleniumService() + waitForMiddlewareService() + [
            {
                "name": "WebUIAcceptanceTests",
                "image": OC_CI_NODEJS % DEFAULT_NODEJS_VERSION,
                "environment": {
                    "SERVER_HOST": "https://ocis-server:9200",
                    "BACKEND_HOST": "https://ocis-server:9200",
                    "RUN_ON_OCIS": "true",
                    "OCIS_REVA_DATA_ROOT": "/srv/app/tmp/ocis/owncloud/data",
                    "WEB_UI_CONFIG": "/drone/src/tests/config/drone/ocis-config.json",
                    "TEST_TAGS": "not @skipOnOCIS and not @skip",
                    "LOCAL_UPLOAD_DIR": "/uploads",
                    "NODE_TLS_REJECT_UNAUTHORIZED": 0,
                    "WEB_PATH": "/srv/app/web",
                    "FEATURE_PATH": "/drone/src/accounts/ui/tests/acceptance/features",
                    "MIDDLEWARE_HOST": "http://middleware:3000",
                },
                "commands": [
                    ". /drone/src/.drone.env",
                    # we need to have Web around for some general step definitions (eg. how to log in)
                    "git clone -b $WEB_BRANCH --single-branch --no-tags https://github.com/owncloud/web.git /srv/app/web",
                    "cd /srv/app/web",
                    "git checkout $WEB_COMMITID",
                    # TODO: settings/package.json has all the acceptance test dependencies
                    # they shouldn't be needed since we could also use them from web:/tests/acceptance/package.json
                    "cd /drone/src/accounts",
                    "yarn install --immutable",
                    "make test-acceptance-webui",
                ],
                "volumes": [stepVolumeOC10Tests] +
                           [{
                               "name": "uploads",
                               "path": "/uploads",
                           }],
            },
        ] + failEarly(ctx, early_fail),
        "services": selenium() + middlewareService(),
        "volumes": [stepVolumeOC10Tests] +
                   [{
                       "name": "uploads",
                       "temp": {},
                   }],
        "depends_on": getPipelineNames([buildOcisBinaryForTesting(ctx)]),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
    }

def settingsUITests(ctx, storage = "ocis", accounts_hash_difficulty = 4):
    early_fail = config["settingsUITests"]["earlyFail"] if "earlyFail" in config["settingsUITests"] else False

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "settingsUITests",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": skipIfUnchanged(ctx, "acceptance-tests") + restoreBuildArtifactCache(ctx, "ocis-binary-amd64", "ocis/bin/ocis") +
                 ocisServer(storage, accounts_hash_difficulty, [stepVolumeOC10Tests]) + waitForSeleniumService() + waitForMiddlewareService() + [
            {
                "name": "WebUIAcceptanceTests",
                "image": OC_CI_NODEJS % DEFAULT_NODEJS_VERSION,
                "environment": {
                    "SERVER_HOST": "https://ocis-server:9200",
                    "BACKEND_HOST": "https://ocis-server:9200",
                    "RUN_ON_OCIS": "true",
                    "OCIS_REVA_DATA_ROOT": "/srv/app/tmp/ocis/owncloud/data",
                    "WEB_UI_CONFIG": "/drone/src/tests/config/drone/ocis-config.json",
                    "TEST_TAGS": "not @skipOnOCIS and not @skip",
                    "LOCAL_UPLOAD_DIR": "/uploads",
                    "NODE_TLS_REJECT_UNAUTHORIZED": 0,
                    "WEB_PATH": "/srv/app/web",
                    "FEATURE_PATH": "/drone/src/settings/ui/tests/acceptance/features",
                    "MIDDLEWARE_HOST": "http://middleware:3000",
                },
                "commands": [
                    ". /drone/src/.drone.env",
                    # we need to have Web around for some general step definitions (eg. how to log in)
                    "git clone -b $WEB_BRANCH --single-branch --no-tags https://github.com/owncloud/web.git /srv/app/web",
                    "cd /srv/app/web",
                    "git checkout $WEB_COMMITID",
                    # TODO: settings/package.json has all the acceptance test dependencies
                    # they shouldn't be needed since we could also use them from web:/tests/acceptance/package.json
                    "cd /drone/src/settings",
                    "yarn install --immutable",
                    "make test-acceptance-webui",
                ],
                "volumes": [stepVolumeOC10Tests] +
                           [{
                               "name": "uploads",
                               "path": "/uploads",
                           }],
            },
        ] + failEarly(ctx, early_fail),
        "services": [
            {
                "name": "redis",
                "image": REDIS,
            },
        ] + selenium() + middlewareService(),
        "volumes": [stepVolumeOC10Tests] +
                   [{
                       "name": "uploads",
                       "temp": {},
                   }],
        "depends_on": getPipelineNames([buildOcisBinaryForTesting(ctx)]),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
    }

def failEarly(ctx, early_fail):
    """failEarly sends posts a comment about the failed pipeline to the github pr and then kills all pipelines of the current build

    Args:
        ctx: drone passes a context with information which the pipeline can be adapted to
        early_fail: boolean if an early fail should happen or not

    Returns:
        pipeline steps
    """
    if ("full-ci" in ctx.build.title.lower() or ctx.build.event == "tag" or ctx.build.event == "cron"):
        return []

    if (early_fail):
        return [
            {
                "name": "github-comment",
                "image": THEGEEKLAB_DRONE_GITHUB_COMMENT,
                "settings": {
                    "message": ":boom: Acceptance test [<strong>${DRONE_STAGE_NAME}</strong>](${DRONE_BUILD_LINK}/${DRONE_STAGE_NUMBER}/1) failed. Further test are cancelled...",
                    "key": "pr-${DRONE_PULL_REQUEST}",  #TODO: we could delete the comment after a successful CI run
                    "update": "true",
                    "api_key": {
                        "from_secret": "github_token",
                    },
                },
                "when": {
                    "status": [
                        "failure",
                    ],
                    "event": [
                        "pull_request",
                    ],
                },
            },
            {
                "name": "stop-build",
                "image": DRONE_CLI,
                # # https://github.com/drone/runner-go/blob/0bd0f8fc31c489817572060d17c6e24aaa487470/pipeline/runtime/const.go#L95-L102
                # "failure": "fail-fast",
                # would be an alternative, but is currently broken
                "environment": {
                    "DRONE_SERVER": "https://drone.owncloud.com",
                    "DRONE_TOKEN": {
                        "from_secret": "drone_token",
                    },
                },
                "commands": [
                    "drone build stop owncloud/ocis ${DRONE_BUILD_NUMBER}",
                ],
                "when": {
                    "status": [
                        "failure",
                    ],
                    "event": [
                        "pull_request",
                    ],
                },
            },
        ]

    return []

def dockerReleases(ctx):
    pipelines = []
    for arch in config["dockerReleases"]["architectures"]:
        pipelines.append(dockerRelease(ctx, arch))

    manifest = releaseDockerManifest(ctx)
    manifest["depends_on"] = getPipelineNames(pipelines)
    pipelines.append(manifest)

    readme = releaseDockerReadme(ctx)
    readme["depends_on"] = getPipelineNames(pipelines)
    pipelines.append(readme)

    return pipelines

def dockerRelease(ctx, arch):
    build_args = [
        "REVISION=%s" % (ctx.build.commit),
        "VERSION=%s" % (ctx.build.ref.replace("refs/tags/", "") if ctx.build.event == "tag" else "latest"),
    ]

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "docker-%s" % (arch),
        "platform": {
            "os": "linux",
            "arch": arch,
        },
        "steps": skipIfUnchanged(ctx, "build-docker") +
                 makeNodeGenerate("") +
                 makeGoGenerate("") + [
            {
                "name": "build",
                "image": OC_CI_GOLANG,
                "commands": [
                    "make -C ocis release-linux-docker-%s" % (arch),
                ],
            },
            {
                "name": "dryrun",
                "image": PLUGINS_DOCKER,
                "settings": {
                    "dry_run": True,
                    "context": "ocis",
                    "tags": "linux-%s" % (arch),
                    "dockerfile": "ocis/docker/Dockerfile.linux.%s" % (arch),
                    "repo": ctx.repo.slug,
                    "build_args": build_args,
                },
                "when": {
                    "ref": {
                        "include": [
                            "refs/pull/**",
                        ],
                    },
                },
            },
            {
                "name": "docker",
                "image": PLUGINS_DOCKER,
                "settings": {
                    "username": {
                        "from_secret": "docker_username",
                    },
                    "password": {
                        "from_secret": "docker_password",
                    },
                    "auto_tag": True,
                    "context": "ocis",
                    "auto_tag_suffix": "linux-%s" % (arch),
                    "dockerfile": "ocis/docker/Dockerfile.linux.%s" % (arch),
                    "repo": ctx.repo.slug,
                    "build_args": build_args,
                },
                "when": {
                    "ref": {
                        "exclude": [
                            "refs/pull/**",
                        ],
                    },
                },
            },
        ],
        "depends_on": getPipelineNames(testOcisModules(ctx) + testPipelines(ctx)),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
        "volumes": [pipelineVolumeGo],
    }

def binaryReleases(ctx):
    pipelines = []
    for os in config["binaryReleases"]["os"]:
        pipelines.append(binaryRelease(ctx, os))

    return pipelines

def binaryRelease(ctx, name):
    # uploads binary to https://download.owncloud.com/ocis/ocis/daily/
    target = "/ocis/%s/daily" % (ctx.repo.name.replace("ocis-", ""))
    if ctx.build.event == "tag":
        # uploads binary to eg. https://download.owncloud.com/ocis/ocis/1.0.0-beta9/
        folder = "stable"
        buildref = ctx.build.ref.replace("refs/tags/v", "")
        buildref = buildref.lower()
        if buildref.find("-") != -1:  # "x.x.x-alpha", "x.x.x-beta", "x.x.x-rc"
            folder = "testing"
        target = "/ocis/%s/%s/%s" % (ctx.repo.name.replace("ocis-", ""), folder, buildref)

    settings = {
        "endpoint": {
            "from_secret": "s3_endpoint",
        },
        "access_key": {
            "from_secret": "aws_access_key_id",
        },
        "secret_key": {
            "from_secret": "aws_secret_access_key",
        },
        "bucket": {
            "from_secret": "s3_bucket",
        },
        "path_style": True,
        "strip_prefix": "ocis/dist/release/",
        "source": "ocis/dist/release/*",
        "target": target,
    }

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "binaries-%s" % (name),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": skipIfUnchanged(ctx, "build-binary") +
                 makeNodeGenerate("") +
                 makeGoGenerate("") + [
            {
                "name": "build",
                "image": OC_CI_GOLANG,
                "commands": [
                    "make -C ocis release-%s" % (name),
                ],
            },
            {
                "name": "finish",
                "image": OC_CI_GOLANG,
                "commands": [
                    "make -C ocis release-finish",
                ],
                "when": {
                    "ref": [
                        "refs/heads/master",
                        "refs/tags/v*",
                    ],
                },
            },
            {
                "name": "upload",
                "image": PLUGINS_S3,
                "settings": settings,
                "when": {
                    "ref": [
                        "refs/heads/master",
                        "refs/tags/v*",
                    ],
                },
            },
            {
                "name": "changelog",
                "image": OC_CI_GOLANG,
                "commands": [
                    "make changelog CHANGELOG_VERSION=%s" % ctx.build.ref.replace("refs/tags/v", "").split("-")[0],
                ],
                "when": {
                    "ref": [
                        "refs/tags/v*",
                    ],
                },
            },
            {
                "name": "release",
                "image": PLUGINS_GITHUB_RELEASE,
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "ocis/dist/release/*",
                    ],
                    "title": ctx.build.ref.replace("refs/tags/v", ""),
                    "note": "ocis/dist/CHANGELOG.md",
                    "overwrite": True,
                    "prerelease": len(ctx.build.ref.split("-")) > 1,
                },
                "when": {
                    "ref": [
                        "refs/tags/v*",
                    ],
                },
            },
        ],
        "depends_on": getPipelineNames(testOcisModules(ctx) + testPipelines(ctx)),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
        "volumes": [pipelineVolumeGo],
    }

def releaseSubmodule(ctx):
    depends = []
    if len(ctx.build.ref.replace("refs/tags/", "").split("/")) == 2:
        depends = ["linting&unitTests-%s" % (ctx.build.ref.replace("refs/tags/", "").split("/")[0])]

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "release-%s" % (ctx.build.ref.replace("refs/tags/", "")),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "release-submodule",
                "image": PLUGINS_GITHUB_RELEASE,
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                    ],
                    "title": ctx.build.ref.replace("refs/tags/", "").replace("/v", " "),
                    "note": "Release %s submodule" % (ctx.build.ref.replace("refs/tags/", "").replace("/v", " ")),
                    "overwrite": True,
                    "prerelease": len(ctx.build.ref.split("-")) > 1,
                },
                "when": {
                    "ref": [
                        "refs/tags/*/v*",
                    ],
                },
            },
        ],
        "depends_on": depends,
        "trigger": {
            "ref": [
                "refs/tags/*/v*",
            ],
        },
    }

def releaseDockerManifest(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "manifest",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "execute",
                "image": PLUGINS_MANIFEST,
                "settings": {
                    "username": {
                        "from_secret": "docker_username",
                    },
                    "password": {
                        "from_secret": "docker_password",
                    },
                    "spec": "ocis/docker/manifest.tmpl",
                    "auto_tag": True,
                    "ignore_missing": True,
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
            ],
        },
    }

def changelog(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "changelog",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "generate",
                "image": OC_CI_GOLANG,
                "commands": [
                    "make -C ocis changelog",
                ],
            },
            {
                "name": "diff",
                "image": OC_CI_ALPINE,
                "commands": [
                    "git diff",
                ],
            },
            {
                "name": "output",
                "image": OC_CI_ALPINE,
                "commands": [
                    "cat CHANGELOG.md",
                ],
            },
            {
                "name": "publish",
                "image": PLUGINS_GIT_ACTION,
                "settings": {
                    "actions": [
                        "commit",
                        "push",
                    ],
                    "message": "Automated changelog update [skip ci]",
                    "branch": "master",
                    "author_email": "devops@owncloud.com",
                    "author_name": "ownClouders",
                    "netrc_machine": "github.com",
                    "netrc_username": {
                        "from_secret": "github_username",
                    },
                    "netrc_password": {
                        "from_secret": "github_token",
                    },
                },
                "when": {
                    "ref": {
                        "exclude": [
                            "refs/pull/**",
                        ],
                    },
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/pull/**",
            ],
        },
    }

def releaseDockerReadme(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "readme",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "execute",
                "image": CHKO_DOCKER_PUSHRM,
                "environment": {
                    "DOCKER_USER": {
                        "from_secret": "docker_username",
                    },
                    "DOCKER_PASS": {
                        "from_secret": "docker_password",
                    },
                    "PUSHRM_TARGET": "owncloud/${DRONE_REPO_NAME}",
                    "PUSHRM_SHORT": "Docker images for %s" % (ctx.repo.name),
                    "PUSHRM_FILE": "README.md",
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
            ],
        },
    }

def docs(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "docs",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "docs-generate",
                "image": OC_CI_GOLANG,
                "commands": ["make -C docs docs-generate"],
            },
            {
                "name": "prepare",
                "image": OC_CI_GOLANG,
                "commands": [
                    "make -C docs docs-copy",
                ],
            },
            {
                "name": "test",
                "image": OC_CI_GOLANG,
                "commands": [
                    "make -C docs test",
                ],
            },
            {
                "name": "publish",
                "image": PLUGINS_GH_PAGES,
                "settings": {
                    "username": {
                        "from_secret": "github_username",
                    },
                    "password": {
                        "from_secret": "github_token",
                    },
                    "pages_directory": "docs/hugo/content",
                    "target_branch": "docs",
                },
                "when": {
                    "ref": {
                        "exclude": [
                            "refs/pull/**",
                        ],
                    },
                },
            },
            {
                "name": "list and remove temporary files",
                "image": OC_CI_ALPINE,
                "commands": [
                    "tree docs/hugo/public",
                    "rm -rf docs/hugo",
                ],
            },
            {
                "name": "downstream",
                "image": PLUGINS_DOWNSTREAM,
                "settings": {
                    "server": "https://drone.owncloud.com/",
                    "token": {
                        "from_secret": "drone_token",
                    },
                    "repositories": [
                        "owncloud/owncloud.github.io@source",
                    ],
                },
                "when": {
                    "ref": {
                        "exclude": [
                            "refs/pull/**",
                        ],
                    },
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/pull/**",
            ],
        },
    }

def makeNodeGenerate(module):
    if module == "":
        make = "make"
    else:
        make = "make -C %s" % (module)
    return [
        {
            "name": "generate nodejs",
            "image": OC_CI_NODEJS % DEFAULT_NODEJS_VERSION,
            "environment": {
                "CHROMEDRIVER_SKIP_DOWNLOAD": "true",  # install fails on arm and chromedriver is a test only dependency
            },
            "commands": [
                "%s ci-node-generate" % (make),
            ],
            "volumes": [stepVolumeGo],
        },
    ]

def makeGoGenerate(module):
    if module == "":
        make = "make"
    else:
        make = "make -C %s" % (module)
    return [
        {
            "name": "generate go",
            "image": OC_CI_GOLANG,
            "commands": [
                "%s ci-go-generate" % (make),
            ],
            "volumes": [stepVolumeGo],
        },
    ]

def notify(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "chat-notifications",
        "clone": {
            "disable": True,
        },
        "steps": [
            {
                "name": "notify-rocketchat",
                "image": PLUGINS_SLACK,
                "settings": {
                    "webhook": {
                        "from_secret": config["rocketchat"]["from_secret"],
                    },
                    "channel": config["rocketchat"]["channel"],
                },
            },
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/release*",
                "refs/tags/**",
            ],
            "status": [
                "failure",
            ],
        },
    }

def ocisServer(storage, accounts_hash_difficulty = 4, volumes = [], depends_on = [], testing_parallel_deploy = False):
    if not testing_parallel_deploy:
        user = "0:0"
        environment = {
            "OCIS_URL": "https://ocis-server:9200",
            "STORAGE_HOME_DRIVER": "%s" % (storage),
            "STORAGE_USERS_DRIVER": "%s" % (storage),
            "STORAGE_USERS_DRIVER_LOCAL_ROOT": "/srv/app/tmp/ocis/local/root",
            "STORAGE_USERS_DRIVER_OCIS_ROOT": "/srv/app/tmp/ocis/storage/users",
            "STORAGE_METADATA_DRIVER_OCIS_ROOT": "/srv/app/tmp/ocis/storage/metadata",
            "STORAGE_SHARING_USER_JSON_FILE": "/srv/app/tmp/ocis/shares.json",
            "PROXY_ENABLE_BASIC_AUTH": True,
            "WEB_UI_CONFIG": "/drone/src/tests/config/drone/ocis-config.json",
            "IDP_IDENTIFIER_REGISTRATION_CONF": "/drone/src/tests/config/drone/identifier-registration.yml",
            "OCIS_LOG_LEVEL": "error",
            "SETTINGS_DATA_PATH": "/srv/app/tmp/ocis/settings",
            "OCIS_INSECURE": "true",
        }
    else:
        user = "33:33"
        environment = {
            # Keycloak IDP specific configuration
            "PROXY_OIDC_ISSUER": "https://keycloak/auth/realms/owncloud",
            "WEB_OIDC_AUTHORITY": "https://keycloak/auth/realms/owncloud",
            "WEB_OIDC_CLIENT_ID": "ocis-web",
            "WEB_OIDC_METADATA_URL": "https://keycloak/auth/realms/owncloud/.well-known/openid-configuration",
            "STORAGE_OIDC_ISSUER": "https://keycloak",
            "STORAGE_LDAP_IDP": "https://keycloak/auth/realms/owncloud",
            "WEB_OIDC_SCOPE": "openid profile email owncloud",
            # LDAP bind
            "STORAGE_LDAP_HOSTNAME": "openldap",
            "STORAGE_LDAP_PORT": 636,
            "STORAGE_LDAP_INSECURE": "true",
            "STORAGE_LDAP_BIND_DN": "cn=admin,dc=owncloud,dc=com",
            "STORAGE_LDAP_BIND_PASSWORD": "admin",
            # LDAP user settings
            "PROXY_AUTOPROVISION_ACCOUNTS": "true",  # automatically create users when they login
            "PROXY_ACCOUNT_BACKEND_TYPE": "cs3",  # proxy should get users from CS3APIS (which gets it from LDAP)
            "PROXY_USER_OIDC_CLAIM": "ocis.user.uuid",  # claim was added in Keycloak
            "PROXY_USER_CS3_CLAIM": "userid",  # equals STORAGE_LDAP_USER_SCHEMA_UID
            "STORAGE_LDAP_BASE_DN": "dc=owncloud,dc=com",
            "STORAGE_LDAP_GROUP_SCHEMA_DISPLAYNAME": "cn",
            "STORAGE_LDAP_GROUP_SCHEMA_GID_NUMBER": "gidnumber",
            "STORAGE_LDAP_GROUP_SCHEMA_GID": "cn",
            "STORAGE_LDAP_GROUP_SCHEMA_MAIL": "mail",
            "STORAGE_LDAP_GROUPATTRIBUTEFILTER": "(&(objectclass=posixGroup)(objectclass=owncloud)({{attr}}={{value}}))",
            "STORAGE_LDAP_GROUPFILTER": "(&(objectclass=groupOfUniqueNames)(objectclass=owncloud)(ownclouduuid={{.OpaqueId}}*))",
            "STORAGE_LDAP_GROUPMEMBERFILTER": "(&(objectclass=posixAccount)(objectclass=owncloud)(ownclouduuid={{.OpaqueId}}*))",
            "STORAGE_LDAP_USERGROUPFILTER": "(&(objectclass=posixGroup)(objectclass=owncloud)(ownclouduuid={{.OpaqueId}}*))",
            "STORAGE_LDAP_USER_SCHEMA_CN": "cn",
            "STORAGE_LDAP_USER_SCHEMA_DISPLAYNAME": "displayname",
            "STORAGE_LDAP_USER_SCHEMA_GID_NUMBER": "gidnumber",
            "STORAGE_LDAP_USER_SCHEMA_MAIL": "mail",
            "STORAGE_LDAP_USER_SCHEMA_UID_NUMBER": "uidnumber",
            "STORAGE_LDAP_USER_SCHEMA_UID": "ownclouduuid",
            "STORAGE_LDAP_LOGINFILTER": "(&(objectclass=posixAccount)(objectclass=owncloud)(|(uid={{login}})(mail={{login}})))",
            "STORAGE_LDAP_USERATTRIBUTEFILTER": "(&(objectclass=posixAccount)(objectclass=owncloud)({{attr}}={{value}}))",
            "STORAGE_LDAP_USERFILTER": "(&(objectclass=posixAccount)(objectclass=owncloud)(|(ownclouduuid={{.OpaqueId}})(uid={{.OpaqueId}})))",
            "STORAGE_LDAP_USERFINDFILTER": "(&(objectclass=posixAccount)(objectclass=owncloud)(|(cn={{query}}*)(displayname={{query}}*)(mail={{query}}*)))",
            # ownCloudSQL storage driver
            "STORAGE_HOME_DRIVER": "owncloudsql",
            "STORAGE_USERS_DRIVER": "owncloudsql",
            "STORAGE_METADATA_DRIVER": "ocis",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_DATADIR": "/mnt/data/files",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_UPLOADINFO_DIR": "/tmp",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_SHARE_FOLDER": "/Shares",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_LAYOUT": "{{.Username}}",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_DBUSERNAME": "owncloud",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_DBPASSWORD": "owncloud",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_DBHOST": "oc10-db",
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_DBPORT": 3306,
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_DBNAME": "owncloud",
            # TODO: redis is not yet supported
            "STORAGE_USERS_DRIVER_OWNCLOUDSQL_REDIS_ADDR": "redis:6379",
            # ownCloudSQL sharing driver
            "STORAGE_SHARING_USER_DRIVER": "oc10-sql",
            "STORAGE_SHARING_USER_SQL_USERNAME": "owncloud",
            "STORAGE_SHARING_USER_SQL_PASSWORD": "owncloud",
            "STORAGE_SHARING_USER_SQL_HOST": "oc10-db",
            "STORAGE_SHARING_USER_SQL_PORT": 3306,
            "STORAGE_SHARING_USER_SQL_NAME": "owncloud",
            # ownCloud storage readonly
            # TODO: conflict with OWNCLOUDSQL -> https://github.com/owncloud/ocis/issues/2303
            "OCIS_STORAGE_READ_ONLY": "false",
            # General oCIS config
            # OCIS_RUN_EXTENSIONS specifies to start all extensions except glauth, idp and accounts. These are replaced by external services
            "OCIS_RUN_EXTENSIONS": "settings,storage-metadata,graph,graph-explorer,ocs,store,thumbnails,web,webdav,storage-frontend,storage-gateway,storage-userprovider,storage-groupprovider,storage-authbasic,storage-authbearer,storage-authmachine,storage-users,storage-shares,storage-public-link,storage-appprovider,storage-sharing,proxy,nats",
            "OCIS_LOG_LEVEL": "error",
            "OCIS_URL": OCIS_URL,
            "PROXY_TLS": "true",
            "OCIS_BASE_DATA_PATH": "/mnt/data/ocis",
            # change default secrets
            "OCIS_JWT_SECRET": "Pive-Fumkiu4",
            "STORAGE_TRANSFER_SECRET": "replace-me-with-a-transfer-secret",
            "OCIS_MACHINE_AUTH_API_KEY": "change-me-please",
            "OCIS_INSECURE": "true",
            "PROXY_ENABLE_BASIC_AUTH": "true",
        }

    # Pass in "default" accounts_hash_difficulty to not set this environment variable.
    # That will allow OCIS to use whatever its built-in default is.
    # Otherwise pass in a value from 4 to about 11 or 12 (default 4, for making regular tests fast)
    # The high values cause lots of CPU to be used when hashing passwords, and really slow down the tests.
    if (accounts_hash_difficulty != "default"):
        environment["ACCOUNTS_HASH_DIFFICULTY"] = accounts_hash_difficulty

    return [
        {
            "name": "ocis-server",
            "image": OC_CI_ALPINE,
            "detach": True,
            "environment": environment,
            "user": user,
            "commands": [
                "ocis/bin/ocis server",
            ],
            "volumes": volumes,
            "depends_on": depends_on,
        },
        {
            "name": "wait-for-ocis-server",
            "image": OC_CI_WAIT_FOR,
            "commands": [
                "wait-for -it ocis-server:9200 -t 300",
            ],
            "depends_on": depends_on,
        },
    ]

def middlewareService():
    return [{
        "name": "middleware",
        "image": OC_OC_TEST_MIDDLEWARE,
        "environment": {
            "BACKEND_HOST": "https://ocis-server:9200",
            "OCIS_REVA_DATA_ROOT": "/srv/app/tmp/ocis/storage/owncloud/",
            "RUN_ON_OCIS": "true",
            "HOST": "middleware",
            "REMOTE_UPLOAD_DIR": "/uploads",
            "NODE_TLS_REJECT_UNAUTHORIZED": "0",
            "MIDDLEWARE_HOST": "middleware",
        },
        "volumes": [{
            "name": "uploads",
            "path": "/uploads",
        }, {
            "name": "gopath",
            "path": "/srv/app",
        }],
    }]

def waitForMiddlewareService():
    return [{
        "name": "wait-for-middleware-service",
        "image": OC_CI_WAIT_FOR,
        "commands": [
            "wait-for -it middleware:3000 -t 300",
        ],
    }]

def cloneCoreRepos():
    return [
        {
            "name": "clone-core-repos",
            "image": OC_CI_ALPINE,
            "commands": [
                "source /drone/src/.drone.env",
                "git clone -b master --depth=1 https://github.com/owncloud/testing.git /srv/app/tmp/testing",
                "git clone -b $CORE_BRANCH --single-branch --no-tags https://github.com/owncloud/core.git /srv/app/testrunner",
                "cd /srv/app/testrunner",
                "git checkout $CORE_COMMITID",
            ],
            "volumes": [stepVolumeOC10Tests],
        },
    ]

def redis():
    return [
        {
            "name": "redis",
            "image": REDIS,
        },
    ]

def redisForOCStorage(storage = "ocis"):
    if storage == "owncloud":
        return redis()
    else:
        return

def selenium():
    return [
        {
            "name": "selenium",
            "image": SELENIUM_STANDALONE_CHROME_DEBUG,
            "volumes": [{
                "name": "uploads",
                "path": "/uploads",
            }],
        },
    ]

def waitForSeleniumService():
    return [{
        "name": "wait-for-selenium-service",
        "image": OC_CI_WAIT_FOR,
        "commands": [
            "wait-for -it selenium:4444 -t 300",
        ],
    }]

def build():
    return [
        {
            "name": "build",
            "image": OC_CI_GOLANG,
            "commands": [
                "make -C ocis build",
            ],
            "volumes": [stepVolumeGo],
        },
    ]

def skipIfUnchanged(ctx, type):
    if ("full-ci" in ctx.build.title.lower() or ctx.build.event == "tag" or ctx.build.event == "cron"):
        return []

    base = [
        "^.github/.*",
        "^.vscode/.*",
        "^changelog/.*",
        "^docs/.*",
        "^deployments/.*",
    ]
    unit = [
        ".*_test.go$",
    ]
    acceptance = [
        "^tests/acceptance/.*",
    ]

    skip = []
    if type == "acceptance-tests":
        skip = base + unit
    if type == "unit-tests":
        skip = base + acceptance
    if type == "build-binary" or type == "build-docker":
        skip = base + unit + acceptance

    if len(skip) == 0:
        return []

    return [{
        "name": "skip-if-unchanged",
        "image": OC_CI_DRONE_SKIP_PIPELINE,
        "settings": {
            "ALLOW_SKIP_CHANGED": skip,
        },
        "when": {
            "event": [
                "pull_request",
            ],
        },
    }]

def example_deploys(ctx):
    latest_configs = [
        "ocis_ldap/latest.yml",
        "ocis_keycloak/latest.yml",
        "ocis_traefik/latest.yml",
        "ocis_wopi/latest.yml",
        "ocis_hello/latest.yml",
        "ocis_s3/latest.yml",
        "oc10_ocis_parallel/latest.yml",
        "ocis_individual_services/latest.yml",
    ]
    released_configs = [
        "ocis_ldap/released.yml",
        "ocis_keycloak/released.yml",
        "ocis_traefik/released.yml",
        "ocis_wopi/released.yml",
    ]

    # if on master branch:
    configs = latest_configs
    rebuild = "false"

    if ctx.build.event == "tag":
        configs = released_configs
        rebuild = "false"

    if ctx.build.event == "cron":
        configs = latest_configs + released_configs
        rebuild = "true"

    deploys = []
    for config in configs:
        deploys.append(deploy(ctx, config, rebuild))

    return deploys

def deploy(ctx, config, rebuild):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "deploy_%s" % (config),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "clone continuous deployment playbook",
                "image": ALPINE_GIT,
                "commands": [
                    "cd deployments/continuous-deployment-config",
                    "git clone https://github.com/owncloud-devops/continuous-deployment.git",
                ],
            },
            {
                "name": "deploy",
                "image": OC_CI_DRONE_ANSIBLE,
                "failure": "ignore",
                "environment": {
                    "CONTINUOUS_DEPLOY_SERVERS_CONFIG": "../%s" % (config),
                    "REBUILD": "%s" % (rebuild),
                    "HCLOUD_API_TOKEN": {
                        "from_secret": "hcloud_api_token",
                    },
                    "CLOUDFLARE_API_TOKEN": {
                        "from_secret": "cloudflare_api_token",
                    },
                },
                "settings": {
                    "playbook": "deployments/continuous-deployment-config/continuous-deployment/playbook-all.yml",
                    "galaxy": "deployments/continuous-deployment-config/continuous-deployment/requirements.yml",
                    "requirements": "deployments/continuous-deployment-config/continuous-deployment/py-requirements.txt",
                    "inventory": "localhost",
                    "private_key": {
                        "from_secret": "ssh_private_key",
                    },
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
            ],
        },
    }

def checkStarlark():
    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "check-starlark",
        "steps": [
            {
                "name": "format-check-starlark",
                "image": OC_CI_BAZEL_BUILDIFIER,
                "commands": [
                    "buildifier --mode=check .drone.star",
                ],
            },
            {
                "name": "show-diff",
                "image": OC_CI_BAZEL_BUILDIFIER,
                "commands": [
                    "buildifier --mode=fix .drone.star",
                    "git diff",
                ],
                "when": {
                    "status": [
                        "failure",
                    ],
                },
            },
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/pull/**",
            ],
        },
    }]

def genericCache(name, action, mounts, cache_key):
    rebuild = "false"
    restore = "false"
    if action == "rebuild":
        rebuild = "true"
        action = "rebuild"
    else:
        restore = "true"
        action = "restore"

    step = {
        "name": "%s_%s" % (action, name),
        "image": MELTWATER_DRONE_CACHE,
        "environment": {
            "AWS_ACCESS_KEY_ID": {
                "from_secret": "cache_s3_access_key",
            },
            "AWS_SECRET_ACCESS_KEY": {
                "from_secret": "cache_s3_secret_key",
            },
        },
        "settings": {
            "endpoint": {
                "from_secret": "cache_s3_endpoint",
            },
            "bucket": "cache",
            "region": "us-east-1",  # not used at all, but fails if not given!
            "path_style": "true",
            "cache_key": cache_key,
            "rebuild": rebuild,
            "restore": restore,
            "mount": mounts,
        },
    }
    return step

def genericCachePurge(ctx, name, cache_key):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "purge_%s" % (name),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "purge-cache",
                "image": MINIO_MC,
                "failure": "ignore",
                "environment": {
                    "MC_HOST_cache": {
                        "from_secret": "cache_s3_connection_url",
                    },
                },
                "commands": [
                    "mc rm --recursive --force cache/cache/%s/%s" % (ctx.repo.name, cache_key),
                ],
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
            "status": [
                "success",
                "failure",
            ],
        },
    }

def genericBuildArtifactCache(ctx, name, action, path):
    name = "%s_build_artifact_cache" % (name)
    cache_key = "%s/%s/%s" % (ctx.repo.slug, ctx.build.commit + "-${DRONE_BUILD_NUMBER}", name)
    if action == "rebuild" or action == "restore":
        return genericCache(name, action, [path], cache_key)
    if action == "purge":
        return genericCachePurge(ctx, name, cache_key)
    return []

def restoreBuildArtifactCache(ctx, name, path):
    return [genericBuildArtifactCache(ctx, name, "restore", path)]

def rebuildBuildArtifactCache(ctx, name, path):
    return [genericBuildArtifactCache(ctx, name, "rebuild", path)]

def purgeBuildArtifactCache(ctx, name):
    return genericBuildArtifactCache(ctx, name, "purge", [])

def pipelineSanityChecks(ctx, pipelines):
    """pipelineSanityChecks helps the CI developers to find errors before running it

    These sanity checks are only executed on when converting starlark to yaml.
    Error outputs are only visible when the conversion is done with the drone cli.

    Args:
      ctx: drone passes a context with information which the pipeline can be adapted to
      pipelines: pipelines to be checked, normally you should run this on the return value of main()

    Returns:
      none
    """

    # check if name length of pipeline and steps are exceeded.
    max_name_length = 50
    for pipeline in pipelines:
        pipeline_name = pipeline["name"]
        if len(pipeline_name) > max_name_length:
            print("Error: pipeline name %s is longer than 50 characters" % (pipeline_name))

        for step in pipeline["steps"]:
            step_name = step["name"]
            if len(step_name) > max_name_length:
                print("Error: step name %s in pipeline %s is longer than 50 characters" % (step_name, pipeline_name))

    # check for non existing depends_on
    possible_depends = []
    for pipeline in pipelines:
        possible_depends.append(pipeline["name"])

    for pipeline in pipelines:
        if "depends_on" in pipeline.keys():
            for depends in pipeline["depends_on"]:
                if not depends in possible_depends:
                    print("Error: depends_on %s for pipeline %s is not defined" % (depends, pipeline["name"]))

    # check for non declared volumes
    for pipeline in pipelines:
        pipeline_volumes = []
        if "volumes" in pipeline.keys():
            for volume in pipeline["volumes"]:
                pipeline_volumes.append(volume["name"])

        for step in pipeline["steps"]:
            if "volumes" in step.keys():
                for volume in step["volumes"]:
                    if not volume["name"] in pipeline_volumes:
                        print("Warning: volume %s for step %s is not defined in pipeline %s" % (volume["name"], step["name"], pipeline["name"]))

    # list used docker images
    print("")
    print("List of used docker images:")

    images = {}

    for pipeline in pipelines:
        for step in pipeline["steps"]:
            image = step["image"]
            if image in images.keys():
                images[image] = images[image] + 1
            else:
                images[image] = 1

    for image in images.keys():
        print(" %sx\t%s" % (images[image], image))

"""Parallel Deployment configs
"""

# configs
OCIS_URL = "https://ocis-server:9200"
OCIS_DOMAIN = "ocis-server:9200"
OC10_URL = "http://oc10:8080"
PARALLEL_DEPLOY_CONFIG_PATH = "/drone/src/tests/parallelDeployAcceptance/drone"

# step volumes
stepVolumeOC10Templates = \
    {
        "name": "oc10-templates",
        "path": "/etc/templates",
    }
stepVolumeOC10PreServer = \
    {
        "name": "preserver-config",
        "path": "/etc/pre_server.d",
    }
stepVolumeOC10Apps = \
    {
        "name": "core-apps",
        "path": "/var/www/owncloud/apps",
    }
stepVolumeOC10OCISData = \
    {
        "name": "data",
        "path": "/mnt/data",
    }
stepVolumeOCISConfig = \
    {
        "name": "proxy-config",
        "path": "/etc/ocis",
    }

# pipeline volumes
pipeOC10TemplatesVol = \
    {
        "name": "oc10-templates",
        "temp": {},
    }
pipeOC10PreServerVol = \
    {
        "name": "preserver-config",
        "temp": {},
    }
pipeOC10AppsVol = \
    {
        "name": "core-apps",
        "temp": {},
    }
pipeOC10OCISSharedVol = \
    {
        "name": "data",
        "temp": {},
    }
pipeOCISConfigVol = \
    {
        "name": "proxy-config",
        "temp": {},
    }

def parallelDeployAcceptancePipeline(ctx):
    pipelines = []

    default = {
        "filterTags": "~@skip",
    }

    for category, params in config["parallelApiTests"].items():
        if "skip" in params and params["skip"]:
            return pipelines

        early_fail = params["earlyFail"] if "earlyFail" in params else False

        if type(params["suites"]) == "list":
            suites = {}
            for suite in params["suites"]:
                suites[suite] = suite
        else:
            suites = params["suites"]

        for suite, suiteName in suites.items():
            params = {}
            for item in default:
                params[item] = params[item] if item in params else default[item]

            environment = {}
            environment["BEHAT_FILTER_TAGS"] = params["filterTags"]
            environment["BEHAT_SUITE"] = suite

            pipeline = {
                "kind": "pipeline",
                "type": "docker",
                "name": "parallel-%s" % (suiteName),
                "platform": {
                    "os": "linux",
                    "arch": "amd64",
                },
                "steps": skipIfUnchanged(ctx, "acceptance-tests") +
                         restoreBuildArtifactCache(ctx, "ocis-binary-amd64", "ocis/bin/ocis") +
                         cloneCoreRepos() +
                         copyConfigs() +
                         parallelDeploymentOC10Server() +
                         owncloudLog() +
                         fixSharedDataPermissions() +
                         ocisServer(
                             "ocis",
                             "default",
                             [stepVolumeOC10OCISData, stepVolumeOCISConfig],
                             ["fix-shared-data-permissions"],
                             True,
                         ) +
                         parallelAcceptance(environment) +
                         failEarly(ctx, early_fail),
                "services": oc10DbService() +
                            ldapService() +
                            redis(),
                "volumes": [
                    pipeOC10TemplatesVol,
                    pipeOC10PreServerVol,
                    pipeOC10AppsVol,
                    pipeOC10OCISSharedVol,
                    pipeOCISConfigVol,
                    pipelineVolumeOC10Tests,
                ],
                "depends_on": getPipelineNames([buildOcisBinaryForTesting(ctx)]),
                "trigger": {},
            }

            if (ctx.build.event == "cron"):
                pipeline["trigger"]["cron"] = params["cron"] if "cron" in params and params["cron"] != "" else "nightly"
            else:
                pipeline["trigger"]["ref"] = [
                    "refs/heads/master",
                    "refs/tags/v*",
                    "refs/pull/**",
                ]

            pipelines.append(pipeline)

    return pipelines

def parallelAcceptance(env):
    environment = {
        "TEST_SERVER_URL": OCIS_URL,
        "TEST_OC10_URL": OC10_URL,
        "TEST_PARALLEL_DEPLOYMENT": "true",
        "TEST_OCIS": "true",
        "TEST_WITH_LDAP": "true",
        "REVA_LDAP_PORT": 636,
        "REVA_LDAP_BASE_DN": "dc=owncloud,dc=com",
        "REVA_LDAP_HOSTNAME": "openldap",
        "REVA_LDAP_BIND_DN": "cn=admin,dc=owncloud,dc=com",
        "SKELETON_DIR": "/var/www/owncloud/apps/testing/data/apiSkeleton",
        "PATH_TO_CORE": "/srv/app/testrunner",
        "OCIS_REVA_DATA_ROOT": "/mnt/data/",
        "EXPECTED_FAILURES_FILE": "/drone/src/tests/parallelDeployAcceptance/expected-failures-API.md",
        "OCIS_SKELETON_STRATEGY": "copy",
        "SEND_SCENARIO_LINE_REFERENCES": "true",
        "UPLOAD_DELETE_WAIT_TIME": "1",
    }
    environment.update(env)

    return [{
        "name": "acceptance-tests",
        "image": OC_CI_PHP % DEFAULT_PHP_VERSION,
        "environment": environment,
        "commands": [
            "make test-paralleldeployment-api",
        ],
        "depends_on": ["clone-core-repos", "wait-for-oc10", "wait-for-ocis-server"],
        "volumes": [
            stepVolumeOC10Apps,
            stepVolumeOC10Tests,
            stepVolumeOC10OCISData,
        ],
    }]

def parallelDeploymentOC10Server():
    return [
        {
            "name": "oc10",
            "image": OC_SERVER,
            "detach": True,
            "environment": {
                # can be switched to "web"
                "OWNCLOUD_DEFAULT_APP": "files",
                "OWNCLOUD_WEB_REWRITE_LINKS": "false",
                # script / config variables
                "IDP_OIDC_ISSUER": "https://keycloak/auth/realms/owncloud",
                "IDP_OIDC_CLIENT_SECRET": "oc10-oidc-secret",
                "CLOUD_DOMAIN": OCIS_DOMAIN,
                # LDAP bind configuration
                "LDAP_HOST": "openldap",
                "LDAP_PORT": 389,
                "STORAGE_LDAP_BIND_DN": "cn=admin,dc=owncloud,dc=com",
                "STORAGE_LDAP_BIND_PASSWORD": "admin",
                # LDAP user configuration
                "LDAP_BASE_DN": "dc=owncloud,dc=com",
                "LDAP_USER_SCHEMA_DISPLAYNAME": "displayname",
                "LDAP_LOGINFILTER": "(&(objectclass=owncloud)(|(uid=%uid)(mail=%uid)))",
                "LDAP_GROUP_SCHEMA_DISPLAYNAME": "cn",
                "LDAP_USER_SCHEMA_NAME_ATTR": "uid",
                "LDAP_GROUPFILTER": "(&(objectclass=groupOfUniqueNames)(objectclass=owncloud))",
                "LDAP_USER_SCHEMA_UID": "ownclouduuid",
                "LDAP_USERATTRIBUTEFILTERS": "uid",  # ownCloudUUID;cn;uid;mail
                "LDAP_USER_SCHEMA_MAIL": "mail",
                "LDAP_USERFILTER": "(&(objectclass=owncloud))",
                "LDAP_GROUP_MEMBER_ASSOC_ATTR": "uniqueMember",
                # database
                "OWNCLOUD_DB_TYPE": "mysql",
                "OWNCLOUD_DB_NAME": "owncloud",
                "OWNCLOUD_DB_USERNAME": "owncloud",
                "OWNCLOUD_DB_PASSWORD": "owncloud",
                "OWNCLOUD_DB_HOST": "oc10-db",
                "OWNCLOUD_ADMIN_USERNAME": "admin",
                "OWNCLOUD_ADMIN_PASSWORD": "admin",
                "OWNCLOUD_MYSQL_UTF8MB4": "true",
                # redis
                "OWNCLOUD_REDIS_ENABLED": "true",
                "OWNCLOUD_REDIS_HOST": "redis",
                # ownCloud config
                "OWNCLOUD_TRUSTED_PROXIES": OCIS_DOMAIN,
                "OWNCLOUD_OVERWRITE_PROTOCOL": "https",
                "OWNCLOUD_OVERWRITE_HOST": OCIS_DOMAIN,
                "OWNCLOUD_APPS_ENABLE": "openidconnect,oauth2,user_ldap,graphapi",
                "OWNCLOUD_LOG_LEVEL": 2,
                "OWNCLOUD_LOG_FILE": "/mnt/data/owncloud.log",
            },
            "volumes": [
                stepVolumeOC10OCISData,
                stepVolumeOC10Apps,
                stepVolumeOC10Templates,
                stepVolumeOC10PreServer,
            ],
            "depends_on": ["copy-configs"],
        },
        {
            "name": "wait-for-oc10",
            "image": OC_CI_WAIT_FOR,
            "commands": [
                "wait-for -it oc10:8080 -t 300",
            ],
            "depends_on": ["oc10"],
        },
    ]

def ldapService():
    return [{
        "name": "openldap",
        "image": OSIXIA_OPEN_LDAP,
        "environment": {
            "LDAP_TLS_VERIFY_CLIENT": "never",
            "LDAP_DOMAIN": "owncloud.com",
            "LDAP_ORGANISATION": "owncloud",
            "LDAP_ADMIN_PASSWORD": "admin",
            "LDAP_RFC2307BIS_SCHEMA": "true",
            "LDAP_REMOVE_CONFIG_AFTER_SETUP": "false",
            "LDAP_SEED_INTERNAL_LDIF_PATH": "%s/ldap/ldif" % (PARALLEL_DEPLOY_CONFIG_PATH),
        },
        "command": [
            "--copy-service",
            "--loglevel",
            "debug",
        ],
    }]

def oc10DbService():
    return [
        {
            "name": "oc10-db",
            "image": MARIADB,
            "environment": {
                "MYSQL_ROOT_PASSWORD": "owncloud",
                "MYSQL_USER": "owncloud",
                "MYSQL_PASSWORD": "owncloud",
                "MYSQL_DATABASE": "owncloud",
            },
            "command": [
                "--max-allowed-packet=128M",
                "--innodb-log-file-size=64M",
                "--innodb-read-only-compressed=OFF",
            ],
        },
    ]

def copyConfigs():
    return [{
        "name": "copy-configs",
        "image": OC_SERVER,
        "commands": [
            # ocis proxy config
            "mkdir -p /etc/ocis",
            "cp %s/ocis/proxy.yaml /etc/ocis/proxy.yaml" % (PARALLEL_DEPLOY_CONFIG_PATH),
            # oc10 configs
            "mkdir -p /etc/templates",
            "mkdir -p /etc/pre_server.d",
            "cp %s/oc10/oidc.config.php /etc/templates/oidc.config.php" % (PARALLEL_DEPLOY_CONFIG_PATH),
            "cp %s/oc10/ldap-config.tmpl.json /etc/templates/ldap-config.tmpl.json" % (PARALLEL_DEPLOY_CONFIG_PATH),
            "cp %s/oc10/10-custom-config.sh /etc/pre_server.d/10-custom-config.sh" % (PARALLEL_DEPLOY_CONFIG_PATH),
        ],
        "volumes": [
            stepVolumeOCISConfig,
            stepVolumeOC10Templates,
            stepVolumeOC10PreServer,
        ],
    }]

def owncloudLog():
    return [{
        "name": "owncloud-log",
        "image": OC_UBUNTU,
        "detach": True,
        "commands": [
            "tail -f /mnt/data/owncloud.log",
        ],
        "volumes": [
            stepVolumeOC10OCISData,
        ],
        "depends_on": ["wait-for-oc10"],
    }]

def fixSharedDataPermissions():
    return [{
        "name": "fix-shared-data-permissions",
        "image": OC_CI_PHP % DEFAULT_PHP_VERSION,
        "commands": [
            "chown -R 33:33 /var/www/owncloud",  # www-data  user
            "chmod -R 777 /var/www/owncloud",
            "chown -R 33:33 /mnt/data",  # www-data  user
            "chmod -R 777 /mnt/data",
        ],
        "volumes": [
            stepVolumeOC10Apps,
            stepVolumeOC10OCISData,
        ],
        "depends_on": ["wait-for-oc10"],
    }]
