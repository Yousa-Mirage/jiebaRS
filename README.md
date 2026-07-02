
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jiebaRS

<div data-align="center">

<!-- badges: start -->

[![GitHub
Stars](https://img.shields.io/github/stars/Yousa-Mirage/jiebaRS?style=social)](https://github.com/Yousa-Mirage/jiebaRS/stargazers)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docs dev
Version](https://img.shields.io/badge/docs-dev-blue.svg)](https://yousa-mirage.github.io/jiebaRS/)
[![Ask
DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Yousa-Mirage/jiebaRS)
<!-- badges: end -->

</div>

The goal of jiebaRS is to …

## Installation

You can install the development version of jiebaRS from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Yousa-Mirage/jiebaRS")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(jiebaRS)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
