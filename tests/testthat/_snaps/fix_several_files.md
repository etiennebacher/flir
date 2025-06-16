# Ask permission to use fix() on several files if Git is not used

    Code
      fix_dir("R")
    Condition
      Error in `fix()`:
      ! It seems that you are not using Git, but `fix()` will be applied on several R files. This will make it difficult to see the changes in code. Therefore, this operation is not allowed by default in a non-interactive setting. Use `force = TRUE` to bypass this behavior.

