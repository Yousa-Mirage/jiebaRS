mod keywords;
mod segment;
mod tag;
mod user_dict;
mod worker;

use extendr_api::prelude::*;
use worker::JiebaWorker;

/// Create an internal native jieba worker.
///
/// Internal bridge used by [worker()] to allocate a native `JiebaWorker`.
///
/// @param worker_type Character scalar naming the worker type. Currently
///   supports `"mix"`, `"mp"`, `"hmm"`, `"full"`, `"query"`, and
///   `"tag"`, and `"keywords"`.
/// @param use_hmm Logical scalar indicating whether HMM fallback should be
///   enabled for segmentation.
/// @param top_n Integer scalar giving the number of keywords retained by
///   keyword workers.
/// @param stop_words Character vector of normalized UTF-8 stop words passed to
///   the native worker.
///
/// @return A native `JiebaWorker` handle.
/// @keywords internal
#[extendr]
fn new_worker(
    worker_type: &str,
    use_hmm: bool,
    top_n: u32,
    stop_words: Vec<String>,
) -> Result<JiebaWorker> {
    JiebaWorker::new(worker_type, use_hmm, top_n, stop_words)
}

/// Segment text with an internal native worker.
///
/// Internal bridge used by `segment()` to segment a single UTF-8 string.
///
/// @param text Character scalar containing the input text.
/// @param worker A native `JiebaWorker` handle created by the internal worker
///   constructor.
///
/// @return A character vector of segmented tokens.
/// @keywords internal
#[extendr]
fn segment_worker(text: &str, worker: &JiebaWorker) -> Result<Strings> {
    let tokens = worker.segment_text(text)?;
    Ok(Strings::from_values(tokens))
}

/// Segment multiple strings with an internal native worker.
///
/// Internal bridge used by `segment()` to segment many UTF-8 strings.
///
/// @param texts Character vector containing the input strings.
/// @param worker A native `JiebaWorker` handle created by the internal worker
///   constructor.
///
/// @return A list of character vectors, one per input string.
/// @keywords internal
#[extendr]
fn segment_batch_worker(texts: Strings, worker: &JiebaWorker) -> Result<List> {
    let texts_vec: Vec<&str> = texts.iter().map(|s| s.as_str()).collect();
    let results = worker
        .segment_texts(&texts_vec)?
        .into_iter()
        .map(Strings::from_values);
    Ok(List::from_values(results))
}

/// Tag text with an internal native worker.
///
/// Internal bridge used by [tagging()] to tag a single UTF-8 string.
///
/// @param text Character scalar containing the input text.
/// @param worker A native `JiebaWorker` handle created by the internal worker
///   constructor.
///
/// @return A named list with `term` and `tag` vectors.
/// @keywords internal
#[extendr]
fn tagging_worker(text: &str, worker: &JiebaWorker) -> Result<List> {
    let records = worker.tag_text(text)?;
    Ok(list!(
        term = Strings::from_values(records.iter().map(|record| record.word)),
        tag = Strings::from_values(records.iter().map(|record| record.tag))
    ))
}

/// Tag multiple strings with an internal native worker.
///
/// Internal bridge used by `tagging()` to tag many UTF-8 strings.
///
/// @param texts Character vector containing the input strings.
/// @param worker A native `JiebaWorker` handle created by the internal worker
///   constructor.
///
/// @return A list where each element is a named list with `term` and `tag`
///   vectors.
/// @keywords internal
#[extendr]
fn tagging_batch_worker(texts: Strings, worker: &JiebaWorker) -> Result<List> {
    let texts_vec: Vec<&str> = texts.iter().map(|s| s.as_str()).collect();
    let results = worker.tag_texts(&texts_vec)?;
    let values = results.into_iter().map(|records| {
        list!(
            term = Strings::from_values(records.iter().map(|record| record.word)),
            tag = Strings::from_values(records.iter().map(|record| record.tag))
        )
    });
    Ok(List::from_values(values))
}

/// Extract keywords with an internal native worker.
///
/// Internal bridge used by [keywords()] to extract keywords from a single UTF-8
/// string.
///
/// @param text Character scalar containing the input text.
/// @param worker A native `JiebaWorker` handle created by the internal worker
///   constructor.
///
/// @return A named list with `keyword` and `weight` vectors.
/// @keywords internal
#[extendr]
fn keywords_worker(text: &str, worker: &JiebaWorker) -> Result<List> {
    let records = worker.extract_keywords(text)?;
    Ok(list!(
        keyword = Strings::from_values(records.iter().map(|record| &record.keyword)),
        weight = Doubles::from_values(records.iter().map(|record| record.weight))
    ))
}

/// Add user-defined words with an internal native worker.
///
/// Internal bridge used by [new_user_word()] to mutate an existing native
/// worker in place.
///
/// @param worker A mutable native `JiebaWorker` handle.
/// @param words Character vector of custom words.
/// @param tags Character vector of tags aligned with `words`.
///
/// @return `NULL`, invisibly, after the worker has been updated.
/// @keywords internal
#[extendr]
fn add_user_words(worker: &mut JiebaWorker, words: Vec<String>, tags: Vec<String>) -> Result<()> {
    worker.add_user_words(&words, &tags)
}

/// Convert a decimal simhash value to a 64-bit binary string.
///
/// Internal bridge used by [tobin()] for formatting simhash values.
///
/// @param x Character scalar containing an unsigned 64-bit integer in base 10.
///
/// @return A length-1 character vector containing the 64-bit binary string.
///   If `x` is not a valid unsigned 64-bit integer, `NA` is returned.
/// @keywords internal
#[extendr]
fn tobin_rs(x: &str) -> Option<String> {
    x.parse::<u64>().ok().map(|v| format!("{v:064b}"))
}

extendr_module! {
    mod jiebaRS;

    fn new_worker;
    fn segment_worker;
    fn segment_batch_worker;
    fn tagging_worker;
    fn tagging_batch_worker;
    fn keywords_worker;

    fn add_user_words;
    fn tobin_rs;
}
