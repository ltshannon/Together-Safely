//
//  HeaderView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/31/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Image("appIcon")
                .resizable()
                .frame(width: 50, height: 50)
            Text("together")
                .font(Font.custom("Avenir-Heavy", size: 25))
                .foregroundColor(.white)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
