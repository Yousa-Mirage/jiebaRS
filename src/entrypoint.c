// We need to forward routine registration from C to Rust
// to avoid the linker removing the static library.

void R_init_jieba_rs_extendr(void *dll);
void register_extendr_panic_hook(void);

void R_init_jiebaRS(void *dll) {
    register_extendr_panic_hook();
    R_init_jieba_rs_extendr(dll);
}
