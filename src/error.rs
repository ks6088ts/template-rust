//! Error types returned by the library.

use std::io;

/// Errors produced by `template-rust` commands.
#[derive(Debug, thiserror::Error)]
#[non_exhaustive]
pub enum Error {
    /// The name passed to `greet` was empty or only whitespace.
    #[error("name must not be empty")]
    EmptyName,

    /// Reading or writing failed.
    #[error("I/O error")]
    Io(#[from] io::Error),
}

/// A specialized [`Result`](std::result::Result) for this crate.
pub type Result<T, E = Error> = std::result::Result<T, E>;
