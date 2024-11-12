//
//  GarageBandTutorial.swift
//  Rings
//
//  Created by Brody on 11/12/24.
//

import SwiftUI

struct GarageBandTutorial: View {
    var body: some View {
        ZStack{
            AppColors.backgroundColor.ignoresSafeArea()
            ScrollView{
                VStack(alignment: .leading){
                    Spacer()
                        .frame(height: 20)
                    Text("Export Ringtones Through GarageBand")
                        .font(.system(size: 28))
                        .multilineTextAlignment(.leading)
                        .bold()
                    Spacer()
                        .frame(height: 20)
                    VStack{
                        
                        Text("1: ")
                        + Text("Save")
                            .bold()
                            .foregroundStyle(AppColors.secondary)
                        + Text(" the ")
                        + Text("GarageBand")
                        + Text(" file in the desired location.")
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack{
                        Text("2:")
                        + Text(" Long Press")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                        + Text(" the project file found in the desired location and")
                        + Text(" Press Share")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack{
                        Text("3: ")
                        + Text("Press")
                        + Text(" RingTones")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack{
                        Text("4: ")
                        + Text("Click ")
                        + Text("Export")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                        + Text(" to successfuly complete the ringtone! Now you can use the ringtone found in ")
                        + Text("Settings -> Sounds & Haptics -> Ringtones")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                    }
                }
            }
            
        }
    }
}

#Preview {
    GarageBandTutorial()
}
