# awos Tests {#sec-awos-tests}

When you add some feature to awos, you should write a test for it.
awos tests are kept in the directory `awos/tests`, and are executed
(using Nix) by a testing framework that automatically starts one or more
virtual machines containing the awos system(s) required for the test.

```{=include=} sections
writing-awos-tests.section.md
running-awos-tests.section.md
running-awos-tests-interactively.section.md
linking-awos-tests-to-packages.section.md
testing-hardware-features.section.md
```
