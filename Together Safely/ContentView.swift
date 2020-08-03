//
//  ContentView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/19/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @State var nameEntered = UserDefaults.standard.value(forKey: "username") as? String ?? ""
    
    var body: some View {

        VStack {
            NavigationView {
                if status && nameEntered.count > 0 {
                    DummyView()
                } else if status && nameEntered.count == 0 {
                    SetNameView()
                } else {
                    StartLoginView().environmentObject(LocationFetcher())
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

