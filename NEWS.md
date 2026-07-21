# jiebaRS 0.2.0

- Custom dictionary and model files are now read through a common UTF-8 layer
  that handles a leading BOM and reports invalid formats.
- Reject duplicate entries in custom IDF dictionaries now.
- User dictionary entries with an omitted frequency now infer one automatically,
  zero frequencies are rejected.
- Legacy `word tag` entries from `jiebaR` are supported.
- `worker()` now accepts `min_keyword_length` to control the minimum Unicode
  length of terms returned by TF-IDF and TextRank keyword extraction.
- `worker()` now accepts one or more user dictionary paths through `user`;
  dictionaries are appended in the supplied order
  ([qinwf/jiebaR#69](https://github.com/qinwf/jiebaR/issues/69)).

# jiebaRS 0.1.0

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

Add necessary tests, documents, a benchmark, and the website.
