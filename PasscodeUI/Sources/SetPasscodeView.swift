import SwiftUI

public struct SetPasscodeView: View {
    public let passcodeLength: Int
    public let dismissOnSet: Bool
    public let onSet: (String) -> Void
    
    @State private var inputPasscode: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    public init(passcodeLength: Int, dismissOnSet: Bool, onSet: @escaping (String) -> Void) {
        self.passcodeLength = passcodeLength
        self.dismissOnSet = dismissOnSet
        self.onSet = onSet
    }
    
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)
                .ignoresSafeArea()
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                VStack(spacing: 16) {
                    ContentView()
                }
                .padding()
            } else {
                let isLandscape = verticalSizeClass == .compact
                if isLandscape {
                    HStack(spacing: 16) {
                        ContentView()
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        ContentView()
                    }
                    .padding()
                }
            }
            
        }
        .onChange(of: inputPasscode) { newValue in
            let reachMaxLength = newValue.count == passcodeLength
            if !reachMaxLength {
                return
            }
            onSet(newValue)
            if dismissOnSet {
                dismiss()
            }
        }
        .environment(\.colorScheme, .dark)
    }
    
    @ViewBuilder
    public func ContentView() -> some View {
        Spacer()
        VStack(spacing: 16) {
            Text("Enter your passcode", bundle: .module)
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
        })
    }
}

#Preview {
    SetPasscodeView(passcodeLength: 4, dismissOnSet: true, onSet: { passcode in
        // save passcode
        print("set passcode \(passcode)")
    })
}
