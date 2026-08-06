use ::cidian as parser;
use extendr_api::{Error, Result};

use crate::worker::JiebaWorker;

fn parse_dictionary(path: &str, format: &str) -> Result<parser::Dictionary> {
    let dictionary = match format {
        "scel" => parser::scel::parse_file(path),
        "qcel" => parser::qcel::parse_file(path),
        "qpyd" => parser::qpyd::parse_file(path),
        "bdict" => parser::bdict::parse_file(path),
        "bcd" => parser::bcd::parse_file(path),
        _ => unreachable!("unsupported input-method dictionary format: {format}"),
    };

    dictionary.map_err(|error| {
        Error::Other(format!(
            "Failed to parse input-method dictionary `{path}`: {error}"
        ))
    })
}

impl JiebaWorker {
    pub fn import_cidian(&mut self, path: &str, format: &str, tag: Option<&str>) -> Result<()> {
        self.validate()?;

        for entry in parse_dictionary(path, format)?.entries {
            self.engine.add_word(&entry.word, None, tag);
        }

        Ok(())
    }
}

pub fn read_cidian(path: &str, format: &str) -> Result<(Vec<String>, Vec<String>)> {
    Ok(parse_dictionary(path, format)?
        .entries
        .into_iter()
        .map(|entry| (entry.word, entry.code.join(" ")))
        .unzip())
}
