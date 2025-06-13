test_that("unreachable_code_linter works in simple function", {
  expect_lint(
    "foo <- function(bar) { \nreturn(bar)\n }",
    NULL,
    "unreachable_code"
  )
})

test_that("unreachable_code_linter works in sub expressions", {
  linter <- "unreachable_code"
  msg <- "Remove code and comments coming after return() or stop()"

  lines <- "
    foo <- function(bar) {
      if (bar) {
        return(bar)
        # Test comment
        while (bar) {
          return(bar)
          5 + 3
          repeat {
            return(bar)
            # Test comment
            1 + 1
          }
        }
      } else if (bla) {
        # test
        return(5)
        # Test 2
      } else {
        return(bar)
        # Test comment
        for(i in 1:3) {
          return(bar)
          5 + 4
        }
      }
      return(bar)
      5 + 1
    }
  "

  # More useful in this case
  expect_snapshot(lint_text(lines))

  lines <- "
    foo <- function(bar) {
      if (bar) {
        return(bar) # Test comment
      }
      while (bar) {
        return(bar) # 5 + 3
      }
      repeat {
        return(bar) # Test comment
      }

    }
  "
  # TODO: How can I skip content that is on the same line as return() / stop()
  # expect_lint(lines, NULL, linter)

  lines <- "
    foo <- function(bar) {
      if (bar) {
        return(bar); x <- 2
      } else {
        return(bar); x <- 3
      }
      while (bar) {
        return(bar); 5 + 3
      }
      repeat {
        return(bar); test()
      }
      for(i in 1:3) {
        return(bar); 5 + 4
      }
    }
  "

  expect_snapshot(lint_text(lines))
})

test_that("unreachable_code_linter works with next and break in sub expressions", {
  linter <- "unreachable_code"
  msg <- "Remove code and comments coming after `next` or `break`"

  lines <- "
    foo <- function(bar) {
      if (bar) {
        next
        # Test comment
        while (bar) {
          break
          5 + 3
          repeat {
            next
            # Test comment
          }
        }
      } else {
        next
        # test
        for(i in 1:3) {
          break
          5 + 4
        }
      }
    }
  "

  expect_snapshot(lint_text(lines))

  lines <- "
    foo <- function(bar) {
      if (bar) {
        break # Test comment
      } else {
        next # Test comment
      }
      while (bar) {
        next # 5 + 3
      }
      repeat {
        next # Test comment
      }
      for(i in 1:3) {
        break # 5 + 4
      }
    }
  "
  # TODO: see same above
  # expect_lint(lines, NULL, linter)

  lines <- "
    foo <- function(bar) {
      if (bar) {
        next; x <- 2
      } else {
        break; x <- 3
      }
      while (bar) {
        break; 5 + 3
      }
      repeat {
        next; test()
      }
      for(i in 1:3) {
        break; 5 + 4
      }
    }
  "

  expect_snapshot(lint_text(lines))
})

test_that("unreachable_code_linter ignores expressions that aren't functions", {
  expect_lint("x + 1", NULL, "unreachable_code")
})

test_that("unreachable_code_linter ignores anonymous/inline functions", {
  expect_lint(
    "lapply(rnorm(10), function(x) x + 1)",
    NULL,
    "unreachable_code"
  )
})

test_that("unreachable_code_linter passes on multi-line functions", {
  lines <- "
    oo <- function(x) {
      y <- x + 1
      return(y)
    }
  "
  expect_lint(lines, NULL, "unreachable_code")
})

# TODO
# test_that("unreachable_code_linter ignores comments on the same expression", {
#   lines <- "
#     foo <- function(x) {
#       return(
#         y^2
#       ) # y^3
#     }
#   "
#   expect_lint(lines, NULL, "unreachable_code")
# })

# TODO
# test_that("unreachable_code_linter ignores comments on the same line", {
#   lines <- "
#     foo <- function(x) {
#       return(y^2) # y^3
#     }
#   "
#   expect_lint(lines, NULL, "unreachable_code")
# })

