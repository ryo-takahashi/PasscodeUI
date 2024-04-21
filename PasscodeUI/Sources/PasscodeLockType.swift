public enum PasscodeLockType {
    case onlyBiometric
    case onlyPasscode(passcode: String)
    case both(passcode: String)
}
