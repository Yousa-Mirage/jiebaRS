
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jiebaRS

<div align="center">

<!-- badges: start -->

[![GitHub
Stars](https://img.shields.io/github/stars/Yousa-Mirage/jiebaRS?style=social)](https://github.com/Yousa-Mirage/jiebaRS)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docs dev
Version](https://img.shields.io/badge/docs-dev-blue.svg)](https://yousa-mirage.github.io/jiebaRS/)
[![Ask
DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Yousa-Mirage/jiebaRS)
<!-- badges: end -->

[简体中文](https://yousa-mirage.github.io/jiebaRS/index.html) \|
[English](https://yousa-mirage.github.io/jiebaRS/README_en.html)

</div>

**jiebaRS** is a Rust-backed replacement of
[jiebaR](https://github.com/qinwf/jiebaR) for Chinese text segmentation,
part-of-speech tagging, and keyword extraction. It uses
[jieba-rs](https://github.com/messense/jieba-rs) as the segmentation
engine, bringing modern performance and maintainability.

[qinwf](https://github.com/qinwf) created
[jiebaR](https://github.com/qinwf/jiebaR) based on cppjieba many years
ago, which has long been the go-to tool for Chinese text segmentation in
R. However, [qinwf](https://github.com/qinwf) has stopped maintaining
[jiebaR](https://github.com/qinwf/jiebaR), and
[jiebaR](https://github.com/qinwf/jiebaR) has been removed from
[CRAN](https://CRAN.R-project.org/package=jiebaR), making it unavailable
for direct installation. This has caused inconvenience and confusion in
R teaching and research. Therefore, based on the well-featured,
performant, and actively maintained Rust
[jieba-rs](https://github.com/messense/jieba-rs) crate, I developed
**jiebaRS** to provide R users with a modern and easy-to-use Chinese
text segmentation tool, maintaining much compatibility with the original
[jiebaR](https://github.com/qinwf/jiebaR) API.

## Installation

### From CRAN

You can install the released version of jiebaRS from CRAN:

``` r
install.packages("jiebaRS")
```

### From R-universe / R-multiverse

A prebuilt binary is hosted on R-universe and R-multiverse:

``` r
install.packages("jiebaRS", repos = "https://yousa-mirage.r-universe.dev")
```

``` r
install.packages("jiebaRS", repos = "https://community.r-multiverse.org")
```

### From Source Code

Install from source with [pak](https://pak.r-lib.org/) or
[remotes](https://remotes.r-lib.org/):

``` r
pak::pak("Yousa-Mirage/jiebaRS")
# or
remotes::install_github("Yousa-Mirage/jiebaRS")
```

> **Note:** Building from source requires Rust tool chain to compile the
> Rust backend.

## Usage

``` r
library(jiebaRS)
```

### Segmentation

Create a worker and segment a text:

``` r
cutter <- worker()
segment("南京市长江大桥", cutter)
#> [1] "南京市"   "长江大桥"
```

Batch segmentation supports multiple strings with `batch` aggregation.
It will automatically segment parallelly if more than one strings are
provided, making it much faster than jiebaR.

``` r
texts <- c("南京市长江大桥。", "这是一个测试，小明很聪明。")

# list: one character vector per input string
segment_batch(texts, cutter, batch = "list")
#> [[1]]
#> [1] "南京市"   "长江大桥"
#> 
#> [[2]]
#> [1] "这是" "一个" "测试" "小明" "很"   "聪明"

# flatten: all tokens concatenated into one vector
segment_batch(texts, cutter, batch = "flatten")
#> [1] "南京市"   "长江大桥" "这是"     "一个"     "测试"     "小明"     "很"      
#> [8] "聪明"

# data.frame: doc_id + word columns
segment_batch(texts, cutter, batch = "data.frame")
#>   doc_id     word
#> 1      1   南京市
#> 2      1 长江大桥
#> 3      2     这是
#> 4      2     一个
#> 5      2     测试
#> 6      2     小明
#> 7      2       很
#> 8      2     聪明
```

If you want to segment a very long text parallelly, you can split it
into 32~128 chunks and then use `segment_batch()`.

### Speech Tagging

You can tag segmented words with part-of-speech (POS) tags using the
`tagging()` function:

``` r
tagger <- worker(type = "tag")

# Default: named vector (terms as names, tags as values)
tagging("这是一个测试，小明很聪明。", tagger)
#> 这是 一个 测试 小明   很 聪明 
#>  "v"  "m" "vn" "nr" "zg"  "a"

# data.frame: term + tag columns
tagging("这是一个测试，小明很聪明。", tagger, format = "data.frame")
#>   term tag
#> 1 这是   v
#> 2 一个   m
#> 3 测试  vn
#> 4 小明  nr
#> 5   很  zg
#> 6 聪明   a

# legacy: jiebaR-style (terms as values, tags as names)
tagging("这是一个测试，小明很聪明。", tagger, format = "legacy")
#>      v      m     vn     nr     zg      a 
#> "这是" "一个" "测试" "小明"   "很" "聪明"
```

### Keyword Extraction

You can extract keywords using TF-IDF with the `keywords()` function:

``` r
keys <- worker(type = "keywords", topn = 3)

text <- "今天纽约的天气真好啊，京华大酒店的张尧经理吃了一只北京烤鸭。后天纽约的天气不好，昨天纽约的天气也不好，北京烤鸭真好吃。"

# Named numeric vector (keyword -> weight)
keywords(text, keys)
#>  北京烤鸭      纽约      天气 
#> 1.2514383 1.0095837 0.9689916

# Data frame with term + weight columns
keywords_df(text, keys)
#>       term    weight
#> 1 北京烤鸭 1.2514383
#> 2     纽约 1.0095837
#> 3     天气 0.9689916
```

You can also use the TextRank algorithm with the `textrank()` function.
This is available in [Python’s jieba](https://github.com/fxsjy/jieba)
but not in jiebaR.

``` r
ranker <- worker(type = "textrank", topn = 3)

textrank(text, ranker)
#>        天气        纽约        不好 
#> 19308397026 19181002755 13770391787

textrank_df(text, ranker)
#>   term      weight
#> 1 天气 19308397026
#> 2 纽约 19181002755
#> 3 不好 13770391787
```

### Custom Dictionaries

Load a custom **main dictionary** (`dict` — replaces the embedded
dictionary) or a **user dictionary** (`user` — appends to the main
dictionary). Both files use the line format: `word [freq] [tag]`.

``` r
# User dictionary: add new words to the default dictionary
user_file <- withr::local_tempfile()
writeLines(c("量子机器狗 1000 n", "超导量子比特 1000"), user_file, useBytes = TRUE)

cutter2 <- worker(user = user_file)
segment("量子机器狗和超导量子比特", cutter2)
#> [1] "量子机器狗"   "和"           "超导量子比特"
```

Add words dynamically with `new_user_word()` (alias: `add_word()`):

``` r
cutter3 <- worker()
segment("量子机器狗和超导量子比特", cutter3)
#> [1] "量子" "机器" "狗"   "和"   "超导" "量子" "比特"

new_user_word(cutter3, "量子机器狗", "n")
add_word(cutter3, "超导量子比特", "n")  # alias
segment("量子机器狗和超导量子比特", cutter3)
#> [1] "量子机器狗"   "和"           "超导量子比特"
```

### Stop Words

Supply stop words as a character vector via the `stop_word` parameter or
a file path via the `stop_word_file` parameter. Stop words are filtered
from segmentation and keyword extraction results.

``` r
cutter4 <- worker(stop_word = c("这是", "一个"))
segment("这是一个测试", cutter4)
#> [1] "测试"
```

### Custom IDF + `get_idf()`

Compute an IDF dictionary from your own corpus of segmented documents,
then use it for TF-IDF keyword extraction:

``` r
docs <- list(
  c("北京", "烤鸭", "纽约"),
  c("北京", "天气"),
  c("纽约", "天气")
)

idf_file <- withr::local_tempfile()
get_idf(docs, path = idf_file)

keys_custom <- worker(type = "keywords", topn = 3, idf = idf_file)
keywords(text, keys_custom)
#>       天气       纽约       不好 
#> 0.06081977 0.06081977 0.04054651
```

### Word Frequency & N-grams

Two small but useful functions are provided for word frequency and
n-gram counts:

``` r
tokens <- segment("南京市长江大桥南京市", worker())

# Word frequency
freq(tokens)
#>       char freq
#> 1   南京市    2
#> 2 长江大桥    1

# Sorted by descending frequency
freq(tokens, sort = TRUE)
#>       char freq
#> 1   南京市    2
#> 2 长江大桥    1

# N-gram counts (default: bigrams)
count_ngrams(tokens, n = 2)
#>              term n count
#> 1 南京市 长江大桥 2     1
#> 2 长江大桥 南京市 2     1

# Multiple n sizes, as a named vector
count_ngrams(tokens, n = 1:2, format = "vector")
#>          南京市        长江大桥 南京市 长江大桥 长江大桥 南京市 
#>               2               1               1               1
```

## Compare with jiebaR

jiebaRS and jiebaR are both based on the jieba segmentation algorithm,
but there are inevitably subtle differences between the Rust backend
(jieba-rs) and the C++ backend (cppjieba). The results below are
measured on the full text of *Fortress Besieged* (围城) and *Dream of
the Red Chamber* (红楼梦).

### Segmentation Similarity

| Corpus | Characters | jiebaRS tokens | jiebaR tokens | jiebaRS vocab | jiebaR vocab | Vocab Jaccard |
|----|---:|---:|---:|---:|---:|:--:|
| Fortress Besieged | 246,871 | 128,985 | 129,560 | 18,375 | 18,794 | 0.929 |
| Dream of the Red Chamber | 860,933 | 451,792 | 451,228 | 44,634 | 45,596 | 0.865 |

The total token counts are close (within 0.2%), and the vocabularies
overlap heavily. The main differences come from the different
segmentation granularity of some proper nouns (e.g. jiebaRS merges the
protagonist name “鸿渐” into a single word, while jiebaR splits it into
“鸿” + “渐”), as well as minor differences in HMM-based OOV
(out-of-vocabulary) boundary inference.

### Segmentation Speed

| Corpus | Input mode | jiebaRS (s) | jiebaR (s) | Speedup |
|----|----|---:|---:|:--:|
| Fortress Besieged | whole text | 0.039 | 0.065 | 1.66x |
| Fortress Besieged | 100k sentences (parallel) | 0.246 | 2.930 | 11.91x |
| Dream of the Red Chamber | whole text | 0.129 | 0.246 | 1.91x |
| Dream of the Red Chamber | 100k sentences (parallel) | 0.639 | 4.601 | 7.20x |

For a single long text, jiebaRS is about 1.7~1.9x faster; when the input
is many short sentences that are segmented in parallel, jiebaRS can
reach 7~12x speedup.

## Acknowledgments

jiebaRS builds on the work of open-source projects:

- **[jieba-rs](https://github.com/messense/jieba-rs)**: messense and
  contributors for the Rust port of the Jieba engine.
- **[jiebaR](https://github.com/qinwf/jiebaR)**: qinwf for the original
  R package that jiebaRS replaces.
- **[extendr](https://github.com/extendr/extendr)**: the extendr team
  for making Rust–R interoperability practical.
- The broader **Rust** and **R** communities.

Without these projects, jiebaRS would not exist.

## License

MIT license
