
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jiebaRS

<div align="center">

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

[简体中文](README.md) \| [English](README_en.md)

</div>

**jiebaRS** 是 [jiebaR](https://github.com/qinwf/jiebaR) 的 Rust
后端替代实现， 用于中文分词、词性标注和关键词提取。它使用
[jieba-rs](https://github.com/messense/jieba-rs) 作为分词引擎，
带来了现代化的性能与可维护性。

多年前，[qinwf](https://github.com/qinwf) 基于 cppjieba 创建了
[jiebaR](https://github.com/qinwf/jiebaR)，长期以来一直是 R
语言中文分词的首选工具。然而，[qinwf](https://github.com/qinwf)
已停止维护 [jiebaR](https://github.com/qinwf/jiebaR)，并且
[jiebaR](https://github.com/qinwf/jiebaR) 已被
[CRAN](https://cran.r-project.org/web/packages/jiebaR/index.html) 移除，
无法直接安装。这给 R
语言的教学与研究带来了不便和困扰。因此，基于功能完善、性能出色、
持续维护的 Rust [jieba-rs](https://github.com/messense/jieba-rs) crate，
我开发了 **jiebaRS**，为 R 用户提供一个现代化、易用的中文分词工具，
并尽可能保持与原 [jiebaR](https://github.com/qinwf/jiebaR) API
的兼容性。

## 安装

### 从 CRAN 安装

你可以从 CRAN 安装 jiebaRS 的发布版本：

``` r
install.packages("jiebaRS")
```

### R-universe / R-multiverse

R-universe 和 R-multiverse 上提供了预编译的二进制包：

``` r
install.packages("jiebaRS", repos = "https://yousa-mirage.r-universe.dev")
```

``` r
install.packages("jiebaRS", repos = "https://community.r-multiverse.org")
```

### 从源码安装

使用 [pak](https://pak.r-lib.org/) 或
[remotes](https://remotes.r-lib.org/) 从源码安装：

``` r
pak::pak("Yousa-Mirage/jiebaRS")
# 或
remotes::install_github("Yousa-Mirage/jiebaRS")
```

> **注意：** 从源码构建需要 Rust 工具链来编译 Rust 后端。

## 用法

``` r
library(jiebaRS)
```

### 分词

创建一个 worker 并对文本进行分词：

``` r
cutter <- worker()
segment("南京市长江大桥", cutter)
#> [1] "南京市"   "长江大桥"
```

批量分词支持多个字符串，通过 `batch`
参数控制聚合方式。当输入多于一个字符串时， 会自动并行分词，速度远超
jiebaR。

``` r
texts <- c("南京市长江大桥。", "这是一个测试，小明很聪明。")

# list：每个输入字符串对应一个字符向量
segment_batch(texts, cutter, batch = "list")
#> [[1]]
#> [1] "南京市"   "长江大桥"
#> 
#> [[2]]
#> [1] "这是" "一个" "测试" "小明" "很"   "聪明"

# flatten：所有词元拼接为一个向量
segment_batch(texts, cutter, batch = "flatten")
#> [1] "南京市"   "长江大桥" "这是"     "一个"     "测试"     "小明"     "很"      
#> [8] "聪明"

# data.frame：doc_id + word 两列
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

如果你想对一段很长的文本进行并行分词，可以先将其拆分为 32~64 个片段，
再使用 `segment_batch()`。

### 词性标注

使用 `tagging()` 函数为分词结果标注词性（POS）标签：

``` r
tagger <- worker(type = "tag")

# 默认：命名向量（词为名称，标签为值）
tagging("这是一个测试，小明很聪明。", tagger)
#> 这是 一个 测试 小明   很 聪明 
#>  "v"  "m" "vn" "nr" "zg"  "a"

# data.frame：term + tag 两列
tagging("这是一个测试，小明很聪明。", tagger, format = "data.frame")
#>   term tag
#> 1 这是   v
#> 2 一个   m
#> 3 测试  vn
#> 4 小明  nr
#> 5   很  zg
#> 6 聪明   a

# legacy：jiebaR 风格（词为值，标签为名称）
tagging("这是一个测试，小明很聪明。", tagger, format = "legacy")
#>      v      m     vn     nr     zg      a 
#> "这是" "一个" "测试" "小明"   "很" "聪明"
```

### 关键词提取

使用 `keywords()` 函数通过 TF-IDF 提取关键词：

``` r
keys <- worker(type = "keywords", topn = 3)

text <- "今天纽约的天气真好啊，京华大酒店的张尧经理吃了一只北京烤鸭。后天纽约的天气不好，昨天纽约的天气也不好，北京烤鸭真好吃。"

# 命名数值向量（关键词 -> 权重）
keywords(text, keys)
#>  北京烤鸭      纽约      天气 
#> 1.2514383 1.0095837 0.9689916

# 含 term + weight 两列的数据框
keywords_df(text, keys)
#>       term    weight
#> 1 北京烤鸭 1.2514383
#> 2     纽约 1.0095837
#> 3     天气 0.9689916
```

你也可以使用 `textrank()` 函数基于 TextRank 算法提取关键词。该功能在
Python 的 [jieba](https://github.com/fxsjy/jieba) 库中可用，但 jiebaR
中没有提供该功能。

``` r
ranker <- worker(type = "textrank", topn = 3)

textrank(text, ranker)
#>        天气        纽约        不好 
#> 19307224922 19179746649 13769693283

textrank_df(text, ranker)
#>   term      weight
#> 1 天气 19307224922
#> 2 纽约 19179746649
#> 3 不好 13769693283
```

### 自定义词典

加载自定义**主词典**（`dict` — 替换内置词典）或**用户词典** （`user` —
追加到主词典）。两个文件都使用如下行格式：`word [freq] [tag]`。

``` r
# 用户词典：向默认词典添加新词
user_file <- withr::local_tempfile()
writeLines(c("量子机器狗 1000 n", "超导量子比特 1000"), user_file, useBytes = TRUE)

cutter2 <- worker(user = user_file)
segment("量子机器狗和超导量子比特", cutter2)
#> [1] "量子机器狗"   "和"           "超导量子比特"
```

使用 `new_user_word()`（别名：`add_word()`）动态添加词语：

``` r
cutter3 <- worker()
segment("量子机器狗和超导量子比特", cutter3)
#> [1] "量子" "机器" "狗"   "和"   "超导" "量子" "比特"

new_user_word(cutter3, "量子机器狗", "n")
#> NULL
add_word(cutter3, "超导量子比特", "n")  # 别名
#> NULL
segment("量子机器狗和超导量子比特", cutter3)
#> [1] "量子机器狗"   "和"           "超导量子比特"
```

### 停用词

通过 `stop_word` 参数以字符向量形式提供停用词，或通过 `stop_word_file`
参数 以文件路径形式提供。停用词会从分词和关键词提取结果中过滤掉。

``` r
cutter4 <- worker(stop_word = c("这是", "一个"))
segment("这是一个测试", cutter4)
#> [1] "测试"
```

### 自定义 IDF + `get_idf()`

从你自己的已分词语料库计算 IDF 词典，然后用于 TF-IDF 关键词提取：

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

### 词频与 N-gram

提供两个小巧实用的函数用于词频统计和 n-gram 计数：

``` r
tokens <- segment("南京市长江大桥南京市", worker())

# 词频
freq(tokens)
#>       char freq
#> 1   南京市    2
#> 2 长江大桥    1

# 按词频降序排列
freq(tokens, sort = TRUE)
#>       char freq
#> 1   南京市    2
#> 2 长江大桥    1

# N-gram 计数（默认：二元组）
count_ngrams(tokens, n = 2)
#>              term n count
#> 1 南京市 长江大桥 2     1
#> 2 长江大桥 南京市 2     1

# 多个 n 值，以命名向量返回
count_ngrams(tokens, n = 1:2, format = "vector")
#>          南京市        长江大桥 南京市 长江大桥 长江大桥 南京市 
#>               2               1               1               1
```

## 与 jiebaR 的比较

jiebaRS 与 jiebaR 都基于 jieba 的分词算法，但在 Rust 后端（jieba-rs）和
C++ 后端
（cppjieba）的实现上不可避免地存在细微差异。以下是使用《围城》和《红楼梦》全文作为测试语料的实测结果。

### 分词结果相似度

| 语料 | 字符数 | jiebaRS 词元数 | jiebaR 词元数 | jiebaRS 词条数 | jiebaR 词条数 | 词表 Jaccard 相似度 |
|----|---:|---:|---:|---:|---:|:--:|
| 《围城》 | 246,871 | 128,985 | 129,560 | 18,375 | 18,794 | 0.929 |
| 《红楼梦》 | 860,933 | 451,792 | 451,228 | 44,634 | 45,596 | 0.865 |

两份分词结果的词元总数接近（差异在 0.2%
以内），词条表重叠度较高。主要差异来自部分专有名词的切分粒度不同（如
jiebaRS 将主角名 “鸿渐” 合并为一个词，jiebaR 则切为 “鸿” +
“渐”），以及未登录词的 HMM 推断边界存在少量差异。

### 分词速度

| 语料       | 输入模式    | jiebaRS（秒） | jiebaR（秒） | 加速比 |
|------------|-------------|--------------:|-------------:|:------:|
| 《围城》   | 单长文本    |         0.039 |        0.065 | 1.66x  |
| 《围城》   | 10 万句并行 |         0.246 |        2.930 | 11.91x |
| 《红楼梦》 | 单长文本    |         0.129 |        0.246 | 1.91x  |
| 《红楼梦》 | 10 万句并行 |         0.639 |        4.601 | 7.20x  |

单文本分词时 jiebaRS 约快 1.7~1.9 倍；当输入为大量短句并并行切分时，
jiebaRS 可达 7~12 倍加速。

## 致谢

jiebaRS 构建于以下开源项目的基础之上：

- **[jieba-rs](https://github.com/messense/jieba-rs)**：messense
  及贡献者对 Jieba 引擎的 Rust 移植。
- **[jiebaR](https://github.com/qinwf/jiebaR)**：qinwf 创建的原始 R 包，
  jiebaRS 即为其替代实现。
- **[extendr](https://github.com/extendr/extendr)**：extendr 团队让 Rust
  与 R 的互操作变得切实可行。
- 更广泛的 **Rust** 与 **R** 社区。

没有这些项目，jiebaRS 就不会存在。

## 许可证

jiebaRS 基于 [MIT 许可证](LICENSE.md) 授权。
