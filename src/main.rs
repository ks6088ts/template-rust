//! Command-line entry point for `template-rust`.

use std::{
    io::{self, Write},
    process::ExitCode,
};

use anyhow::Context;
use clap::Parser;
use template_rust::{cli::Cli, logging};

fn main() -> ExitCode {
    // Usage errors exit with status 2 and `--help`/`--version` with 0 inside `parse`.
    let cli = Cli::parse();

    match run(&cli) {
        Ok(()) => ExitCode::SUCCESS,
        // A closed downstream pipe (e.g. `| head`) is not a failure of this program.
        Err(err) if is_broken_pipe(&err) => ExitCode::SUCCESS,
        Err(err) => {
            let _ = writeln!(io::stderr().lock(), "error: {err:#}");
            ExitCode::FAILURE
        }
    }
}

fn run(cli: &Cli) -> anyhow::Result<()> {
    logging::init(&cli.verbosity)
        .map_err(anyhow::Error::from_boxed)
        .context("failed to initialize logging")?;
    template_rust::run(cli, &mut io::stdout().lock())?;
    Ok(())
}

fn is_broken_pipe(err: &anyhow::Error) -> bool {
    err.chain()
        .filter_map(|cause| cause.downcast_ref::<io::Error>())
        .any(|io_err| io_err.kind() == io::ErrorKind::BrokenPipe)
}

#[cfg(test)]
mod tests {
    use super::is_broken_pipe;
    use std::io;

    #[test]
    fn detects_nested_broken_pipe() {
        let err = anyhow::Error::from(template_rust::Error::from(io::Error::from(
            io::ErrorKind::BrokenPipe,
        )));
        assert!(is_broken_pipe(&err));
    }

    #[test]
    fn ignores_other_errors() {
        let err = anyhow::Error::from(template_rust::Error::EmptyName);
        assert!(!is_broken_pipe(&err));
    }
}
