# Repository Guidelines

## Project Structure & Module Organization

- `R/` contains the public R API and internal helpers. Roxygen comments generate
  files in `man/` and exports in `NAMESPACE`.
- `src/` contains the R native entrypoint and build configuration. The Rust
  implementation is under `src/rust/src/`; its Cargo manifest and lockfile are
  in `src/rust/`.
- `tests/testthat/` contains edition-3 tests, snapshots, and optional real
  dictionary fixtures under `tests/testthat/fixtures/`.
- `data-raw/` stores source stopword files and generation scripts. Compiled
  package data is stored in `data/`.
- `README.Rmd` and `README_en.Rmd` are the README sources. `README.md` and
  `README_en.md` are generated outputs.

## Build, Test, and Development Commands

- `just document` builds Rust-generated wrappers, regenerates R documentation,
  and rebuilds both README files.
- `just test` runs the R testthat suite and Rust tests.
- `just format` runs `r-air` for R files and `cargo fmt` for Rust files.
- `just check` runs `jarl`, spelling checks, and Rust Clippy with warnings as
  errors.
- `just pkg-check` runs the package check; `just site` rebuilds READMEs and the
  pkgdown site.

Run focused R tests with, for example,
`Rscript -e "devtools::test(filter = 'cidian')"`.

## Coding Style & Naming Conventions

Use two-space indentation in R, the base `|>` pipe, and `snake_case` names.
Use standard Rust formatting with `cargo fmt`. Keep public R functions
documented with Roxygen and keep internal generated wrappers out of the user
reference where appropriate.

## Testing Guidelines

Name R tests `tests/testthat/test-<feature>.R`; place snapshots in
`tests/testthat/_snaps/`. Add focused tests for every user-facing behavior and
run both R and Rust tests before submitting changes. Tests may run in parallel;
avoid shared writable temporary files and use testthat temporary paths.

## Commit & Pull Request Guidelines

Use short conventional-style subjects such as `fix(build): support Windows
ARM64`, `docs: ...`, or `test: ...`. Work on a feature branch rather than
`main`. A pull request should explain the behavior change, list validation
commands and platform-specific checks, link related issues, and include
regenerated documentation when source comments or README sources changed.
