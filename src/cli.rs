//! Command-line argument definitions.

use clap::{ArgAction, Args, Parser, Subcommand};
use clap_complete::Shell;
use tracing_subscriber::filter::LevelFilter;

/// Top-level command-line arguments.
#[derive(Debug, Parser)]
#[command(name = "template-rust", version, about, long_about = None, propagate_version = true)]
pub struct Cli {
    /// Logging verbosity flags shared by all subcommands.
    #[command(flatten)]
    pub verbosity: Verbosity,

    /// The subcommand to run.
    #[command(subcommand)]
    pub command: Command,
}

/// Global flags that control log output on stderr.
#[derive(Debug, Default, Args)]
pub struct Verbosity {
    /// Increase log verbosity (-v: info, -vv: debug, -vvv: trace)
    #[arg(short, long, action = ArgAction::Count, global = true, conflicts_with = "quiet")]
    pub verbose: u8,

    /// Disable log output
    #[arg(short, long, global = true)]
    pub quiet: bool,
}

impl Verbosity {
    /// Returns the maximum log level selected by the flags. Defaults to `WARN`.
    #[must_use]
    pub fn level_filter(&self) -> LevelFilter {
        if self.quiet {
            return LevelFilter::OFF;
        }
        match self.verbose {
            0 => LevelFilter::WARN,
            1 => LevelFilter::INFO,
            2 => LevelFilter::DEBUG,
            _ => LevelFilter::TRACE,
        }
    }
}

/// Available subcommands.
#[derive(Debug, Subcommand)]
pub enum Command {
    /// Print a greeting
    Greet(GreetArgs),
    /// Generate a shell completion script
    Completions(CompletionsArgs),
}

/// Arguments for the `greet` subcommand.
#[derive(Debug, Args)]
pub struct GreetArgs {
    /// Name to greet
    #[arg(short, long, env = "TEMPLATE_RUST_NAME", default_value = "World")]
    pub name: String,
}

/// Arguments for the `completions` subcommand.
#[derive(Debug, Args)]
pub struct CompletionsArgs {
    /// Target shell
    #[arg(value_enum)]
    pub shell: Shell,
}

#[cfg(test)]
mod tests {
    use super::{Cli, Verbosity};
    use clap::CommandFactory;
    use tracing_subscriber::filter::LevelFilter;

    #[test]
    fn command_definition_is_valid() {
        Cli::command().debug_assert();
    }

    #[test]
    fn verbosity_maps_to_level_filter() {
        let cases = [
            (0, false, LevelFilter::WARN),
            (1, false, LevelFilter::INFO),
            (2, false, LevelFilter::DEBUG),
            (3, false, LevelFilter::TRACE),
            (9, false, LevelFilter::TRACE),
            (0, true, LevelFilter::OFF),
        ];
        for (verbose, quiet, expected) in cases {
            let verbosity = Verbosity { verbose, quiet };
            assert_eq!(
                verbosity.level_filter(),
                expected,
                "-v x{verbose}, quiet={quiet}"
            );
        }
    }
}
