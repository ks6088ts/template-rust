use std::process::Command;

#[test]
fn prints_the_sum() {
    let output = Command::new(env!("CARGO_BIN_EXE_hello"))
        .output()
        .expect("failed to run hello");

    assert!(
        output.status.success(),
        "hello exited with {}",
        output.status
    );
    assert_eq!(output.stdout.as_slice(), b"2 + 2 = 4\n");
    assert!(
        output.stderr.is_empty(),
        "unexpected stderr: {}",
        String::from_utf8_lossy(&output.stderr)
    );
}
