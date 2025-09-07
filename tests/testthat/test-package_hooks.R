test_that("package_hooks_linter skips allowed usages of packageStartupMessage() & library.dynam()", {
  linter <- package_hooks_linter()

  # allowed in .onAttach, not .onLoad
  expect_no_lint(
    ".onAttach <- function(lib, pkg) packageStartupMessage('hi')",
    linter
  )
  # allowed in .onLoad, not .onAttach
  expect_no_lint(".onLoad <- function(lib, pkg) library.dynam()", linter)
})

test_that("package_hooks_linter blocks simple disallowed usages of packageStartupMessage() & library.dynam()", {
  linter <- package_hooks_linter()

  # inline version
  expect_lint(
    ".onLoad <- function(lib, pkg) packageStartupMessage('hi')",
    "Put packageStartupMessage() calls in .onAttach(), not .onLoad().",
    linter
  )

  # multiline version
  expect_lint(
    trim_some(
      "
      .onAttach <- function(libname, pkgname) {
        library.dynam()
      }
    "
    ),
    "Put library.dynam() calls in .onLoad(), not .onAttach().",
    linter
  )

  # found at deeper nesting too
  expect_lint(
    trim_some(
      "
      .onLoad <- function(libname, pkgname) {
        foo(bar(baz(packageStartupMessage('hi'))))
      }
    "
    ),
    "Put packageStartupMessage() calls in .onAttach()",
    linter
  )
})

test_that("package_hooks_linter blocks simple disallowed usages of other blocked messaging functions", {
  linter <- package_hooks_linter()

  expect_no_lint(".onLoad <- function(lib, pkg) catr('hi')", linter)

  for (fn in c(
    "cat",
    "installed.packages",
    "message",
    "packageStartupMessage",
    "print",
    "writeLines"
  )) {
    # inline version
    expect_lint(
      paste0(".onLoad <- function(lib, pkg) ", fn, "('hi')"),
      paste0("Don't use ", fn, "() in .onLoad()"),
      linter
    )
    # multiline version
    expect_lint(
      paste0(".onLoad <- function(lib, pkg) {\n", fn, "('hi')\n}"),
      paste0("Don't use ", fn, "() in .onLoad()"),
      linter
    )
    # found at deeper nesting too
    expect_lint(
      paste0(
        ".onLoad <- function(lib, pkg) {\nfoo(bar(baz(",
        fn,
        "('hi'))))\n}"
      ),
      paste0("Don't use ", fn, "() in .onLoad()"),
      linter
    )
  }

  # Almost same set of functions but not exactly
  for (fn in c("cat", "installed.packages", "message", "print", "writeLines")) {
    # inline version
    expect_lint(
      paste0(".onAttach <- function(lib, pkg) ", fn, "('hi')"),
      paste0("Don't use ", fn, "() in .onAttach()"),
      linter
    )
    # multiline version
    expect_lint(
      paste0(".onAttach <- function(lib, pkg) {\n", fn, "('hi')\n}"),
      paste0("Don't use ", fn, "() in .onAttach()"),
      linter
    )
    # found at deeper nesting too
    expect_lint(
      paste0(
        ".onAttach <- function(lib, pkg) {\nfoo(bar(baz(",
        fn,
        "('hi'))))\n}"
      ),
      paste0("Don't use ", fn, "() in .onAttach()"),
      linter
    )
  }
})

# test_that("package_hooks_linter skips valid .onLoad() and .onAttach() arguments", {
#   linter <- package_hooks_linter()
#
#   expect_lint(".onAttach <- function(lib, pkg) { }", NULL, linter)
#   expect_lint(".onLoad <- function(lib, pkg) { }", NULL, linter)
#
#   # args only need to start with those characters
#   expect_lint(".onAttach <- function(libname, pkgpath) { }", NULL, linter)
#   expect_lint(".onLoad <- function(libXXXX, pkgYYYY) { }", NULL, linter)
# })
#
# test_that("package_hooks_linter blocks invalid .onLoad() / .onAttach() arguments", {
#   linter <- package_hooks_linter()
#   onload_msg <- ".onLoad() should take two arguments"
#
#   expect_lint(
#     ".onAttach <- function(xxx, pkg) { }",
#     ".onAttach() should take two arguments",
#     linter
#   )
#   expect_lint(".onLoad <- function(lib, yyy) { }", onload_msg, linter)
#   # only one lint if both are wrong
#   expect_lint(".onLoad <- function(xxx, yyy) { }", onload_msg, linter)
#
#   # exactly two arguments required.
#   # NB: QC.R allows ... arguments to be passed, but disallow this flexibility in the linter.
#   expect_lint(".onLoad <- function() { }", onload_msg, linter)
#   expect_lint(".onLoad <- function(lib) { }", onload_msg, linter)
#   expect_lint(".onLoad <- function(lib, pkg, third) { }", onload_msg, linter)
#   expect_lint(".onLoad <- function(lib, ...) { }", onload_msg, linter)
# })

test_that("package_hooks_linter skips valid namespace loading", {
  linter <- package_hooks_linter()

  expect_no_lint(
    ".onAttach <- function(lib, pkg) { requireNamespace('foo') }",
    linter
  )
  expect_no_lint(
    ".onLoad <- function(lib, pkg) {  requireNamespace('foo') }",
    linter
  )
})

