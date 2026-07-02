mod keywords;
mod segment;
mod tag;
mod user_dict;
mod worker;

use extendr_api::prelude::*;
use extendr_api::Result;
use worker::JiebaWorker;

/// Create an internal native jieba worker.
///
/// Internal bridge used by [worker()] to allocate a native `JiebaWorker`.
///
/// @param worker_type Character scalar naming the worker type. Currently
///   supports `"mix"`, `"mp"`, `"hmm"`, `"full"`, `"query"`, `"tag"`,
///   `"keywords"`, and `"textrank"`.
/// @param use_hmm Logical scalar indicating whether HMM fallback should be
///   enabled for segmentation.
/// @param hmm_model Character scalar containing a custom HMM model path, or an
///   empty string to use the embedded model.
/// @param idf_path Character scalar containing a custom IDF dictionary path, or
///   an empty string to use the embedded dictionary.
/// @param dict_path Character scalar containing a custom main dictionary path,
///   or an empty string to use the embedded dictionary. When provided, the
///   custom file *replaces* the embedded main dictionary entirely.
/// @param user_path Character scalar containing a user dictionary path, or an
///   empty string to skip. User entries are *appended* to the main dictionary.
/// @param top_n Integer scalar giving the number of keywords retained by
///   keyword workers.
/// @param stop_words Character vector of normalized UTF-8 stop words passed to
///   the native worker.
///
/// @return A native `JiebaWorker` handle.
/// @keywords internal
#[extendr]
#[allow(clippy::too_many_arguments)]
fn new_worker(
    worker_type: &str,
    use_hmm: bool,
    hmm_model: &str,
    idf_path: &str,
    dict_path: &str,
    user_path: &str,
    top_n: u32,
    stop_words: Vec<String>,
) -> Result<JiebaWorker> {
    JiebaWorker::new(
        worker_type,
        use_hmm,
        hmm_model,
        idf_path,
        dict_path,
        user_path,
        top_n,
        stop_words,
    )
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
    let texts_vec: Vec<&str> = texts.iter().map(|s| s.as_ref()).collect();
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
    let texts_vec: Vec<&str> = texts.iter().map(|s| s.as_ref()).collect();
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
/// Internal bridge used by [keywords()] to extract TF-IDF keywords from a
/// single UTF-8 string.
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

/// Extract TextRank keywords with an internal native worker.
///
/// Internal bridge used by [textrank()] to extract TextRank keywords from a
/// single UTF-8 string.
///
/// @param text Character scalar containing the input text.
/// @param worker A native `JiebaWorker` handle created by the internal worker
///   constructor.
///
/// @return A named list with `keyword` and `weight` vectors.
/// @keywords internal
#[extendr]
fn textrank_worker(text: &str, worker: &JiebaWorker) -> Result<List> {
    let records = worker.extract_textrank(text)?;
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
/// @param freq Optional integer vector of frequencies aligned with `words`.
///
/// @return `NULL`, invisibly, after the worker has been updated.
/// @keywords internal
#[extendr]
fn add_user_words(
    worker: &mut JiebaWorker,
    words: Strings,
    tags: Strings,
    freq: Nullable<Integers>,
) -> Result<()> {
    worker.add_user_words(&words, &tags, &freq)
}

extendr_module! {
    mod jiebaRS;

    fn new_worker;
    fn segment_worker;
    fn segment_batch_worker;
    fn tagging_worker;
    fn tagging_batch_worker;
    fn keywords_worker;
    fn textrank_worker;

    fn add_user_words;
}
