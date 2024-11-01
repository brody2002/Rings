//
//  SwiftDataExample.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import Foundation
import SwiftUI
import SwiftData






@Model
class Dog{
    var name: String
    init(name: String){
        self.name = name
    }
}

struct testView: View{
    @Query var dogList: [Dog] = [Dog]()
    @Environment(\.modelContext) var modelContext
    
    func addDog(){
        modelContext.insert(Dog(name: "DOG 1"))
        try? modelContext.save()
        
        print(dogList)
    }
    
    var body: some View{
        VStack{
            ForEach(dogList, id: \.name){ dog in
                Text(dog.name)
            }
            
            Spacer()
                .frame(height: 100)
            
            Button(
                action: {addDog()},
                label: {
                    Image(systemName: "globe")
                }
            )
        }
        
    }
}

#Preview {
    
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true) // Correctly initialize the model configuration
        let container = try ModelContainer(for: Dog.self, configurations: config)
        
        return testView()
            .modelContainer(container) // Attach the model container
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
    
}

