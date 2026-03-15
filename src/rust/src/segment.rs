use extendr_api::prelude::*;

use crate::worker::{JiebaWorker, SegmentMode, WorkerFamily};

impl JiebaWorker {
    pub fn segment_text(&self, text: &str) -> Result<Vec<String>> {
        self.validate()?;

        let tokens = match self.family {
            WorkerFamily::Segment(SegmentMode::Mix) => self.engine.cut(text, self.use_hmm),
            WorkerFamily::Segment(SegmentMode::Mp) => self.engine.cut(text, false),
            WorkerFamily::Segment(SegmentMode::Hmm) => self.engine.cut(text, true),
            WorkerFamily::Segment(SegmentMode::Full) => self.engine.cut_all(text),
            WorkerFamily::Segment(SegmentMode::Query) => {
                self.engine.cut_for_search(text, self.use_hmm)
            }
            WorkerFamily::Tag => {
                return Err(Error::Other(
                    "`segment()` requires a segmentation worker, not a tag worker.".to_string(),
                ))
            }
            WorkerFamily::Keywords => {
                return Err(Error::Other(
                    "`segment()` requires a segmentation worker, not a keyword worker.".to_string(),
                ))
            }
        };

        Ok(tokens.into_iter().map(str::to_string).collect())
    }
}
