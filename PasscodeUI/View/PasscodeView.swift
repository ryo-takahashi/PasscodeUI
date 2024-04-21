import SwiftUI
import LocalAuthentication

public struct PasscodeView: View {
    let passcodeLength: Int
    let lockType: PasscodeLockType
    let unlock: (() -> Void)
    
    @State private var inputPasscode: String = ""
    @State private var animateWrongPasscode: Bool = false
    @State private var isShowNoBiometricAccessNotice: Bool = false
    @State private var isEnterPasscodeButton: Bool = false
    @State private var isShowLockView: Bool = true
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    public init(passcodeLength: Int, lockType: PasscodeLockType, unlock: @escaping () -> Void) {
        self.passcodeLength = passcodeLength
        self.lockType = lockType
        self.unlock = unlock
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)
                .ignoresSafeArea()
            Group {
                switch lockType {
                case .onlyBiometric:
                    OnlyBiometricView()
                case .onlyPasscode(let passcode):
                    OnlyPasscodeView(passcode: passcode)
                case .both(let passcode):
                    BothView(passcode: passcode)
                }
            }
            .opacity(isShowLockView ? 1 : 0)
        }
        .onAppear(perform: onAppear)
        .environment(\.colorScheme, .dark)
    }
    
    @ViewBuilder
    private func BothView(passcode: String) -> some View {
        if isEnterPasscodeButton {
            NumberPadPinView(isShowBackButton: true, correctPasscode: passcode)
        } else {
            if isShowNoBiometricAccessNotice {
                VStack(spacing: 16) {
                    Image(systemName: "lock.app.dashed")
                        .font(.title)
                        .foregroundStyle(.gray)
                    Text("Locked")
                        .font(.title3.bold())
                    Text("Open the app settings and turn on Face ID permissions")
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                    Button {
                        let url = URL(string: UIApplication.openSettingsURLString)!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } label: {
                        Text("Open settings")
                    }
                    Button {
                        isEnterPasscodeButton = true
                    } label: {
                        Text("Enter passcode")
                    }
                }
                .padding(.horizontal, 48)
            } else {
                VStack(spacing: 16) {
                    RequestBioMetricButton()
                    
                    Button {
                        isEnterPasscodeButton = true
                    } label: {
                        Text("Enter passcode")
                    }
                }
            }
        }
    }
    
    private func OnlyPasscodeView(passcode: String) -> some View {
        NumberPadPinView(isShowBackButton: false, correctPasscode: passcode)
    }
    
    @ViewBuilder
    private func OnlyBiometricView() -> some View {
        if isShowNoBiometricAccessNotice {
            VStack(spacing: 16) {
                Image(systemName: "lock.app.dashed")
                    .font(.title)
                    .foregroundStyle(.gray)
                Text("Locked")
                    .font(.title3.bold())
                Text("Open the app settings and turn on Face ID permissions")
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                Button {
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } label: {
                    Text("Open settings")
                }
            }
            .padding(.horizontal, 48)
        } else {
            RequestBioMetricButton()
        }
    }
    
    private func RequestBioMetricButton() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "faceid")
                .font(.largeTitle)
            
            Text("Tap to unlock")
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(width: 100, height: 100)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
        .contentShape(.rect)
        .onTapGesture {
            requestBiometricUnlockIfNeeded()
        }
    }
    
    private func onAppear() {
        switch lockType {
        case .onlyBiometric, .both:
            requestBiometricUnlockIfNeeded()
        case .onlyPasscode:
            break
        }
    }
    
    private func requestBiometricUnlockIfNeeded() {
        Task {
            let isBiometricAvailable = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            if isBiometricAvailable {
                /// Requesting Biometric Unlock
                let localizedReason = String(localized: "Unlock the View")
                if let isSuccess = try? await LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason), isSuccess {
                    withAnimation {
                        isShowLockView = false
                    }
                    unlock()
                }
            }

            isShowNoBiometricAccessNotice = !isBiometricAvailable
        }
    }
    
    @ViewBuilder
    private func NumberPadPinView(isShowBackButton: Bool, correctPasscode: String) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            VStack(spacing: 16) {
                NumberPadPinContentView(isShowBackButton: isShowBackButton, correctPasscode: correctPasscode)
            }
        } else {
            let isLandscape = verticalSizeClass == .compact
            if isLandscape {
                HStack(spacing: 16) {
                    NumberPadPinContentView(isShowBackButton: isShowBackButton, correctPasscode: correctPasscode)
                }
            } else {
                VStack(spacing: 16) {
                    NumberPadPinContentView(isShowBackButton: isShowBackButton, correctPasscode: correctPasscode)
                }
            }
        }
    }
    
    @ViewBuilder
    private func NumberPadPinContentView(isShowBackButton: Bool, correctPasscode: String) -> some View {
        Spacer()
        VStack(spacing: 16) {
            Text("Enter passcode")
                .font(.body)
            
            HStack(spacing: 10) {
                ForEach(0..<passcodeLength, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 55)
                        .overlay {
                            let isSafeIndex = inputPasscode.count > index
                            if isSafeIndex {
                                let index = inputPasscode.index(inputPasscode.startIndex, offsetBy: index)
                                let string = String(inputPasscode[index])
                                
                                Text(string)
                                    .font(.title.bold())
                                    .foregroundStyle(.black)
                            }
                        }
                }
            }
            .shake($animateWrongPasscode)
        }
        Spacer()
        LazyVGrid(columns: Array(repeating: GridItem(), count: 3), content: {
            ForEach(1...9, id: \.self) { number in
                Button(action: {
                    if inputPasscode.count < passcodeLength {
                        inputPasscode.append("\(number)")
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                }, label: {
                    Text("\(number)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .contentShape(.rect)
                })
                .tint(.white)
            }
            
            /// 0 and Back Button
            Button(action: {
                if !inputPasscode.isEmpty {
                    inputPasscode.removeLast()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }, label: {
                Image(systemName: "delete.backward")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .contentShape(.rect)
            })
            .tint(.white)
            
            Button(action: {
                if inputPasscode.count < passcodeLength {
                    inputPasscode.append("0")
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }, label: {
                Text("0")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .contentShape(.rect)
            })
            .tint(.white)
            
            if isShowBackButton {
                Button {
                    inputPasscode = ""
                    isEnterPasscodeButton = false
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    Text("Cancel")
                }
                .tint(.white)
            }
        })
        .onChange(of: inputPasscode) { newValue in
            if newValue.count == passcodeLength {
                let isValidPasscode = correctPasscode == inputPasscode
                if isValidPasscode {
                    withAnimation {
                        isShowLockView = false
                    }
                    unlock()
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    inputPasscode = ""
                    animateWrongPasscode.toggle()
                }
            }
        }
    }
}

#Preview {
    PasscodeView(passcodeLength: 4, lockType: .onlyBiometric) {
        
    }
}

#Preview {
    PasscodeView(passcodeLength: 4, lockType: .onlyPasscode(passcode: "0000")) {
        
    }
}

#Preview {
    PasscodeView(passcodeLength: 4, lockType: .both(passcode: "0000")) {
        
    }
}
