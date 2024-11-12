//
//  AddRingtoneView.swift
//  Rings
//
//  Created by Brody on 11/12/24.
//

import SwiftUI

struct AddRingtoneView: View {
    var body: some View {
        ZStack{
            Circle()
                .frame(width:20,height:20)
                .foregroundColor(Color.gray.opacity(0.8))
            Image(systemName: "iphone.gen2")
                .resizable()
                .frame(width: 8, height: 11)
                .foregroundColor(Color.white)
                .padding(.trailing, 4)
                
            Image(systemName: "plus")
                .resizable()
                .frame(width: 6, height: 6)
                .padding(.leading, 12)
                .padding(.bottom, 0)
                .foregroundStyle(Color.white)
                
                
                
                
        }
    }
}

#Preview {
    AddRingtoneView()
}
