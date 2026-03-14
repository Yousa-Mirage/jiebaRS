use extendr_api::prelude::*;
use jieba_rs::{Jieba, TfIdf};

pub const WORKER_ABI_VERSION: i32 = 1;

#[derive(Clone, Copy)]
pub enum WorkerFamily {
    Segment(SegmentMode),
    Keywords,
}

#[derive(Clone, Copy)]
pub enum SegmentMode {
    Mix,
}

impl WorkerFamily {
    fn from_type(worker_type: &str) -> Result<Self> {
        match worker_type {
            "mix" => Ok(Self::Segment(SegmentMode::Mix)),
            "keywords" => Ok(Self::Keywords),
            _ => Err(Error::Other(format!(
                "Unsupported worker type `{worker_type}`. Supported types are `mix` and `keywords`."
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
    pub keyword_extractor: Option<TfIdf>,
    version: i32,
}

impl JiebaWorker {
    pub fn new(worker_type: &str, use_hmm: bool, top_n: u32) -> Result<Self> {
        let family = WorkerFamily::from_type(worker_type)?;
        let top_n = usize::try_from(top_n)
            .map_err(|_| Error::Other("`top_n` must be a non-negative integer.".to_string()))?;

        // TODO: The keyword worker still lacks several jiebaR-era knobs.
        // - Thread `use_hmm` into the TF-IDF extractor config instead of only
        //   storing it on the worker.
        // - Load custom IDF and stop-word dictionaries from R-provided paths.
        // - Split keyword-specific config into a dedicated struct once more
        //   keyword options are supported.
        let keyword_extractor = match family {
            WorkerFamily::Segment(_) => None,
            WorkerFamily::Keywords => Some(TfIdf::default()),
        };

        Ok(Self {
            engine: Jieba::new(),
            family,
            use_hmm,
            top_n,
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
}
