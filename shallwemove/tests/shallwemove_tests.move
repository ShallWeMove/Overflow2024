#[test_only]
module shallwemove::shallwemove_tests {
    // uncomment this line to import the module
    use shallwemove::cardgame;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_shallwemove() {
        // pass
    }

    #[test, expected_failure(abort_code = shallwemove::shallwemove_tests::ENotImplemented)]
    fun test_shallwemove_fail() {
        abort ENotImplemented
    }
}