use extendr_api::prelude::*;
use extendr_api::wrapper::Nullable;
use extendr_api::{Error, Result};

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

        let tag_values: Vec<Option<&str>> = tags
            .iter()
            .map(|tag| {
                if tag.is_na() {
                    None
                } else {
                    Some(tag.as_ref())
                }
            })
            .collect();

        let freq_values = match freq {
            Nullable::Null => vec![None],
            Nullable::NotNull(freqs) => {
                let freqs: &[Rint] = freqs;
                freqs
                    .iter()
                    .map(|freq| {
                        let value: Option<i32> = (*freq).into();
                        match value {
                            None => Ok(None),
                            Some(value) if value > 0 => {
                                usize::try_from(value).map(Some).map_err(|_| {
                                    Error::Other(
                                        "`freq` must contain only positive integers or `NA` values."
                                            .to_string(),
                                    )
                                })
                            }
                            Some(_) => Err(Error::Other(
                                "`freq` must contain only positive integers or `NA` values."
                                    .to_string(),
                            )),
                        }
                    })
                    .collect::<Result<Vec<_>>>()?
            }
        };

        for (i, word) in words.iter().enumerate() {
            let tag = tag_values[i % tag_values.len()];
            let freq = freq_values[i % freq_values.len()];
            self.engine.add_word(word, freq, tag);
        }

        Ok(())
    }
}
