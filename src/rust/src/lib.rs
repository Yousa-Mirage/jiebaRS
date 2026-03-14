use extendr_api::prelude::*;
use jieba_rs::Jieba;

const WORKER_ABI_VERSION: i32 = 1;

#[derive(Clone, Copy)]
enum WorkerKind {
    Mix,
}

impl WorkerKind {
    fn from_str(kind: &str) -> Result<Self> {
        match kind {
            "mix" => Ok(Self::Mix),
            _ => Err(Error::Other(format!(
                "Unsupported worker type `{kind}`. Only `mix` is implemented right now."
            ))),
        }
    }
}

#[extendr]
struct JiebaWorker {
    engine: Jieba,
    kind: WorkerKind,
    use_hmm: bool,
    version: i32,
}

impl JiebaWorker {
    fn new(kind: WorkerKind, use_hmm: bool) -> Self {
        Self {
            engine: jieba_rs::Jieba::new(),
            kind,
            use_hmm,
            version: WORKER_ABI_VERSION,
        }
    }

    fn segment_text(&self, text: &str) -> Vec<String> {
        let tokens = match self.kind {
            WorkerKind::Mix => self.engine.cut(text, self.use_hmm),
        };

        tokens.into_iter().map(str::to_string).collect()
    }
}

#[extendr]
fn new_worker(kind: &str, use_hmm: bool) -> Result<JiebaWorker> {
    let kind = WorkerKind::from_str(kind)?;
    Ok(JiebaWorker::new(kind, use_hmm))
}

#[extendr]
fn segment_worker(text: &str, worker: &JiebaWorker) -> Result<Vec<String>> {
    if worker.version != WORKER_ABI_VERSION {
        return Err(Error::Other(
            "Worker ABI version mismatch. Please create a new worker.".to_string(),
        ));
    }

    Ok(worker.segment_text(text))
}

extendr_module! {
    mod jiebaRS;
    fn new_worker;
    fn segment_worker;
}
