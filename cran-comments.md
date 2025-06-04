This is the first CRAN release.

This package may write in the user directory for several reasons:

1. The objective of some functions (`fix()` and its variants) is to
   automatically modify R files that the user passes as inputs. It is clearly
   described in the documentation that this will modify the files, and it asks
   for the user confirmation when several files will be modified.

2. Some functions are helpers to make it easier to use the package:
  - `setup_flir()` creates a folder `flir`
  - `setup_flir_gha()` creates a YAML file for Github Actions
  - `add_new_rule()` creates a file in the `flir` directory

  Those are similar to functions in other packages, e.g. `usethis`.
