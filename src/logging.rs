//! Logging setup based on [`tracing`].

use std::io::{self, IsTerminal};

use tracing_subscriber::EnvFilter;

use crate::cli::Verbosity;

/// Error returned when a global subscriber is already installed.
pub type InitError = Box<dyn std::error::Error + Send + Sync + 'static>;

/// Installs a global subscriber that writes human-readable logs to stderr.
///
/// `RUST_LOG` takes precedence over the `-v`/`-q` flags when it is set, so
/// stdout stays reserved for command output.
///
/// # Errors
///
/// Returns an error if a global subscriber has already been installed.
pub fn init(verbosity: &Verbosity) -> Result<(), InitError> {
    let filter = EnvFilter::builder()
        .with_default_directive(verbosity.level_filter().into())
        .from_env_lossy();

    tracing_subscriber::fmt()
        .with_env_filter(filter)
        .with_writer(io::stderr)
        .with_ansi(io::stderr().is_terminal())
        .with_target(false)
        .without_time()
        .try_init()
}
