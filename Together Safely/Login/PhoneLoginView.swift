//
//  PhoneLoginView.swift
//  Together
//
//  Created by Larry Shannon on 7/17/20.
//

import SwiftUI
import Combine
import Firebase

struct PhoneLoginView: View {
    
    @State private var phoneNumber: String = ""
    @State private var show = false
    @State private var msg = ""
    @State private var alert = false
    @State private var returnId : String = ""
    @State private var textSize:CGFloat = 35
    @State private var showIndicator = false
    @State private var keyboardHeight: CGFloat = 0
    @EnvironmentObject var locationFetcher: LocationFetcher
    
    var currencyFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.locale = .current
    formatter.numberStyle = .currency
    return formatter
    }
    
    var body: some View {
        ZStack {
            Color("Color-backgroud").edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Spacer()
                HStack {
                    Image("appIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("together")
                    .font(Font.custom("Avenir-Heavy", size: 50))
                    .foregroundColor(.white)
                }
                Spacer()
                Group {
                    Text("Enter your phone")
                        .font(Font.custom("Avenir-Black", size: textSize))
                        .foregroundColor(.white)
                    Text("number to create")
                        .font(Font.custom("Avenir-Black", size: textSize))
                        .foregroundColor(.white)
                    Text("your account")
                        .font(Font.custom("Avenir-Black", size: textSize))
                        .foregroundColor(.white)
                }
                Spacer()
                CustomTextField("(XXX) XXX-XXXX", value: $phoneNumber, keyType: .numberPad)
                    .frame(width: 300, height: 25)
                    .font(Font.custom("Avenir-Black", size: 25))
                    .padding()
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .multilineTextAlignment(TextAlignment.center)
                    .padding(.bottom, keyboardHeight)
                    .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
                Spacer()
                NavigationLink(destination: PhoneVerificationView(id: $returnId), isActive: $show) {
                    Button(action: {
                        if self.phoneNumber.count != 10 {
                            self.msg = "Enter a 10 digit number"
                            self.alert.toggle()
                            return
                        }
                        PhoneAuthProvider.provider().verifyPhoneNumber("+1"+self.phoneNumber, uiDelegate: nil) { (id, err) in
                            if err != nil {
                                self.msg = (err?.localizedDescription)!
                                self.alert.toggle()
                                return
                            }
                            if let id = id {
                                self.returnId = id
                                UserDefaults.standard.set(id, forKey: "authVerificationID")
                            }
                            self.show.toggle()
                            self.showIndicator.toggle()
                        }
                        self.showIndicator.toggle()
                    }) {
                        Text("Continue")
                            .frame(width: 200, height: 50)
                            .font(Font.custom("Avenir-Black", size: 25))
                    }
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                Spacer()

                Group {
                    NavigationLink(destination: LocationServiceNotEnableView(), isActive: $locationFetcher.alert2) {
                        EmptyView()
                    }
                }

            }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("ok")))
            }
            .onAppear() {
                self.locationFetcher.checkIfEnabled()
            }
            if self.showIndicator {
                GeometryReader {geometry in
                    SpinnerView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
}

struct PhoneLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneLoginView()
    }
}

struct CustomTextField: UIViewRepresentable {
    private var placeholder: String
    @Binding var value: String
    var keyType: UIKeyboardType

    init(_ placeholder: String,
         value: Binding<String>,
         keyType: UIKeyboardType) {
        self.placeholder = placeholder
        self._value = value
        self.keyType = keyType
    }

    func makeUIView(context: Context) -> UITextField {
        let textfield = UITextField()
        textfield.keyboardType = keyType
        textfield.delegate = context.coordinator
        textfield.placeholder = placeholder
        textfield.text = value
        textfield.textAlignment = .right

        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: textfield.frame.size.width,
                                              height: 44))
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .done,
                                         target: self,
                                         action: #selector(textfield.doneButtonTapped(button:)))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                    target: nil,action: nil)
        toolBar.setItems([space, doneButton], animated: true)
        textfield.inputAccessoryView = toolBar
        return textfield
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // Do nothing, needed for protocol
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(_ textField: CustomTextField) {
            self.parent = textField
        }
        
        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {

//            self.parent.value.append(string)
            
            return true
        }

        func textFieldDidEndEditing(_ textField: UITextField,
                                    reason: UITextField.DidEndEditingReason) {
            // Format value with formatter at End Editing
            print(textField.text!)
            if let str = textField.text {
                self.parent.value = str
            }
        }

    }
}


