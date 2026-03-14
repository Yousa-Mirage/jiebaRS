use extendr_api::prelude::*;

use crate::worker::JiebaWorker;

impl JiebaWorker {
    pub fn add_user_words(&mut self, words: &[String], tags: &[String]) -> Result<()> {
        self.validate()?;

        for (word, tag) in words.iter().zip(tags.iter()) {
            self.engine.add_word(word, None, Some(tag));
        }

        Ok(())
    }
}
