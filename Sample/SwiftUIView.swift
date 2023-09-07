//
//  SwiftUIView.swift
//  
//
//  Created by Tristan Chay on 7/9/23.
//

import SwiftUI

struct SwiftUIView: View {
    @Persistence("test.txt") var document
    var body: some View {
        Text(document)
    }
}

#Preview {
    SwiftUIView()
}
