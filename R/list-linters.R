#' Get the list of linters in `flir`
#'
#' @inheritParams lint
#' @return A character vector
#' @export
#'
#' @examples
#' list_linters(".")
list_linters <- function(path = ".") {
  out <- c(
    # "absolute_path", # TODO: really broken, too many false positives, e.g #42
    "any_duplicated",
    "any_is_na",
    "class_equals",
    "condition_message",
    "double_assignment",
    "duplicate_argument",
    "empty_assignment",
    "equal_assignment",
    "equals_na",
    "expect_comparison",
    "expect_identical",
    "expect_length",
    "expect_named",
    "expect_not",
    "expect_null",
    "expect_s3_class",
    "expect_s4_class",
    "expect_true_false",
    "expect_type",
    "for_loop_index",
    "function_return",
    "implicit_assignment",
    "is_numeric",
    "length_levels",
    "length_test",
    "lengths",
    "library_call",
    "list_comparison",
    "literal_coercion",
    "matrix_apply",
    "missing_argument",
    "nested_ifelse",
    "numeric_leading_zero",
    "nzchar",
    "outer_negation",
    "package_hooks",
    "paste",
    "redundant_equals",
    "redundant_ifelse",
    "rep_len",
    "right_assignment",
    "sample_int",
    "seq",
    "sort",
    "stopifnot_all",
    "T_and_F_symbol",
    "todo_comment",
    "undesirable_function",
    "undesirable_operator",
    "unnecessary_nesting",
    # TODO: I think it should be removed eventually, ast-grep tools is just not
    # the right tool for this. For now, I just leave it opt-in.
    # "unreachable_code",
    "vector_logic",
    "which_grepl"
  )
  keep_or_exclude_testthat_rules(path, out)
}

update_linter_factory <- function(path = ".") {
  suppressWarnings(file.remove("R/linters_factory.R"))
  list_linters <- list_linters(path)
  for (i in list_linters) {
    if (grepl("assignment", i)) {
      cat(
        sprintf(
          "\n\n#' %s",
          i
        ),
        file = "R/linters_factory.R",
        append = TRUE
      )
    } else {
      cat(
        sprintf(
          "\n\n#' @inherit lintr::%s_linter title\n#' @description\n#' See <https://lintr.r-lib.org/reference/%s_linter>.",
          i,
          i
        ),
        file = "R/linters_factory.R",
        append = TRUE
      )
    }
    cat(
      sprintf(
        "\n\n#' @usage %s_linter\n#' @name %s_linter\n#' @export\n#' @return The name of the linter
NULL
makeActiveBinding('%s_linter', function() { function() '%s' }, env = environment())\n
",
        i,
        i,
        i,
        i
      ),
      file = "R/linters_factory.R",
      append = TRUE
    )
  }
  cat(
    paste0(
      "keep:\n",
      paste("  -", list_linters, collapse = "\n")
    ),
    file = "inst/config.yml"
  )
}
