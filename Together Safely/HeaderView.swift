//
//  HeaderView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/31/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    static let width: Float = 131.0
    var body: some View {
        Image("header-logo")
            .renderingMode(.template)
            .foregroundColor(.white)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
