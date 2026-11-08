//! The `greet` subcommand.

use std::io::Write;

use crate::{Error, Result, cli::GreetArgs};

/// Builds a greeting for `name`, ignoring surrounding whitespace.
///
/// # Errors
///
/// Returns [`Error::EmptyName`] if `name` is empty or only whitespace.
///
/// # Examples
///
/// ```
/// assert_eq!(template_rust::commands::greet::greeting("Rust")?, "Hello, Rust!");
/// # Ok::<(), template_rust::Error>(())
/// ```
pub fn greeting(name: &str) -> Result<String> {
    let name = name.trim();
    if name.is_empty() {
        return Err(Error::EmptyName);
    }
    Ok(format!("Hello, {name}!"))
}

/// Writes a greeting line to `out`.
///
/// # Errors
///
/// Returns an error if the name is invalid or writing fails.
pub fn run(args: &GreetArgs, out: &mut impl Write) -> Result<()> {
    tracing::debug!(name = %args.name, "building greeting");
    writeln!(out, "{}", greeting(&args.name)?)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::{greeting, run};
    use crate::{Error, cli::GreetArgs};

    #[test]
    fn greets_trimmed_name() {
        assert_eq!(greeting("  Ferris ").unwrap(), "Hello, Ferris!");
    }

    #[test]
    fn rejects_blank_name() {
        assert!(matches!(greeting(" \t"), Err(Error::EmptyName)));
    }

    #[test]
    fn writes_greeting_line() {
        let mut out = Vec::new();
        run(
            &GreetArgs {
                name: "World".into(),
            },
            &mut out,
        )
        .unwrap();
        assert_eq!(out, b"Hello, World!\n");
    }

    #[test]
    fn propagates_write_errors() {
        let mut out: &mut [u8] = &mut [];
        let err = run(
            &GreetArgs {
                name: "World".into(),
            },
            &mut out,
        )
        .unwrap_err();
        assert!(matches!(err, Error::Io(e) if e.kind() == std::io::ErrorKind::WriteZero));
    }
}
