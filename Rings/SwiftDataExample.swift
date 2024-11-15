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
class Dog {
    var name: String
    init(name: String) {
        self.name = name
    }
}

func customSort(_ lhs: String, _ rhs: String) -> Bool {
    // Check if one string is a prefix of the other
    if lhs.hasPrefix(rhs) || rhs.hasPrefix(lhs) {
        return lhs.count > rhs.count // Longer string goes first
    }
    
    // Fall back to natural sorting for non-prefix strings
    return lhs.localizedStandardCompare(rhs) == .orderedAscending
}

struct testView: View {
    @Query var dogList: [Dog]
    @Environment(\.modelContext) var modelContext

    // Custom sorted list using the custom sort function
    var sortedDogList: [Dog] {
        dogList.sorted { customSort($0.name, $1.name) }
    }

    func addDog() {
        modelContext.insert(Dog(name: "Glo slice1"))
        modelContext.insert(Dog(name: "Glo"))
        modelContext.insert(Dog(name: "Sunflower"))
        modelContext.insert(Dog(name: "sure shot slice2"))
        modelContext.insert(Dog(name: "sure shot_slice2"))
        modelContext.insert(Dog(name: "sure shot"))
        try? modelContext.save()
    }

    var body: some View {
        VStack {
            ForEach(sortedDogList, id: \.name) { dog in
                Text(dog.name)
            }
            
            Spacer()
                .frame(height: 100)
            
            Button(action: { addDog() }) {
                Image(systemName: "globe")
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Dog.self, configurations: config)
        
        return testView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}





