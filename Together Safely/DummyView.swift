//
//  DummyView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/27/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts

struct DummyView: View {
    
    @ObservedObject private var contactStore: ContactStore = ContactStore()
    @State var firebaseService:FirebaseService = FirebaseService()
    
    var body: some View {
        VStack {
            HomeView(contactStore: contactStore).environmentObject(firebaseService)
//            AllContactsView(contactStore: contactStore)
        }
        .onAppear {
            self.contactStore.fetch()
            self.firebaseService.getUserData(byPhoneNumber: UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? "")
        }
    }
}

struct DummyView_Previews: PreviewProvider {
    static var previews: some View {
        DummyView()
    }
}
