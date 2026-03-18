use extendr_api::prelude::*;
use extendr_api::wrapper::Nullable;

use crate::worker::JiebaWorker;

impl JiebaWorker {
    pub fn add_user_words(
        &mut self,
        words: &Strings,
        tags: &Strings,
        freq: &Nullable<Integers>,
    ) -> Result<()> {
        self.validate()?;

        if words.is_empty() {
            return Ok(());
        }

        let tags_iter = tags[..]
            .iter()
            .map(|t| if t.is_na() { None } else { Some(t.as_str()) })
            .cycle();

        match freq {
            Nullable::Null => {
                for (word, tag) in words.iter().zip(tags_iter) {
                    self.engine.add_word(word, None, tag);
                }
            }
            Nullable::NotNull(freqs) => {
                let freqs_iter = freqs[..]
                    .iter()
                    .map(|f| {
                        if f.is_na() {
                            None
                        } else {
                            Some(f.inner() as usize)
                        }
                    })
                    .cycle();

                for ((word, tag), freq) in words.iter().zip(tags_iter).zip(freqs_iter) {
                    self.engine.add_word(word, freq, tag);
                }
            }
        }

        Ok(())
    }
}
