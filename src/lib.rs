//! Library crate behind the `template-rust` command-line interface.
//!
//! The binary in `src/main.rs` only parses arguments, initializes logging, and
//! maps errors to exit codes. Everything else lives here so it can be unit
//! tested without spawning a process.

pub mod cli;
pub mod commands;
pub mod error;
pub mod logging;

use std::io::Write;

pub use error::{Error, Result};

use cli::{Cli, Command};

/// Runs the subcommand selected in `cli`, writing its output to `out`.
///
/// # Errors
///
/// Returns an error if the command fails or if writing to `out` fails.
pub fn run(cli: &Cli, out: &mut impl Write) -> Result<()> {
    match &cli.command {
        Command::Greet(args) => commands::greet::run(args, out)?,
        Command::Completions(args) => commands::completions::run(args, out)?,
    }
    out.flush()?;
    Ok(())
}
