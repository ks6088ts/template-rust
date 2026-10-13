use std::io::{self, Write};

fn write_sum(mut output: impl Write) -> io::Result<()> {
    writeln!(output, "2 + 2 = {}", template_rust::add(2, 2))
}

fn main() -> io::Result<()> {
    write_sum(io::stdout().lock())
}

#[cfg(test)]
mod tests {
    use super::write_sum;
    use std::io::ErrorKind;

    #[test]
    fn propagates_output_errors() {
        let output: &mut [u8] = &mut [];
        let error = write_sum(output).expect_err("writing to an empty slice must fail");

        assert_eq!(error.kind(), ErrorKind::WriteZero);
    }
}
