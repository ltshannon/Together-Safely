//
//  ContentView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/19/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var dataController: DataController
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @Environment(\.managedObjectContext) var managedObjectContext
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
        UINavigationBar.appearance().tintColor = .white
        
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some View {
        GeometryReader { metrics in
            NavigationView {
                if self.status {
                    DummyView()
                        .environmentObject(dataController)
                } else {
//                    StartLoginView().environmentObject(LocationFetcher())
                    StartLoginView()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

