
# Developing the awos Test Driver {#chap-developing-the-test-driver}

The awos test framework is a project of its own.

It consists of roughly the following components:

 - `awos/lib/test-driver`: The Python framework that sets up the test and runs the [`testScript`](#test-opt-testScript)
 - `awos/lib/testing`: The Nix code responsible for the wiring, written using the (awos) Module System.

These components are exposed publicly through:

 - `awos/lib/default.nix`: The public interface that exposes the `awos/lib/testing` entrypoint.
 - `flake.nix`: Exposes the `lib.awos`, including the public test interface.

Beyond the test driver itself, its integration into awos and Nixpkgs is important.

 - `pkgs/top-level/all-packages.nix`: Defines the `awosTests` attribute, used
   by the package `tests` attributes and OfBorg.
 - `awos/release.nix`: Defines the `tests` attribute built by Hydra, independently, but analogous to `awosTests`
 - `awos/release-combined.nix`: Defines which tests are channel blockers.

Finally, we have legacy entrypoints that users should move away from, but are cared for on a best effort basis.
These include `pkgs.awosTest`, `testing-python.nix` and `make-test-python.nix`.

## Testing changes to the test framework {#sec-test-the-test-framework}

We currently have limited unit tests for the framework itself. You may run these with `nix-build -A awosTests.awos-test-driver`.

When making significant changes to the test framework, we run the tests on Hydra, to avoid disrupting the larger awos project.

For this, we use the `python-test-refactoring` branch in the `awos/nixpkgs` repository, and its [corresponding Hydra jobset](https://hydra.awos.org/jobset/awos/python-test-refactoring).
This branch is used as a pointer, and not as a feature branch.

1. Rebase the PR onto a recent, good evaluation of `awos-unstable`
2. Create a baseline evaluation by force-pushing this revision of `awos-unstable` to `python-test-refactoring`.
3. Note the evaluation number (we'll call it `<previous>`)
4. Push the PR to `python-test-refactoring` and evaluate the PR on Hydra
5. Create a comparison URL by navigating to the latest build of the PR and adding to the URL `?compare=<previous>`. This is not necessary for the evaluation that comes right after the baseline.

Review the removed tests and newly failed tests using the constructed URL; otherwise you will accidentally compare iterations of the PR instead of changes to the PR base.

As we currently have some flaky tests, newly failing tests are expected, but should be reviewed to make sure that
 - The number of failures did not increase significantly.
 - All failures that do occur can reasonably be assumed to fail for a different reason than the changes.
