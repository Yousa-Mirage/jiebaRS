use extendr_api::prelude::*;
use rayon::prelude::*;

use crate::worker::{JiebaWorker, SegmentMode, WorkerFamily};

fn segment_with_mode<'a>(worker: &JiebaWorker, mode: SegmentMode, text: &'a str) -> Vec<&'a str> {
    let engine = &worker.engine;
    let use_hmm = worker.use_hmm;

    let mut tokens = match mode {
        SegmentMode::Mix => engine.cut(text, use_hmm),
        SegmentMode::Mp => engine.cut(text, false),
        SegmentMode::Hmm => engine.cut(text, true),
        SegmentMode::Full => engine.cut_all(text),
        SegmentMode::Query => engine.cut_for_search(text, use_hmm),
    };
    if worker.stop_words.is_empty() {
        tokens.retain(|&token| token != " ");
    } else {
        tokens.retain(|&token| worker.keep_token(token));
    }
    tokens
}

impl JiebaWorker {
    fn get_segment_mode(&self) -> Result<SegmentMode> {
        match self.family {
            WorkerFamily::Segment(mode) => Ok(mode),
            WorkerFamily::Tag => Err(Error::Other(
                "`segment()` requires a segmentation worker, not a tag worker.".to_string(),
            )),
            WorkerFamily::Keywords => Err(Error::Other(
                "`segment()` requires a segmentation worker, not a keyword worker.".to_string(),
            )),
        }
    }

    pub fn segment_text<'a>(&'a self, text: &'a str) -> Result<Vec<&'a str>> {
        self.validate()?;
        let mode = self.get_segment_mode()?;
        let tokens = segment_with_mode(self, mode, text);
        Ok(tokens)
    }

    pub fn segment_texts<'a>(&'a self, texts: &'a [&'a str]) -> Result<Vec<Vec<&'a str>>> {
        self.validate()?;
        let mode = self.get_segment_mode()?;
        let tokens = texts
            .par_iter()
            .map(|&text| segment_with_mode(self, mode, text))
            .collect::<Vec<_>>();
        Ok(tokens)
    }
}
