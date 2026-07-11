use std::fs;

use extendr_api::{Error, Result};

const DEFAULT_MAIN_DICT_FREQUENCY: usize = 1;

#[derive(Clone, Copy)]
pub enum DictionaryKind {
    Main,
    User,
}

impl DictionaryKind {
    fn label(self) -> &'static str {
        match self {
            Self::Main => "main dictionary",
            Self::User => "user dictionary",
        }
    }
}

pub struct DictionaryEntry {
    pub word: String,
    pub frequency: Option<usize>,
    pub tag: Option<String>,
}

pub fn read_utf8_file(path: &str, label: &str) -> Result<String> {
    let bytes = fs::read(path)
        .map_err(|err| Error::Other(format!("Failed to open {label} `{path}`: {err}")))?;
    let contents = String::from_utf8(bytes)
        .map_err(|err| Error::Other(format!("Failed to read {label} `{path}` as UTF-8: {err}")))?;

    Ok(contents
        .strip_prefix('\u{feff}')
        .unwrap_or(&contents)
        .to_string())
}

pub fn read_dictionary(path: &str, kind: DictionaryKind) -> Result<Vec<DictionaryEntry>> {
    let label = kind.label();
    let contents = read_utf8_file(path, label)?;
    let mut entries = Vec::new();

    for (index, line) in contents.lines().enumerate() {
        let fields: Vec<&str> = line.split_whitespace().collect();
        if fields.is_empty() {
            continue;
        }
        if fields.len() > 3 {
            let expected = match kind {
                DictionaryKind::Main => "expected `word`, `word freq`, or `word freq tag`",
                DictionaryKind::User => {
                    "expected `word`, `word freq`, `word tag`, or `word freq tag`"
                }
            };
            return Err(invalid_entry(path, label, index + 1, expected));
        }

        let word = fields[0].to_string();
        let (frequency, tag) = match (kind, fields.as_slice()) {
            (DictionaryKind::Main, [_]) => (Some(DEFAULT_MAIN_DICT_FREQUENCY), None),
            (DictionaryKind::Main, [_, frequency]) => (
                Some(parse_positive_frequency(path, label, index + 1, frequency)?),
                None,
            ),
            (DictionaryKind::Main, [_, frequency, tag]) => (
                Some(parse_positive_frequency(path, label, index + 1, frequency)?),
                Some((*tag).to_string()),
            ),
            (DictionaryKind::User, [_]) => (None, None),
            (DictionaryKind::User, [_, value]) => match value.parse::<usize>() {
                Ok(frequency) => {
                    validate_positive_frequency(path, label, index + 1, frequency)?;
                    (Some(frequency), None)
                }
                Err(_) if value.parse::<f64>().is_ok() => {
                    return Err(invalid_entry(
                        path,
                        label,
                        index + 1,
                        "frequency must be a positive integer",
                    ));
                }
                Err(_) => (None, Some((*value).to_string())),
            },
            (DictionaryKind::User, [_, frequency, tag]) => (
                Some(parse_positive_frequency(path, label, index + 1, frequency)?),
                Some((*tag).to_string()),
            ),
            _ => unreachable!(),
        };

        entries.push(DictionaryEntry {
            word,
            frequency,
            tag,
        });
    }

    if entries.is_empty() {
        return Err(Error::Other(format!(
            "The {label} `{path}` contains no entries."
        )));
    }

    Ok(entries)
}

pub fn read_idf_dictionary(path: &str) -> Result<String> {
    let contents = read_utf8_file(path, "custom IDF dictionary")?;
    let mut entries = 0usize;

    for (index, line) in contents.lines().enumerate() {
        let fields: Vec<&str> = line.split_whitespace().collect();
        if fields.is_empty() {
            continue;
        }
        if fields.len() != 2 {
            return Err(invalid_entry(
                path,
                "custom IDF dictionary",
                index + 1,
                "expected exactly `word idf_value`",
            ));
        }

        let value = fields[1].parse::<f64>().map_err(|_| {
            invalid_entry(
                path,
                "custom IDF dictionary",
                index + 1,
                "IDF value must be numeric",
            )
        })?;
        if !value.is_finite() {
            return Err(invalid_entry(
                path,
                "custom IDF dictionary",
                index + 1,
                "IDF value must be finite",
            ));
        }
        entries += 1;
    }

    if entries == 0 {
        return Err(Error::Other(format!(
            "The custom IDF dictionary `{path}` contains no entries."
        )));
    }

    Ok(contents)
}

fn parse_positive_frequency(path: &str, label: &str, line: usize, value: &str) -> Result<usize> {
    let frequency = value
        .parse::<usize>()
        .map_err(|_| invalid_entry(path, label, line, "frequency must be a positive integer"))?;
    validate_positive_frequency(path, label, line, frequency)?;
    Ok(frequency)
}

fn validate_positive_frequency(
    path: &str,
    label: &str,
    line: usize,
    frequency: usize,
) -> Result<()> {
    if frequency == 0 {
        let message = match label {
            "user dictionary" => {
                "frequency must be greater than zero; omit it to infer it automatically"
            }
            _ => "frequency must be greater than zero",
        };
        return Err(invalid_entry(path, label, line, message));
    }
    Ok(())
}

fn invalid_entry(path: &str, label: &str, line: usize, message: &str) -> Error {
    Error::Other(format!(
        "Invalid {label} `{path}` at line {line}: {message}."
    ))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn strips_a_utf8_bom() {
        let path =
            std::env::temp_dir().join(format!("jiebars-bom-test-{}.txt", std::process::id()));
        assert!(fs::write(&path, "\u{feff}word 1 n").is_ok());
        let path_string = path.to_string_lossy().to_string();

        let contents = read_utf8_file(&path_string, "test file");

        assert!(fs::remove_file(path).is_ok());
        assert_eq!(contents.ok().as_deref(), Some("word 1 n"));
    }

    #[test]
    fn rejects_zero_frequency() {
        let error = validate_positive_frequency("dict.txt", "user dictionary", 2, 0)
            .err()
            .map(|error| error.to_string())
            .unwrap_or_default();
        assert!(error.contains("line 2"));
        assert!(error.contains("greater than zero"));
    }
}
