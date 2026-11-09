# CLI

## Usage

```shell
cargo run -- greet --name Rust        # Hello, Rust!
cargo run -- --help
```

```text
Usage: template-rust [OPTIONS] <COMMAND>

Commands:
  greet        Print a greeting
  completions  Generate a shell completion script

Options:
  -v, --verbose...  Increase log verbosity (-v: info, -vv: debug, -vvv: trace)
  -q, --quiet       Disable log output
```

- `greet [--name <NAME>]` prints `Hello, <NAME>!`. The name can also come from
  `TEMPLATE_RUST_NAME` and defaults to `World`. Command-line values take
  precedence over environment variables.
- `completions <bash|elvish|fish|powershell|zsh>` writes a completion script,
  for example `template-rust completions zsh > ~/.zfunc/_template-rust`.
- Command output goes to stdout. Logs and errors go to stderr. `RUST_LOG`
  (for example `RUST_LOG=debug`) overrides `-v`/`-q`.

## Exit codes

| Code | Meaning |
| --- | --- |
| 0 | success, `--help`, `--version`, or the reader closed the pipe (e.g. `\| head`) |
| 1 | runtime error, reported as `error: <cause chain>` |
| 2 | invalid command-line usage |

## Code layout

```text
src/
├── main.rs            # entry point: parse args, init logging, map errors to exit codes
├── lib.rs             # `run()` dispatches subcommands; the library is fully testable
├── cli.rs             # clap definitions (global flags, subcommands, arguments)
├── logging.rs         # tracing subscriber writing to stderr
├── error.rs           # typed library errors (thiserror)
└── commands/          # one module per subcommand
    ├── greet.rs
    └── completions.rs
tests/cli.rs           # end-to-end tests against the compiled binary
```

The library returns typed errors (`template_rust::Error`). Only the binary uses
`anyhow` to add context and print the cause chain. Commands write to a
generic `impl Write`, so unit tests check output in memory.

## Adding a subcommand

1. Add a variant to `cli::Command` with an `Args` struct.
2. Create `src/commands/<name>.rs` with `pub fn run(args, out) -> Result<()>`.
3. Dispatch it in `lib.rs::run`.
4. Add unit and CLI tests.