test_that("unreachable_code_linter identifies simple unreachable code", {
  lines <- "
    foo <- function(bar) {
      return(bar)
      x + 3
    }
  "
  # testing the correct expression is linted (the first culprit line)
  expect_lint(
    lines,
    "Code and comments coming after a return() or stop() should be removed.",
    "unreachable_code"
  )
})

test_that("unreachable_code_linter finds unreachable comments", {
  lines <- "
    foo <- function(x) {
      y <- x + 1
      return(y^2)
      # y^3
    }
  "
  expect_lint(
    lines,
    "Code and comments coming after a return() or stop() should be removed.",
    "unreachable_code"
  )
})

test_that("unreachable_code_linter finds expressions in the same line", {
  msg <- "Code and comments coming after a return() or stop() should be removed."
  linter <- "unreachable_code"

  lines <- "
    foo <- function(x) {
      return(
        y^2
      ); 3 + 1
    }
  "
  expect_lint(lines, msg, linter)

  lines <- "
    foo <- function(x) {
      return(y^2); 3 + 1
    }
  "
  expect_lint(lines, msg, linter)

  lines <- "
    foo <- function(x) {
      return(y^2); 3 + 1 # Test
    }
  "
  expect_lint(lines, msg, linter)
})

test_that("unreachable_code_linter finds expressions and comments after comment in return line", {
  msg <- "Code and comments coming after a return() or stop() should be removed."
  linter <- "unreachable_code"

  lines <- "
    foo <- function(x) {
      return(y^2) #Test comment
      #Test comment 2
    }
  "
  expect_lint(lines, msg, linter)

  lines <- "
    foo <- function(x) {
      return(y^2) # Test
      3 + 1
    }
  "
  expect_lint(lines, msg, linter)
})

test_that("unreachable_code_linter finds a double return", {
  lines <- trim_some(
    "
    foo <- function(x) {
      return(y^2)
      return(y^3)
    }
  "
  )
  expect_lint(
    lines,
    "Code and comments coming after a return() or stop() should be removed.",
    "unreachable_code"
  )
})

test_that("unreachable_code_linter finds code after stop()", {
  lines <- trim_some(
    "
    foo <- function(x) {
      y <- x + 1
      stop(y^2)
      # y^3
    }
  "
  )
  expect_lint(
    lines,
    "Code and comments coming after a return() or stop() should be removed.",
    "unreachable_code"
  )
})

test_that("unreachable_code_linter ignores code after foo$stop(), which might be stopping a subprocess, for example", {
  linter <- "unreachable_code"

  expect_lint(
    trim_some(
      "
      foo <- function(x) {
        bar <- get_process()
        bar$stop()
        TRUE
      }
    "
    ),
    NULL,
    linter
  )
  expect_lint(
    trim_some(
      "
      foo <- function(x) {
        bar <- get_process()
        bar@stop()
        TRUE
      }
    "
    ),
    NULL,
    linter
  )
})

test_that("unreachable_code_linter identifies unreachable code in conditional loops", {
  linter <- "unreachable_code"
  msg <- "Remove code inside a conditional loop with a deterministically false condition."

  lines <- trim_some(
    "
    foo <- function(bar) {
      if (FALSE) {
        x <- 3
      }
      x + 3
    }
  "
  )

  expect_lint(lines, msg, linter)

  lines <- trim_some(
    "
    foo <- function(bar) {
      if (FALSE) {
        # Unlinted comment
        x <- 3
      }
      x + 3
    }
  "
  )

  expect_lint(lines, msg, linter)

  lines <- trim_some(
    "
    foo <- function(bar) {
      if (bla) {
        x <- 3
      } else if (FALSE) {
        # Unlinted comment
        y <- 3
      }
      x + 3
    }
  "
  )

  expect_lint(lines, msg, linter)

  lines <- trim_some(
    "
    foo <- function(bar) {
      while (FALSE) {
        x <- 3
      }
      x + 3
    }
  "
  )

  expect_lint(lines, msg, linter)

  lines <- trim_some(
    "
    foo <- function(bar) {
      while (FALSE) {
        # Unlinted comment
        x <- 3
      }
      x + 3
    }
  "
  )

  expect_lint(lines, msg, linter)

  lines <- "while (FALSE) x <- 3"

  expect_lint(lines, msg, linter)

  lines <- "if (FALSE) x <- 3 # Test comment"

  expect_lint(lines, msg, linter)
})

