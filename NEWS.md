# jiebaRS 0.3.1

- 更新至 jieba-rs 0.11
- 优化了 README.md

# jiebaRS 0.3.0

- 通过选择匹配的 Rust 目标，修复了在原生 Windows ARM64 平台上的源代码安装问题。
- 添加了 `import_cidian()` 函数，用于将 SCEL、QCEL、QPYD、BDICT 和 BCD 输入法字典中的单词导入到现有
  worker 中。
- 添加了 `read_cidian()` 函数，用于将支持的输入法词典读取到包含条目和编码组件的数据框中。
- 提供了 `stopwords_cn`、`stopwords_en` 和 `stopwords_full` 三份停用词表。
  停用词过滤默认情况下仍处于禁用状态。
- 移除了 `get_tuple()` 函数；请使用 `count_ngrams()` 函数进行 n-gram 计数。
- 函数现在拒绝未命名的可选参数；请按名称提供可选参数。
- 不再生成内部原生桥接函数的文档。

---------------------------------------------------------------------------------------------------------

- Fixed source installation on native Windows ARM64 by selecting the matching Rust target.
- Added `import_cidian()` to import words from SCEL, QCEL, QPYD, BDICT, and BCD input-method dictionaries
  into an existing worker.
- Added `read_cidian()` to read supported input-method dictionaries into a data frame of entries and
  coding components.
- Bundled `stopwords_cn`, `stopwords_en`, and `stopwords_full` stopwords datasets are now available for
  explicit use; stopword filtering remains disabled by default.
- Removed `get_tuple()`; use `count_ngrams()` for n-gram counting.
- Exported functions now reject unnamed optional arguments; supply optional arguments by name.
- Documentation for internal native bridge functions is no longer generated for users.

# jiebaRS 0.2.0

- 自定义词典和模型文件通过一个通用的 UTF-8 层读取，该层可以处理前导 BOM 并报告无效格式。
- 拒绝自定义 IDF 词典中的重复条目。
- 用户词典中省略词频的条目现在会自动推断为 1，词频为 0 的条目会被拒绝。
- 支持来自 `jiebaR` 的旧版 `word tag` 条目。
- `worker()` 现在接受 `min_keyword_length` 参数，用于控制 TF-IDF 和 TextRank 关键词提取返回的词项的最小
  Unicode 长度。
- `worker()` 现在接受通过 `user` 参数传入的一个或多个用户词典路径；
  词典会按照提供的顺序附加到路径中（[qinwf/jiebaR#69](https://github.com/qinwf/jiebaR/issues/69)）。

---------------------------------------------------------------------------------------------------------

- Custom dictionary and model files are now read through a common UTF-8 layer that handles a leading BOM
  and reports invalid formats.
- Reject duplicate entries in custom IDF dictionaries now.
- User dictionary entries with an omitted frequency now infer one automatically, zero frequencies are
  rejected.
- Legacy `word tag` entries from `jiebaR` are supported.
- `worker()` now accepts `min_keyword_length` to control the minimum Unicode length of terms returned by
  TF-IDF and TextRank keyword extraction.
- `worker()` now accepts one or more user dictionary paths through `user`; dictionaries are appended in
  the supplied order ([qinwf/jiebaR#69](https://github.com/qinwf/jiebaR/issues/69)).

# jiebaRS 0.1.0

初始 CRAN 提交。

已实现以下 API：

- Worker：
  - `worker`
- 分词：
  - `segment`
  - `segment_batch`
- 词性：
  - `tagging`
  - `tagging_batch`
- 关键词提取：
  - `keywords`
  - `keywords_df`
  - `textrank`
  - `textrank_df`
- 词频和 N 元语法：
  - `freq`
  - `count_ngrams`
  - `get_tuple`
- 工具函数：
  - `filter_segment`
  - `new_user_word`
  - `add_word`
  - `get_idf`

添加了必要的测试、文档、基准测试和网站。

---------------------------------------------------------------------------------------------------------

Initial CRAN submission.

Implemented these APIs:

- Workers:
  - `worker`
- Segmentation:
  - `segment`
  - `segment_batch`
- Speech Tagging:
  - `tagging`
  - `tagging_batch`
- Keyword Extraction:
  - `keywords`
  - `keywords_df`
  - `textrank`
  - `textrank_df`
- Word Frequency and N-grams:
  - `freq`
  - `count_ngrams`
  - `get_tuple`
- Utilities:
  - `filter_segment`
  - `new_user_word`
  - `add_word`
  - `get_idf`

Added necessary tests, documents, a benchmark, and the website.
