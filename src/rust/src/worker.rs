use ahash::AHashSet;

use extendr_api::prelude::*;
use jieba_rs::{Jieba, TfIdf};

pub const WORKER_ABI_VERSION: i32 = 1;

#[derive(Clone, Copy)]
pub enum WorkerFamily {
    Segment(SegmentMode),
    Tag,
    Keywords,
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
            _ => Err(Error::Other(format!(
                "Unsupported worker type `{worker_type}`. Supported types are `mix`, `mp`, `hmm`, `full`, `query`, `tag`, and `keywords`."
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
    version: i32,
}

impl JiebaWorker {
    pub fn new(
        worker_type: &str,
        use_hmm: bool,
        top_n: u32,
        stop_words: Vec<String>,
    ) -> Result<Self> {
        let family = WorkerFamily::from_type(worker_type)?;
        let top_n = usize::try_from(top_n)
            .map_err(|_| Error::Other("`top_n` must be a non-negative integer.".to_string()))?;
        let stop_words = stop_words.into_iter().collect();

        // TODO: The keyword worker still lacks several jiebaR-era knobs.
        // - Thread `use_hmm` into the TF-IDF extractor config instead of only
        //   storing it on the worker.
        // - Load custom IDF and stop-word dictionaries from R-provided paths.
        // - Split keyword-specific config into a dedicated struct once more
        //   keyword options are supported.
        let keyword_extractor = match family {
            WorkerFamily::Segment(_) | WorkerFamily::Tag => None,
            WorkerFamily::Keywords => Some(TfIdf::default()),
        };

        Ok(Self {
            engine: Jieba::new(),
            family,
            use_hmm,
            top_n,
            stop_words,
            keyword_extractor,
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
