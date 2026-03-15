use extendr_api::prelude::*;
use jieba_rs::Tag;

use crate::worker::{JiebaWorker, WorkerFamily};

impl JiebaWorker {
    pub fn tag_text<'a>(&'a self, text: &'a str) -> Result<Vec<Tag<'a>>> {
        self.validate()?;

        if let WorkerFamily::Tag = self.family {
            Ok(self.engine.tag(text, self.use_hmm))
        } else {
            Err(Error::Other(
                "`tagging()` requires a tag worker created with `worker(type = 'tag')`."
                    .to_string(),
            ))
        }
    }
}
