use extendr_api::{Error, Result};
use jieba_rs::{Keyword, KeywordExtract};

use crate::worker::JiebaWorker;

impl JiebaWorker {
    pub fn extract_keywords(&self, text: &str) -> Result<Vec<Keyword>> {
        self.validate()?;

        // TODO: Match the remaining jiebaR keyword behavior.
        // - Expose configurable allowed POS filtering if we decide to support
        //   richer keyword controls than jiebaR offered.
        let Some(extractor) = &self.keyword_extractor else {
            return Err(Error::Other(
                "This worker is not configured for keyword extraction.".to_string(),
            ));
        };

        let keywords = extractor.extract_keywords(&self.engine, text, self.top_n, vec![]);

        Ok(keywords)
    }
}
