//
//  SwiftUIView.swift
//  
//
//  Created by Nantanat Thongthep on 19/4/2566 BE.
//

import SwiftUI

struct Puzzle: Identifiable {
    var id: String = UUID().uuidString
    var imageName: String
    var title: String
    var describe: String
    var answer: String
    var choice: String = "🍖🌿💩🥤🧻🥡⚙️📄🫙🧪🔋🔪"
    var color: Color
    
    var letters: [Letter] = []
}

struct Letter: Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var value: String
    var padding: CGFloat = 10
    var textSize: CGFloat = .zero
    var fontSize: CGFloat = 18
}

var puzzles: [Puzzle] = [
    Puzzle(imageName: "green-bin", title: "Green Bin", describe: "It is for compostable waste such as garden and food waste.", answer: "🍖🌿💩", color: .green),
    Puzzle(imageName: "yellow-bin", title: "Yellow Bin", describe: "It is for recycle waste such as glass, metal, paper and some plastics.", answer: "⚙️📄🫙", color: .yellow),
    Puzzle(imageName: "blue-bin", title: "Blue Bin", describe: "It is for general waste that cannot be recycled, such as plastic bags.", answer: "🥤🧻🥡", color: .blue),
    Puzzle(imageName: "red-bin", title: "Red Bin", describe: "It is for hazardous waste, dangerous objects, chemicals, and electronic items.", answer: "🧪🔋🔪", color: .red)
]
