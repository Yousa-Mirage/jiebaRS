use extendr_api::{Error, Result};
use jieba_rs::{Keyword, KeywordExtract};

use crate::worker::JiebaWorker;

impl JiebaWorker {
    pub fn extract_keywords(&self, text: &str) -> Result<Vec<Keyword>> {
        self.validate()?;

        let Some(extractor) = &self.keyword_extractor else {
            return Err(Error::Other(
                "This worker is not configured for TF-IDF keyword extraction.".to_string(),
            ));
        };

        let keywords = extractor.extract_keywords(&self.engine, text, self.top_n, vec![]);

        Ok(keywords)
    }

    pub fn extract_textrank(&self, text: &str) -> Result<Vec<Keyword>> {
        self.validate()?;

        let Some(extractor) = &self.textrank_extractor else {
            return Err(Error::Other(
                "This worker is not configured for TextRank keyword extraction.".to_string(),
            ));
        };

        let candidate_count = self.engine.tag(text, self.use_hmm).len();
        let keywords = extractor
            .extract_keywords(&self.engine, text, candidate_count, vec![])
            .into_iter()
            .filter(|keyword| {
                keyword.keyword.chars().count() >= self.min_keyword_length
                    && !self.stop_words.contains(&keyword.keyword.to_lowercase())
            })
            .take(self.top_n)
            .collect();

        Ok(keywords)
    }
}
