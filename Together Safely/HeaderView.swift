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
            Spacer()
            Image("homeTop")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 35)
/*
            Text("together")
                .font(Font.custom("Avenir-Heavy", size: 28))
                .foregroundColor(.white)
//                .padding(.trailing, 20)
//                .background(Color.blue)
 */
            Spacer()
        }
//        .background(Color.black)
    .padding(0)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
