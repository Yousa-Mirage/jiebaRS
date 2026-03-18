use extendr_api::prelude::*;
use jieba_rs::Tag;
use rayon::prelude::*;

use crate::worker::{JiebaWorker, WorkerFamily};

fn tag_with_engine<'a>(worker: &'a JiebaWorker, text: &'a str) -> Vec<Tag<'a>> {
    let use_hmm = worker.use_hmm;
    let mut tags: Vec<Tag<'_>> = worker.engine.tag(text, use_hmm);
    if worker.stop_words.is_empty() {
        tags.retain(|record| record.word != " ");
    } else {
        tags.retain(|record| worker.keep_token(record.word));
    }
    tags
}

impl JiebaWorker {
    fn ensure_tag_worker(&self) -> Result<()> {
        if let WorkerFamily::Tag = self.family {
            Ok(())
        } else {
            Err(Error::Other(
                "`tagging()` requires a tag worker created with `worker(type = 'tag')`."
                    .to_string(),
            ))
        }
    }

    pub fn tag_text<'a>(&'a self, text: &'a str) -> Result<Vec<Tag<'a>>> {
        self.validate()?;
        self.ensure_tag_worker()?;

        Ok(tag_with_engine(self, text))
    }

    pub fn tag_texts<'a>(&'a self, texts: &'a [&'a str]) -> Result<Vec<Vec<Tag<'a>>>> {
        self.validate()?;
        self.ensure_tag_worker()?;

        Ok(texts
            .par_iter()
            .map(|&text| tag_with_engine(self, text))
            .collect())
    }
}
