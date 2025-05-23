test_that("absolute_path is not reported", {
  create_local_package()
  cat('paste0("/n")', file = "R/foo.R")
  expect_equal(nrow(lint()), 0)

  setup_flir()
  expect_equal(nrow(lint()), 0)
})

# TODO
# test_that("is_root_path", {
#   f <- lintr:::is_root_path
#
#   x <- character()
#   y <- logical()
#   expect_identical(f(x), y)
#
#   x <- c("",    "foo", "http://rseek.org/", "./",  " /",  "/foo", "'/'")
#   y <- c(FALSE, FALSE, FALSE,               FALSE, FALSE, FALSE,  FALSE)
#   expect_identical(f(x), y)
#
#   x <- c("/",  "//")
#   y <- c(TRUE, FALSE)
#   expect_identical(f(x), y)
#
#   x <- c("~",  "~/", "~//", "~bob2", "~foo_bar/")
#   y <- c(TRUE, TRUE, TRUE,  TRUE,    TRUE)
#   expect_identical(f(x), y)
#
#   x <- c("c:", "C:\\", "D:/", "C:\\\\", "D://")
#   y <- c(TRUE, TRUE,   TRUE,  FALSE,    FALSE)
#   expect_identical(f(x), y)
#
#   x <- c("\\\\", "\\\\localhost", "\\\\localhost\\")
#   y <- c(TRUE,   TRUE,            TRUE)
#   expect_identical(f(x), y)
# })
#
#
# test_that("is_absolute_path", {
#   f <- lintr:::is_absolute_path
#
#   x <- character()
#   y <- logical()
#   expect_identical(f(x), y)
#
#   x <- c("/",  "//",  "/foo", "/foo/")
#   y <- c(TRUE, FALSE, TRUE,   TRUE)
#   expect_identical(f(x), y)
#
#   x <- c("~",  "~/foo", "~/foo/", "~'")
#   y <- c(TRUE, TRUE,    TRUE,     FALSE)
#   expect_identical(f(x), y)
#
#   x <- c("c:", "C:\\foo\\", "C:/foo/")
#   y <- c(TRUE, TRUE,        TRUE)
#   expect_identical(f(x), y)
#
#   x <- c("\\\\", "\\\\localhost", "\\\\localhost\\c$", "\\\\localhost\\c$\\foo")
#   y <- c(TRUE,   TRUE,            TRUE,                TRUE)
#   expect_identical(f(x), y)
# })
#
#
# test_that("is_relative_path", {
#   f <- lintr:::is_relative_path
#
#   x <- character()
#   y <- logical()
#   expect_identical(f(x), y)
#
#   x <- c("/",   "c:\\", "~/",  "foo", "http://rseek.org/", "'./'")
#   y <- c(FALSE, FALSE,  FALSE, FALSE, FALSE,               FALSE)
#   expect_identical(f(x), y)
#
#   x <- c("/foo", "foo/", "foo/bar", "foo//bar", "./foo", "../foo")
#   y <- c(FALSE,  TRUE,   TRUE,      TRUE,       TRUE,    TRUE)
#   expect_identical(f(x), y)
#
#   x <- c("\\\\", "\\foo", "foo\\", "foo\\bar", ".\\foo", "..\\foo", ".",  "..", "../")
#   y <- c(FALSE,  FALSE,   TRUE,    TRUE,       TRUE,     TRUE,      TRUE, TRUE, TRUE)
#   expect_identical(f(x), y)
# })
#
#
# test_that("is_path", {
#   f <- lintr:::is_path
#
#   x <- character()
#   y <- logical()
#   expect_identical(f(x), y)
#
#   x <- c("",    "foo", "http://rseek.org/", "foo\nbar", "'foo/bar'", "'/'")
#   y <- c(FALSE, FALSE, FALSE,               FALSE,      FALSE,       FALSE)
#   expect_identical(f(x), y)
#
#   x <- c("c:", "..", "foo/bar", "foo\\bar", "~",  "\\\\localhost")
#   y <- c(TRUE, TRUE, TRUE,      TRUE,       TRUE, TRUE)
#   expect_identical(f(x), y)
# })
#
#
# test_that("is_valid_path", {
#   f <- lintr:::is_valid_path
#
#   x <- character()
#   y <- logical()
#   expect_identical(f(x), y)
#
#   x <- c("C:/asdf", "C:/asd*f", "a\\s:df", "a\\\nsdf")
#   y <- c(TRUE,      FALSE,      FALSE,     FALSE)
#   expect_identical(f(x), y)
#
#   x <- c("C:/asdf", "C:/asd*f", "a\\s:df", "a\\\nsdf")
#   y <- c(TRUE,      FALSE,      FALSE,     FALSE)
#   expect_identical(f(x, lax = TRUE), y)
#
#   x <- c("/asdf", "/asd*f", "/as:df", "/a\nsdf")
#   y <- c(TRUE,    TRUE,     TRUE,     TRUE)
#   expect_identical(f(x), y)
#
#   x <- c("/asdf", "/asd*f", "/as:df", "/a\nsdf")
#   y <- c(TRUE,    FALSE,    FALSE,    FALSE)
#   expect_identical(f(x, lax = TRUE), y)
# })
#
#
# test_that("is_long_path", {
#   f <- lintr:::is_long_path
#
#   x <- character()
#   y <- logical()
#   expect_identical(f(x), y)
#
#   x <- c("foo/", "/foo", "n/a", "Z:\\foo", "foo/bar", "~/foo", "../foo")
#   y <- c(FALSE,  FALSE,  FALSE, TRUE,      TRUE,      TRUE,    TRUE)
#   expect_identical(f(x), y)
# })
#
# test_that("returns the correct linting", {
#   lint_msg <- "Do not use absolute paths."
#
#   # strict mode
#   linter <- absolute_path_linter()
#   non_absolute_path_strings <- c(
#     "..",
#     "./blah",
#     encodeString("blah\\file.txt")
#   )
#   for (path in non_absolute_path_strings) {
#     expect_lint(single_quote(path), NULL, linter)
#     expect_lint(double_quote(path), NULL, linter)
#   }
#
#   expect_lint("\"'/'\"", NULL, linter) # nested quotes
#
#   absolute_path_strings <- c(
#     "/",
#     "/blah/file.txt",
#     encodeString("d:\\"),
#     "E:/blah/file.txt",
#     encodeString("\\\\"),
#     encodeString("\\\\server\\path"),
#     "~",
#     "~james.hester/blah/file.txt",
#     encodeString("/a\nsdf"),
#     "/as:df"
#   )
#   for (path in absolute_path_strings) {
#     expect_lint(single_quote(path), lint_msg, linter)
#     expect_lint(double_quote(path), lint_msg, linter)
#   }

# lax mode: no check for strings that are likely not paths (too short or with special characters)
# linter <- absolute_path_linter(lax = TRUE)
# unlikely_path_strings <- c(
#   "/",
#   encodeString("/a\nsdf/bar"),
#   "/as:df/bar"
# )
# for (path in unlikely_path_strings) {
#   expect_lint(single_quote(path), NULL, linter)
#   expect_lint(double_quote(path), NULL, linter)
# }
# })

# test_that("raw strings are handled correctly", {
#   skip_if_not_r_version("4.0.0")
#   expect_lint('R"(./blah)"', NULL, absolute_path_linter())
#   expect_lint(
#     "R'--[/blah/file.txt]--'",
#     "Do not use absolute paths.",
#     absolute_path_linter()
#   )
# })
#
# test_that("lints vectorize", {
#   lint_msg <- "Do not use absolute paths."
#
#   expect_equal(
#     nrow(lint_text("{
#       '/'
#       '/blah/file.txt'
#       'abcdefg'
#       '~'
#     }", linters = absolute_path_linter())),
#     3
#   )
# })
