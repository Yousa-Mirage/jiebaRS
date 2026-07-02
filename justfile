alias fmt := format
alias doc := document

default:
    @just --list

format:
    r-air format .
    cargo fmt --manifest-path src/rust/Cargo.toml

check:
    jarl check .
    Rscript -e "devtools::spell_check()"
    cargo clippy --manifest-path src/rust/Cargo.toml -- -D warnings

clean:
    cargo clean --manifest-path src/rust/Cargo.toml

document:
    Rscript -e "devtools::document()"
    Rscript -e "devtools::build_readme()"

test:
    TESTTHAT_CPUS=8 Rscript -e "devtools::test(reporter = 'summary')"
    cargo test --quiet --manifest-path src/rust/Cargo.toml

pkg-check:
    Rscript -e "devtools::check(remote = TRUE, manual = TRUE)"

site:
    Rscript -e "devtools::build_readme()"
    Rscript -e "pkgdown::build_site()"
    @xdg-open docs/index.html || true
