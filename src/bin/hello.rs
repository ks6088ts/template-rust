use std::io::{self, Write};

fn write_sum(mut output: impl Write) -> io::Result<()> {
    writeln!(output, "2 + 2 = {}", template_rust::add(2, 2))?;
    output.flush()
}

fn main() -> io::Result<()> {
    write_sum(io::stdout().lock())
}

#[cfg(test)]
mod tests {
    use super::write_sum;
    use std::io::{self, ErrorKind, Write};

    #[test]
    fn propagates_output_errors() {
        let output: &mut [u8] = &mut [];
        let error = write_sum(output).expect_err("writing to an empty slice must fail");

        assert_eq!(error.kind(), ErrorKind::WriteZero);
    }

    #[test]
    fn propagates_flush_errors() {
        struct FlushError;

        impl Write for FlushError {
            fn write(&mut self, buffer: &[u8]) -> io::Result<usize> {
                Ok(buffer.len())
            }

            fn flush(&mut self) -> io::Result<()> {
                Err(io::Error::new(ErrorKind::BrokenPipe, "flush failed"))
            }
        }

        let error = write_sum(FlushError).expect_err("a failed flush must be reported");

        assert_eq!(error.kind(), ErrorKind::BrokenPipe);
    }
}
