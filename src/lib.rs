/// Adds two `u64` values.
///
/// # Examples
///
/// ```
/// assert_eq!(template_rust::add(2, 2), 4);
/// ```
///
/// # Panics
///
/// Panics if the sum exceeds `u64::MAX`.
pub fn add(left: u64, right: u64) -> u64 {
    left.checked_add(right).expect("u64 addition overflowed")
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    fn adds_values() {
        assert_eq!(add(2, 2), 4);
        assert_eq!(add(0, 0), 0);
        assert_eq!(add(u64::MAX, 0), u64::MAX);
    }

    #[test]
    #[should_panic(expected = "u64 addition overflowed")]
    fn panics_on_overflow() {
        add(u64::MAX, 1);
    }
}
