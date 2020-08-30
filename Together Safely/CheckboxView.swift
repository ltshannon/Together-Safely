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
    let arrayIndexs: [Int]
    let size: CGFloat
    let color: Color
    let textSize: Int
    let callback: (Int, Bool)->()
    
    init(
        id: Int,
        arrayIndexs: [Int],
        size: CGFloat = 10,
        color: Color = Color.black,
        textSize: Int = 14,
        callback: @escaping (Int, Bool)->()
        ) {
        self.id = id
        self.arrayIndexs = arrayIndexs
        self.size = size
        self.color = color
        self.textSize = textSize
        self.callback = callback
    }
    
    @State var isMarked:Bool = false
    
    var body: some View {
        Button(action:{
            print("Button touched for index: \(self.id)")
            self.isMarked = self.arrayIndexs.contains(self.id)
            self.isMarked.toggle()
            self.callback(self.id, self.isMarked)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(arrayIndexs.contains(id) ? "radioButtonOn" : "radioButtonOff")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
            .buttonStyle(BorderlessButtonStyle())
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
