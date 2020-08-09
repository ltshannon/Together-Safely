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
    
    var body: some View {

        VStack {
            NavigationView {
                if status {
                    DummyView()
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

