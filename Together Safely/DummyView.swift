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
    @StateObject var firebaseService:FirebaseService = FirebaseService()
    @StateObject var locationFetcher: LocationFetcher = LocationFetcher()
    
    var body: some View {
        VStack {
            HomeView().environmentObject(firebaseService).padding(.top, 10)
        }
        .onAppear {
            self.firebaseService.getServerData(byPhoneNumber: UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? "")
        }
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("Moving back to the foreground!")
            self.locationFetcher.start()
        }
    }
}

struct DummyView_Previews: PreviewProvider {
    static var previews: some View {
        DummyView()
    }
}
