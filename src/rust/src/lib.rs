mod keywords;
mod segment;
mod user_dict;
mod worker;

use extendr_api::prelude::*;
use worker::JiebaWorker;

/// Create an internal native jieba worker.
///
/// Internal bridge used by [worker()] to allocate a native `JiebaWorker`.
///
/// @param worker_type Character scalar naming the worker type. Currently
///   supports `"mix"` and `"keywords"`.
/// @param use_hmm Logical scalar indicating whether HMM fallback should be
///   enabled for segmentation.
/// @param top_n Integer scalar giving the number of keywords retained by
///   keyword workers.
///
/// @return A native `JiebaWorker` handle.
/// @keywords internal
#[extendr]
fn new_worker(worker_type: &str, use_hmm: bool, top_n: u32) -> Result<JiebaWorker> {
    JiebaWorker::new(worker_type, use_hmm, top_n)
}

/// Segment text with an internal native worker.
///
/// Internal bridge used by [segment()] to segment a single UTF-8 string.
///
/// @param text Character scalar containing the input text.
/// @param worker A native `JiebaWorker` handle created by the internal worker
///   constructor.
///
/// @return A character vector of segmented tokens.
/// @keywords internal
#[extendr]
fn segment_worker(text: &str, worker: &JiebaWorker) -> Result<Vec<String>> {
    worker.segment_text(text)
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
        keyword = Strings::from_values(records.iter().map(|record| record.keyword.as_str())),
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
    fn keywords_worker;

    fn add_user_words;
    fn tobin_rs;
}
