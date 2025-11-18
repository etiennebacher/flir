# Automatic fixes

The main feature of `flir` is that it can provide automatic fixes for
some linters. This is very useful to avoid the tedious job of fixing
many files by hand but you may be worried about it applying wrong fixes.
Moreover, since those fixes can be applied to several files at once,
going back in time before those fixes were applied can be very
difficult. `flir` provides two mechanisms to be more confident about
automated fixes.

## Use Git

By default, if `flir` would automatically fix several files and the
project doesn’t use Git for version control, a menu will appear
recommending you to use Git. At this stage, you can still decide whether
you want to apply the fixes or stop here without changing anything.

Git makes it much easier to see changed files and it is therefore very
recommended to use it in combination with `flir`. Similarly, if some
files are unstaged (meaning that they have changes not covered by Git
yet), another menu will ask you to confirm that you want to apply fixes.
The reason is that for those unstaged files, it may be difficult to
distinguish the new changes introduced by automated fixes from previous,
unsaved changes.

## Interactively review all fixes

Whether you use Git or not, you can also opt in for interactive review
of changes using the `interactive` parameter in most of the `fix_*()`
functions. Setting `interactive = TRUE` will open a Shiny application
enabling you to see all the changes that *would be* introduced by
`flir`. Those changes are not applied yet: you can decide whether you
want to apply them or to skip them. If you have several files to review,
accepting or skipping the changes for one file will automatically go to
the next file.

The video below shows that I have two files, `foo1.R` and `foo2.R`, both
of which would be modified by automated fixes. Using
`interactive = TRUE` allows me to decide whether I actually want fixes
to be applied or not:

![A gif showing fix() applied on two files and opening a Shiny app to
review changes. Changes for the first file are accepted but not those
for the second file. Only the first file is modified.](demo.gif)

A gif showing [`fix()`](https://flir.etiennebacher.com/reference/fix.md)
applied on two files and opening a Shiny app to review changes. Changes
for the first file are accepted but not those for the second file. Only
the first file is modified.
