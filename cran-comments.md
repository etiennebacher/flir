This is the first CRAN release (2nd try).

Thank you for the comments, I have updated the URL in NEWS and fixed the typo 
in DESCRIPTION.

> Please omit any default path in writing functions.

This was explained in the CRAN comments included in the first submission, which
I put below (points 1 and 2 were already there, point 3 was added in this 
submission).

This package may write in the user directory for several reasons:

1. The objective of some functions (`fix()` and its variants) is to
   automatically modify R files that the user passes as inputs. It is clearly
   described in the documentation that this will modify the files, and it asks
   for the user confirmation when several files will be modified at once.

2. Some functions are helpers to make it easier to use the package:
  - `setup_flir()` creates a folder `flir`
  - `setup_flir_gha()` creates a YAML file for Github Actions
  - `add_new_rule()` creates one or several files in the `flir` directory
  - `export_new_rule()` creates one or several files in the `inst` directory

  Those are similar to functions in other packages, e.g. `usethis`.
  
3. Some tests modify files, but those are located in a temporary directory so
   running the test suite doesn't modify anything in the package files.
