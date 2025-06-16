# flir-ignore-start and end error if mismatch

    Code
      lint_text("# flir-ignore-start\nany(duplicated(x))\nany(duplicated(y))")
    Condition
      Error in `find_lines_to_ignore()`:
      ! Mismatch: the number of `start` patterns (1) and of `end` patterns (0) must be equal.

