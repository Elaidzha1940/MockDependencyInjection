//  /*
//
//  Project: MockDependencyInjection
//  File: ContentView.swift
//  Created by: Elaidzha Shchukin
//  Date: 06.12.2023
//
//  */

import SwiftUI
import Combine


// Problems with Singletons:
//
// 1. Singleton's are Global.
// 2. Cant't customize the init.
// 3. Cant't swap out service.

struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let bode: String
}

class ProductionDataService {
    
    let url: URL
    init(url: URL) {
        self.url = url
    }
    
    func getData() -> AnyPublisher<[PostModel], Error>
    URLSession.shared.dataTaskPublisher(for: url)
        .map({ $.0data })
        .decode(type: [PostModel].self, decoder: JSONDecoder())
        .receive(on: dispatchQueue.main)
        .eraseToAnyPublisher()
}



struct MockDependencyInjection: View {
    @StateObject private var vm: MockDependencyInjection
    
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

struct ContentView: View {
    var body: some View {
        
        ScrollView {
            VStack {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
