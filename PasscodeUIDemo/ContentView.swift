import SwiftUI
import PasscodeUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Set passcode", destination: SetPasscodeView(passcodeLength: 4, dismissOnSet: true, onSet: { passcode in
                        print("set passcode \(passcode)")
                    }))
                }
                Section {
                    NavigationLink("FaceID or Passcode", destination: PasscodeView(passcodeLength: 4, lockType: .both(passcode: "0000")) {
                        print("UNLOCK!!!")
                    })
                    NavigationLink("Only FaceID", destination: PasscodeView(passcodeLength: 4, lockType: .onlyBiometric) {
                        print("UNLOCK!!!")
                    })
                    NavigationLink("Only Passcode", destination: PasscodeView(passcodeLength: 4, lockType: .onlyPasscode(passcode: "0000")) {
                        print("UNLOCK!!!")
                    })
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
