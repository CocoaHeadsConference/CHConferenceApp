//
//  UpdateStore.swift
//  DesignCode
//
//  Created by Douglas Alexandre Barros Taquary on 23/09/19.
//  Copyright © 2019 Douglas Alexandre Barros Taquary. All rights reserved.
//

import SwiftUI
import Combine

class UpdateStore:ObservableObject {
    @Published var updates: [Update] = updateData
    
//    private lazy var backingStore: [Update] = {
//        guard let url = Bundle.nsbrazilConf.url(forResource: "LocalData", withExtension: "json") else {
//            fatalError("CocoaheadsConf demo.json from CocoaheadsConf resources")
//        }
//
//        do {
//            let data = try Data(contentsOf: url)
//            return try JSONDecoder().decode([Update].self, from: data)
//        } catch {
//            fatalError("Failed to load demo content: \(String(describing: error))")
//        }
//    }()
}


let updateData = [
    Update(image: "Illustration1", title: "SwiftUI", text: "Learn how to build custom views and controls in SwiftUI with advanced composition, layout, graphics, and animation. See a demo of a high performance, animatable control and watch it made step by step in code. Gain a deeper understanding of the layout system of SwiftUI.", date: "JUN 26"),
    Update(image: "Illustration2", title: "Framer X", text: "Learn how to build custom views and controls in SwiftUI with advanced composition, layout, graphics, and animation. See a demo of a high performance, animatable control and watch it made step by step in code. Gain a deeper understanding of the layout system of SwiftUI.", date: "JUN 11"),
    Update(image: "Illustration3", title: "CSS Layout", text: "Learn how to combine CSS Grid, Flexbox, animations and responsive design to create a beautiful prototype in CodePen.", date: "MAY 26"),
    Update(image: "Illustration4", title: "React Native Part 2", text: "Learn how to implement gestures, Lottie animations and Firebase login.", date: "MAY 15"),
    Update(image: "Certificate1", title: "Unity", text: "Unity course teaching basics, C#, assets, level design and gameplay", date: "MAR 19"),
    Update(image: "Certificate2", title: "React Native for Designers", text: "Build your own iOS and Android app with custom animations, Redux and API data.", date: "FEB 14"),
    Update(image: "Certificate3", title: "Vue.js", text: "Make a dashboard web-app with a complete login system, dark mode, and animated charts for your data.", date: "JAN 23")
]
