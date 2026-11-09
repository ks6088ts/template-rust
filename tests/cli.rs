//! End-to-end tests that run the compiled binary.

use assert_cmd::{Command, cargo::cargo_bin_cmd};
use predicates::prelude::*;

fn cmd() -> Command {
    let mut cmd = cargo_bin_cmd!();
    cmd.env_remove("TEMPLATE_RUST_NAME").env_remove("RUST_LOG");
    cmd
}

#[test]
fn greets_world_by_default() {
    cmd()
        .arg("greet")
        .assert()
        .success()
        .stdout("Hello, World!\n")
        .stderr("");
}

#[test]
fn greets_given_name() {
    cmd()
        .args(["greet", "--name", "Ferris"])
        .assert()
        .success()
        .stdout("Hello, Ferris!\n");
}

#[test]
fn reads_name_from_environment() {
    cmd()
        .arg("greet")
        .env("TEMPLATE_RUST_NAME", "Env")
        .assert()
        .success()
        .stdout("Hello, Env!\n");
}

#[test]
fn reports_runtime_errors_with_exit_code_1() {
    cmd()
        .args(["greet", "--name", " "])
        .assert()
        .code(1)
        .stdout("")
        .stderr("error: name must not be empty\n");
}

#[test]
fn reports_usage_errors_with_exit_code_2() {
    cmd().arg("unknown").assert().code(2).stdout("");
    cmd()
        .assert()
        .code(2)
        .stderr(predicate::str::contains("Usage:"));
    cmd().args(["-v", "-q", "greet"]).assert().code(2);
}

#[test]
fn prints_version() {
    cmd()
        .arg("--version")
        .assert()
        .success()
        .stdout(format!("template-rust {}\n", env!("CARGO_PKG_VERSION")));
}

#[test]
fn prints_help() {
    cmd()
        .arg("--help")
        .assert()
        .success()
        .stdout(predicate::str::contains(env!("CARGO_PKG_DESCRIPTION")))
        .stdout(predicate::str::contains("greet"))
        .stdout(predicate::str::contains("completions"));
}

#[test]
fn logs_to_stderr_when_verbose() {
    cmd()
        .args(["-vv", "greet"])
        .assert()
        .success()
        .stdout("Hello, World!\n")
        .stderr(predicate::str::contains("building greeting"));
}

#[test]
fn generates_completions() {
    cmd()
        .args(["completions", "bash"])
        .assert()
        .success()
        .stdout(predicate::str::contains("complete -F _template__rust"));
}
