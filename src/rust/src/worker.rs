use std::fs::File;
use std::io::BufReader;

use ahash::AHashSet;

use extendr_api::prelude::*;
use extendr_api::{Error, Result};
use jieba_rs::{HmmModel, Jieba, KeywordExtractConfig, TextRank, TfIdf};

pub const WORKER_ABI_VERSION: i32 = 1;

/// Construction parameters for [`JiebaWorker`].
pub struct WorkerConfig<'a> {
    pub worker_type: &'a str,
    pub use_hmm: bool,
    pub hmm_model: &'a str,
    pub idf_path: &'a str,
    pub dict_path: &'a str,
    pub user_paths: Vec<String>,
    pub top_n: u32,
    pub stop_words: Vec<String>,
}

#[derive(Clone, Copy)]
pub enum WorkerFamily {
    Segment(SegmentMode),
    Tag,
    Keywords,
    TextRank,
}

#[derive(Clone, Copy)]
pub enum SegmentMode {
    Mix,
    Mp,
    Hmm,
    Full,
    Query,
}

impl WorkerFamily {
    fn from_type(worker_type: &str) -> Result<Self> {
        match worker_type {
            "mix" => Ok(Self::Segment(SegmentMode::Mix)),
            "mp" => Ok(Self::Segment(SegmentMode::Mp)),
            "hmm" => Ok(Self::Segment(SegmentMode::Hmm)),
            "full" => Ok(Self::Segment(SegmentMode::Full)),
            "query" => Ok(Self::Segment(SegmentMode::Query)),
            "tag" => Ok(Self::Tag),
            "keywords" => Ok(Self::Keywords),
            "textrank" => Ok(Self::TextRank),
            _ => Err(Error::Other(format!(
                "Unsupported worker type `{worker_type}`. Supported types are `mix`, `mp`, `hmm`, `full`, `query`, `tag`, `keywords`, and `textrank`."
            ))),
        }
    }
}

#[extendr]
pub struct JiebaWorker {
    pub engine: Jieba,
    pub family: WorkerFamily,
    pub use_hmm: bool,
    pub top_n: usize,
    pub stop_words: AHashSet<String>,
    pub keyword_extractor: Option<TfIdf>,
    pub textrank_extractor: Option<TextRank>,
    version: i32,
}

impl JiebaWorker {
    pub fn new(config: WorkerConfig<'_>) -> Result<Self> {
        let WorkerConfig {
            worker_type,
            use_hmm,
            hmm_model,
            idf_path,
            dict_path,
            user_paths,
            top_n,
            stop_words,
        } = config;

        let family = WorkerFamily::from_type(worker_type)?;
        let top_n = top_n as usize;
        let stop_words: AHashSet<String> = stop_words
            .into_iter()
            .map(|word| word.to_lowercase())
            .collect();
        let keyword_stop_words = stop_words.iter().cloned().collect();
        let textrank_stop_words = stop_words.iter().cloned().collect();

        let keyword_extractor = match family {
            WorkerFamily::Keywords => {
                let config = KeywordExtractConfig::builder()
                    .set_stop_words(keyword_stop_words)
                    .use_hmm(use_hmm)
                    .build();

                let extractor = if idf_path.is_empty() {
                    let mut e = TfIdf::default();
                    *e.config_mut() = config;
                    e
                } else {
                    let file = File::open(idf_path).map_err(|err| {
                        Error::Other(format!(
                            "Failed to open custom IDF dictionary `{idf_path}`: {err}"
                        ))
                    })?;
                    let mut reader = BufReader::new(file);
                    TfIdf::new(Some(&mut reader), config)
                };
                Some(extractor)
            }
            WorkerFamily::Segment(_) | WorkerFamily::Tag | WorkerFamily::TextRank => None,
        };

        let textrank_extractor = match family {
            WorkerFamily::TextRank => {
                let config = KeywordExtractConfig::builder()
                    .set_stop_words(textrank_stop_words)
                    .use_hmm(use_hmm)
                    .build();
                Some(TextRank::new(5, config))
            }
            WorkerFamily::Segment(_) | WorkerFamily::Tag | WorkerFamily::Keywords => None,
        };

        let mut engine = if dict_path.is_empty() {
            // Default: use the embedded dictionary.
            Jieba::new()
        } else {
            // `dict` replaces the main dictionary entirely.
            let file = File::open(dict_path).map_err(|err| {
                Error::Other(format!(
                    "Failed to open custom main dictionary `{dict_path}`: {err}"
                ))
            })?;
            let mut reader = BufReader::new(file);
            Jieba::with_dict(&mut reader).map_err(|err| {
                Error::Other(format!(
                    "Failed to load custom main dictionary `{dict_path}`: {err}"
                ))
            })?
        };

        // `user` appends to whatever dictionary is in place (default or
        // custom `dict`).
        for user_path in &user_paths {
            let file = File::open(user_path).map_err(|err| {
                Error::Other(format!(
                    "Failed to open user dictionary `{user_path}`: {err}"
                ))
            })?;
            let mut reader = BufReader::new(file);
            engine.load_dict(&mut reader).map_err(|err| {
                Error::Other(format!(
                    "Failed to load user dictionary `{user_path}`: {err}"
                ))
            })?;
        }

        if !hmm_model.is_empty() {
            let file = File::open(hmm_model).map_err(|err| {
                Error::Other(format!(
                    "Failed to open custom HMM model `{hmm_model}`: {err}"
                ))
            })?;
            let mut reader = BufReader::new(file);
            let model = HmmModel::load(&mut reader).map_err(|err| {
                Error::Other(format!(
                    "Failed to load custom HMM model `{hmm_model}`: {err}"
                ))
            })?;
            engine.set_hmm_model(model);
        }

        Ok(Self {
            engine,
            family,
            use_hmm,
            top_n,
            stop_words,
            keyword_extractor,
            textrank_extractor,
            version: WORKER_ABI_VERSION,
        })
    }

    pub fn validate(&self) -> Result<()> {
        if self.version != WORKER_ABI_VERSION {
            return Err(Error::Other(
                "Worker ABI version mismatch. Please create a new worker.".to_string(),
            ));
        }

        Ok(())
    }

    pub fn keep_token(&self, token: &str) -> bool {
        token != " " && !self.stop_words.contains(token)
    }
}
