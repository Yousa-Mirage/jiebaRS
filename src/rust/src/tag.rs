use extendr_api::prelude::*;
use jieba_rs::Tag;
use rayon::prelude::*;

use crate::worker::{JiebaWorker, WorkerFamily};

fn tag_with_engine<'a>(engine: &'a jieba_rs::Jieba, use_hmm: bool, text: &'a str) -> Vec<Tag<'a>> {
    let mut tags = engine.tag(text, use_hmm);
    tags.retain(|record| record.word != " ");
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

        Ok(tag_with_engine(&self.engine, self.use_hmm, text))
    }

    pub fn tag_texts<'a>(&'a self, texts: &'a [&'a str]) -> Result<Vec<Vec<Tag<'a>>>> {
        self.validate()?;
        self.ensure_tag_worker()?;

        Ok(texts
            .par_iter()
            .map(|&text| tag_with_engine(&self.engine, self.use_hmm, text))
            .collect())
    }
}
