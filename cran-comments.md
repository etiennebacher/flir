This is the first CRAN release (3rd try).

Thank you for the comments, I have updated the functions that write to the user
file system so that the argument `path` has to be specified. Note that in tests
only (which don't write to the working directory), a missing `path` means that
`"."` is used by default.

While I understand the willingness to minimize automatic changes to the user's
file system, I must say there's quite a discrepancy in how this policy is
applied. Many CRAN packages (including some of my own) directly write to the user
file system without asking for user confirmation such as `altdoc`, `devtools`,
`pkgdown`, `rextendr`, `Rcpp`, `roxygen2`, etc. Therefore, from the package
developer's point of view, it's hard to understand why this usage is accepted
for some packages but not others.
