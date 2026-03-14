use extendr_api::prelude::*;

#[extendr]
fn hello_world() -> &'static str {
    "Hello world!"
}

extendr_module! {
    mod jiebaRS;
    fn hello_world;
}
