# Environments

The documentation in this section covers behaviours as they are defined for deployment environments. Note that in a `development` environment all permissions checks are bypassed, with clear logging describing all permissions that would be expected in a deployment environment.

Since a developer is running an application locally and they are able to modify the application's code, applying permissions in this environment would not add any level of security. Instead, developers receive a clear indication of what permissions they must define in a deployment environment while not being hampered in their work by the authorization model.

To ensure that an application's permissions requirements are taken into account during development, permissions **are** required in a `test` environment. This allows developers to ensure that their application is capable of defining the permissions needed to access it and to verify access control correctness with fixture data.

To assist developers when writing tests, permissions failures are logged to `stderr` the `test` environment, as well as to the application's default log file. i.e. permissions failures will appear in-line with output from the application's test suite and are less likely to go unnoticed.
