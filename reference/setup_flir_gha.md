# Create a Github Actions workflow for `flir`

Create a Github Actions workflow for `flir`

## Usage

``` r
setup_flir_gha(path, overwrite = FALSE)
```

## Arguments

- path:

  Path to package or project root. If `NULL` (default), uses `"."`.

- overwrite:

  Whether to overwrite `.github/workflows/flir.yaml` if it already
  exists.

## Value

Creates `.github/workflows/flir.yaml` but doesn't return any value.
