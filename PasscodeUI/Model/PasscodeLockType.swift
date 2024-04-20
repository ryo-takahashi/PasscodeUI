public enum PasscodeLockType {
    case onlyFaceID
    case onlyPasscode(passcode: String)
    case both(passcode: String)
}
