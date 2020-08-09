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
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        GeometryReader { metrics in
            NavigationView {
                if self.status {
                    DummyView()
                } else {
                    StartLoginView().environmentObject(LocationFetcher())
                }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