test_that("unreachable_code_linter identifies unreachable code in conditional loops", {
  linter <- "unreachable_code"
  msg <- "One branch has a a deterministically true condition"

  lines <- trim_some(
    "
    foo <- function(bar) {
      if (TRUE) {
        x <- 3
      } else {
        # Unlinted comment
        x + 3
      }
    }
  "
  )

  expect_lint(lines, msg, linter)

  lines <- trim_some(
    "
    foo <- function(bar) {
      if (TRUE) {
        x <- 3
      } else if (bar) {
        # Unlinted comment
        x + 3
      }
    }
  "
  )

  expect_lint(lines, msg, linter)

  expect_lint(
    "if (TRUE) x <- 3 else if (bar) x + 3",
    msg,
    linter
  )
})

test_that("unreachable_code_linter identifies unreachable code in mixed conditional loops", {
  linter <- "unreachable_code"
  false_msg <- "Remove code inside a conditional loop with a deterministically false condition."
  true_msg <- "One branch has a a deterministically true condition"

  lines <- trim_some(
    "
      function (bla) {
        if (FALSE) {
          code + 4
        }
        while (FALSE) {
          code == 3
        }
        if (TRUE) {
        } else {
          code + bla
        }
        stop('.')
        code <- 1
      }
    "
  )

  expect_lint(lines, false_msg, linter)
  expect_lint(lines, true_msg, linter)

  expect_lint(
    "if (FALSE) x <- 3 else if (TRUE) x + 3 else x + 4",
    true_msg,
    linter
  )
})

# TODO
# test_that("function shorthand is handled", {
#   skip_if_not_r_version("4.1.0")
#
#   expect_lint(
#     trim_some("
#       foo <- \\(bar) {
#         return(bar)
#         x + 3
#       }
#     "),
#     list(
#       line_number = 3L,
#       message = "Code and comments coming after a return() or stop() should be removed."
#     ),
#     "unreachable_code"
#   )
# })

test_that("Do not lint inline else after stop", {
  expect_lint("if (x > 3L) stop() else x + 3", NULL, "unreachable_code")
})

test_that("Do not lint inline else after stop in inline function", {
  linter <- "unreachable_code"

  expect_lint("function(x) if (x > 3L) stop() else x + 3", NULL, linter)
  expect_lint("function(x) if (x > 3L) { stop() } else {x + 3}", NULL, linter)
})

# test_that("Do not lint inline else after stop in inline lambda function", {
#   skip_if_not_r_version("4.1.0")
#
#   linter <- "unreachable_code"
#
#   expect_lint("\\(x) if (x > 3L) stop() else x + 3", NULL, linter)
#   expect_lint("\\(x){ if (x > 3L) stop() else x + 3 }", NULL, linter)
# })

test_that("unreachable_code is deactivated by default", {
  expect_lint(
    "foo <- function(bar) { \nreturn(bar)\n 1 + 1}",
    "Code and comments coming after",
    "unreachable_code"
  )
  expect_lint(
    "foo <- function(bar) { \nreturn(bar)\n 1 + 1}",
    NULL,
    NULL
  )

  create_local_package()
  setup_flir()
  cat("foo <- function(bar) { \nreturn(bar)\n 1 + 1}", file = "R/foo.R")
  lints <- lint_package()
  expect_equal(nrow(lints), 0)
})