test_that("package_hooks_linter blocks attaching namespaces", {
  linter <- package_hooks_linter()

  expect_lint(
    ".onAttach <- function(lib, pkg) { require(foo) }",
    "Don't alter the search() path in .onAttach() by calling require().",
    linter
  )
  expect_lint(
    ".onLoad <- function(lib, pkg) { library(foo) }",
    "Don't alter the search() path in .onLoad() by calling library().",
    linter
  )
  expect_lint(
    ".onLoad <- function(lib, pkg) { installed.packages() }",
    "Don't slow down package load by running installed.packages() in .onLoad().",
    linter
  )

  # find at further nesting too
  expect_lint(
    ".onAttach <- function(lib, pkg) { a(b(c(require(foo)))) }",
    "Don't alter the search() path in .onAttach() by calling require().",
    linter
  )
  expect_lint(
    ".onLoad <- function(lib, pkg) { d(e(f(library(foo)))) }",
    "Don't alter the search() path in .onLoad() by calling library().",
    linter
  )
  expect_lint(
    ".onLoad <- function(lib, pkg) { g(h(i(installed.packages()))) }",
    "Don't slow down package load by running installed.packages() in .onLoad().",
    linter
  )

  # TODO: also find when used as names
  # expect_lint(
  #   ".onAttach <- function(lib, pkg) { sapply(c('a', 'b', 'c'), require, character.only = TRUE) }",
  #   "Don't alter the search() path in .onAttach() by calling require().",
  #   linter
  # )
  # expect_lint(
  #   ".onAttach <- function(lib, pkg) { lapply(c('a', 'b', 'c'), library, character.only = TRUE) }",
  #   "Don't alter the search() path in .onAttach() by calling library()",
  #   linter
  # )
})

test_that("package_hooks_linter skips valid .onDetach() and .Last.lib()", {
  linter <- package_hooks_linter()

  expect_no_lint(".onDetach <- function(lib) { }", linter)
  expect_no_lint(".onDetach <- function(libname) { }", linter)

  expect_no_lint(".Last.lib <- function(lib) { }", linter)
  expect_no_lint(".Last.lib <- function(libname) { }", linter)
})

test_that("package_hooks_linter catches usage of library.dynam.unload()", {
  linter <- package_hooks_linter()

  expect_lint(
    ".onDetach <- function(lib) { library.dynam.unload() }",
    "Use library.dynam.unload() calls in .onUnload(), not .onDetach().",
    linter
  )
  expect_lint(
    ".Last.lib <- function(lib) { library.dynam.unload() }",
    "Use library.dynam.unload() calls in .onUnload(), not .Last.lib().",
    linter
  )
  # expected usage is in .onUnload
  expect_no_lint(
    ".onUnload <- function(lib) { library.dynam.unload() }",
    linter
  )
})

# test_that("package_hooks_linter detects bad argument names in .onDetach()/.Last.lib()", {
#   linter <- package_hooks_linter()
#   lint_msg_part <- " should take one argument starting with 'lib'"
#
#   expect_lint(
#     ".onDetach <- function(xxx) { }",
#     rex::rex(".onDetach()", lint_msg_part),
#     linter
#   )
#   expect_lint(
#     ".Last.lib <- function(yyy) { }",
#     rex::rex(".Last.lib()", lint_msg_part),
#     linter
#   )
#
#   # exactly one argument required.
#   # NB: QC.R allows ... arguments to be passed, but disallow this flexibility in the linter.
#   expect_lint(
#     ".onDetach <- function() { }",
#     rex::rex(".onDetach()", lint_msg_part),
#     linter
#   )
#   expect_lint(
#     ".Last.lib <- function(lib, pkg) { }",
#     rex::rex(".Last.lib()", lint_msg_part),
#     linter
#   )
#   expect_lint(
#     ".onDetach <- function(...) { }",
#     rex::rex(".onDetach()", lint_msg_part),
#     linter
#   )
# })

# test_that("function shorthand is handled", {
#   skip_if_not_r_version("4.1.0")
#   linter <- package_hooks_linter()
#
#   expect_lint(
#     ".onLoad <- \\(lib, pkg) packageStartupMessage('hi')",
#     rex::rex("Put packageStartupMessage() calls in .onAttach()"),
#     linter
#   )
#   expect_lint(
#     ".onAttach <- \\(xxx, pkg) { }",
#     rex::rex(".onAttach() should take two arguments"),
#     linter
#   )
#   expect_lint(
#     ".onAttach <- \\(lib, pkg) { require(foo) }",
#     rex::rex("Don't alter the search() path in .onAttach() by calling require()."),
#     linter
#   )
#   expect_lint(
#     ".onDetach <- \\(lib) { library.dynam.unload() }",
#     rex::rex("Use library.dynam.unload() calls in .onUnload(), not .onDetach()."),
#     linter
#   )
#   expect_lint(
#     ".onDetach <- \\(xxx) { }",
#     rex::rex(".onDetach() should take one argument starting with 'lib'."),
#     linter
#   )
# })
