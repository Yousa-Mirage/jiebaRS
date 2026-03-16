use extendr_api::prelude::*;
use rayon::prelude::*;

use crate::worker::{JiebaWorker, SegmentMode, WorkerFamily};

fn segment_with_mode<'a>(
    engine: &'a jieba_rs::Jieba,
    mode: SegmentMode,
    use_hmm: bool,
    text: &'a str,
) -> Vec<&'a str> {
    let tokens = match mode {
        SegmentMode::Mix => engine.cut(text, use_hmm),
        SegmentMode::Mp => engine.cut(text, false),
        SegmentMode::Hmm => engine.cut(text, true),
        SegmentMode::Full => engine.cut_all(text),
        SegmentMode::Query => engine.cut_for_search(text, use_hmm),
    };
    tokens.into_iter().filter(|&s| s != " ").collect()
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
        Ok(segment_with_mode(&self.engine, mode, self.use_hmm, text))
    }

    pub fn segment_texts<'a>(&'a self, texts: &'a [&'a str]) -> Result<Vec<Vec<&'a str>>> {
        self.validate()?;
        let mode = self.get_segment_mode()?;

        Ok(texts
            .par_iter()
            .map(|&text| segment_with_mode(&self.engine, mode, self.use_hmm, text))
            .collect())
    }
}
