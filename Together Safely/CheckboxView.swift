//
//  CheckboxView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/4/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct CheckboxView: View {
    let id: Int
    let label: String
    let size: CGFloat
    let color: Color
    let textSize: Int
    let callback: (Int, Bool)->()
    
    init(
        id: Int,
        label:String,
        size: CGFloat = 10,
        color: Color = Color.black,
        textSize: Int = 14,
        callback: @escaping (Int, Bool)->()
        ) {
        self.id = id
        self.label = label
        self.size = size
        self.color = color
        self.textSize = textSize
        self.callback = callback
    }
    
    @State var isMarked:Bool = false
    
    var body: some View {
        Button(action:{
            self.isMarked.toggle()
            self.callback(self.id, self.isMarked)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(self.isMarked ? "radioButtonOn" : "radioButtonOff")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.trailing, 20)
    }
}

/*
struct CheckboxView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxView()
    }
}
*/
