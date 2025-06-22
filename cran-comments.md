This is the first CRAN release (3rd try).

Thank you for the comments, I have updated the functions to use `path = NULL`
by default instead of `path = "."`.

I don't really understand the need for this since other CRAN packages use
`path = "."` (or a variant of this argument name that still refers to a path to
a directory) by default, such as `altdoc`, `devtools`, `pkgdown`, `roxygen2`.
