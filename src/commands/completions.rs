//! The `completions` subcommand.

use std::io::Write;

use clap::CommandFactory;

use crate::{
    Result,
    cli::{Cli, CompletionsArgs},
};

/// Writes a completion script for the requested shell to `out`.
///
/// # Errors
///
/// Returns an error if writing to `out` fails.
pub fn run(args: &CompletionsArgs, out: &mut impl Write) -> Result<()> {
    let mut cmd = Cli::command();
    let bin_name = cmd.get_name().to_owned();
    // clap_complete panics on write errors, so render into memory first and
    // let I/O failures such as a closed pipe surface as regular errors.
    let mut script = Vec::new();
    clap_complete::generate(args.shell, &mut cmd, bin_name, &mut script);
    out.write_all(&script)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::run;
    use crate::cli::CompletionsArgs;
    use clap::ValueEnum;
    use clap_complete::Shell;

    #[test]
    fn generates_script_for_every_shell() {
        for shell in Shell::value_variants() {
            let mut out = Vec::new();
            run(&CompletionsArgs { shell: *shell }, &mut out).unwrap();
            let script = String::from_utf8(out).unwrap();
            assert!(
                script.contains("template-rust"),
                "{shell} script lacks the binary name"
            );
        }
    }
}
