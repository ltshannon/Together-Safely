//
//  DummyView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/27/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts

@available(iOS 14.0, *)
struct DummyView: View {
    
//    @ObservedObject private var contactStore: ContactStore = ContactStore()
//    @StateObject var locationFetcher: LocationFetcher = LocationFetcher()
    @EnvironmentObject var dataController: DataController
    @State var attitudeQuestion = UserDefaults.standard.value(forKey: "attitudeQuestion") as? Bool ?? false
    @State private var action1 = true
    @State private var action2 = true
    
    var body: some View {
        VStack {
            HomeView().environmentObject(dataController).padding(.top, 10)
        }
        .onAppear {
            let userPhoneNumber =  UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
            if !dataController.isInitialized {
                dataController.getContacts(byPhoneNumber: userPhoneNumber) { error in
                    dataController.startListeners(phoneNumber: userPhoneNumber) { completion in
                        print("Completed startListeners")
                    }
                }
            }
        }
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                print("Moving back to the foreground!")
                let userPhoneNumber =  UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
                dataController.getContacts(byPhoneNumber: userPhoneNumber) { error in
                    dataController.startListeners(phoneNumber: userPhoneNumber) { completion in
                        print("Completed startListeners")
                    }
                }
//                self.locationFetcher.start()
        }
    }
}

struct DummyView_Previews: PreviewProvider {
    static var previews: some View {
        DummyView()
    }
}
