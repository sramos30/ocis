# Welcome to the Infinite Scale Beta!
https://owncloud.com/news/infinite-scale-beta-available

How to get started with Infinite Scale
To get started with Infinite Scale, you basically have two options:

Set up Infinite Scale locally or on a host machine of your choice (Docker being an option as well!). All supported deployment options are covered in the Infinite Scale documentation. In the most simple case, it only requires you to issue a couple of commands on the terminal to be up and running.
Get a free 14-day ready-go instance managed by ownCloud for testing purposes. More information on this can be found here.
We are looking forward to any feedback you might want to share. Please see the guidelines on how to provide feedback below.
Stay tuned, spread the great news and happy testing!

## Run ownCloud Infinite Scale

Please see [Getting Started](https://owncloud.dev/ocis/getting-started/)

## Development

Please see [Development - Getting Started](https://owncloud.dev/ocis/development/getting-started/)

## Security

If you find a security issue please contact [security@owncloud.com](mailto:security@owncloud.com) first

## Contributing

Please refer to our [Contribution Guidelines](CONTRIBUTING.md).

## License

Apache-2.0

## Copyright

```console
Copyright (c) 2020-2021 ownCloud GmbH <https://owncloud.com>
```

## [Infinite Scale - A new era for ownCloud - ownCloud Conference 2021](https://youtu.be/C4a4q9IGyFQ)

## [Infinite Scale Documentation](https://doc.owncloud.com/ocis/next/)

### [Installation - Container Setup](https://doc.owncloud.com/ocis/next/deployment/container/container-setup.html)

- [ownCloud Infinite Scale-docker-hub](https://hub.docker.com/r/owncloud/ocis)
- [ownCloud / oCIS - ownCloud Infinite Scale / Getting Started](https://owncloud.dev/ocis/getting-started/)
- [ownCloud / oCIS - ownCloud Infinite Scale / Development / Getting Started](https://owncloud.dev/ocis/development/getting-started/)

## [oCIS - ownCloud Infinite Scale - dev](https://owncloud.dev/ocis/)

## [ownCloud Infinite Scale-github](https://github.com/owncloud/ocis)

    git clone --recursive https://github.com/owncloud/ocis.git
    git clone --recursive git@github.com:sramos30/ocis.git

## Branches
    master *
    acc
    accounts-cs3-users-repo
    add-access-log
    add-flaex
    breaker
    bump-commitid-20210315
    bump-web-commit-id-2e673fe
    bumpCoreCommitId-2020-03-30
    checkAddTagsInOcis
    cs3-microfied-v1
    debug-intermittent-webui-failure
    debugOcis#1492
    delete-user-home
    demo
    dependabot/go_modules/ocis/github.com/rs/zerolog-1.21.0
    dependabot/npm_and_yarn/accounts/babel/core-7.13.13
    dependabot/npm_and_yarn/accounts/eslint-7.23.0
    dependabot/npm_and_yarn/idp/css-loader-5.2.0
    dependabot/npm_and_yarn/idp/eslint-plugin-flowtype-5.4.0
    dependabot/npm_and_yarn/onlyoffice/rollup/plugin-replace-2.4.2
    dependabot/npm_and_yarn/onlyoffice/url-search-params-polyfill-8.1.1
    dependabot/npm_and_yarn/settings/rollup/plugin-replace-2.4.2
    dependabot/npm_and_yarn/settings/url-search-params-polyfill-8.1.1
    deployment-fixes2
    doc-adr-spaces-api
    docs
    docs-extensions-framework
    document-proxy
    enable-settings-ui-tests
    enforce_quota
    eos-drone-ci-setup
    eos-tests
    erwinpalma-patch-1
    erwinpalma-patch-2
    feature/cernbox-ocis-canary
    fix_getting_started
    fix_proto
    konnectd-demo-theme
    login-cli
    make_reva_ocis_service_user_uuid_configurable
    micro-auth-registry
    no-additional-init
    ocis-reva-registry
    qa-reva-1368
    read_docs
    release--notes-correction
    release-1.0.0-rc3-pinning
    release-1.4.0
    release-lessons-docs
    release-process
    run-creation-with-upload-tusTests
    run-options-request-tusTests
    run-phoenix-UI-tests-with-both-storages
    run-tests-move-received-file
    run-tests-update-share
    run-tusTests-checksum
    run-tusTests-checksum-overwrite
    runTestsForTusUpload
    run_files_depth_header
    runtime-experiment
    runtime-experiment-suture
    set_data_path_defaults_to_pwd
    settings-dev-docs-v2
    test-api-move-file-error
    testForShareRecipient
    testmoveTUSsteps
    try
    update-flaex-template
    update-pman
    upgrade_deps
    uploadToShare-tusTests
    z-delete-user-home

> ./switch_branch.sh master

### Build the oCIS binary

You only need to run following command if you have changed protobuf definitions or the frontend part in one of the extensions. Run the command in the root directory of the repository. Otherwise you can skip this step and proceed to build the oCIS binary. This will usually modify multiple embed.go files because we embed the frontend build output in these embed.go files and a timestamp will be updated and also minor differences are expected between different Node.js versions.

    make generate

The next step is to build the actual oCIS binary. Therefore you need to navigate to the subdirectory ocis and start the build process.

    cd ocis
    make build

After the build process finished, you can find the binary within the bin/ folder (in ocis/bin relative to the oCIS repository root folder).

Try to run it: *./bin/ocis h*

### Build a local oCIS docker image

If you are developing and want to run your local changes in a docker or docker-compose setup, you have to build an image locally.

Therefore run following commands in the root of the oCIS repository:

    docker build -t owncloud/ocis:dev .

To connect to a container with bash shell...

    docker exec -it owncloud/ocis:dev /bin/bash

Then you can test as usual via

    docker run --rm -ti owncloud/ocis:dev

