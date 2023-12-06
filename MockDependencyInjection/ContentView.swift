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
// 3. Cant't swap out service/dependencies

struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let bode: String
}


protocol DataServiceProtocol {
    func getData() -> AnyPublisher<[PostModel], Error>
}

class ProductionDataService: DataServiceProtocol {
    
    //static let instance = ProductionDataService() // Singletone
    //let url: URL(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func getData() -> AnyPublisher<[PostModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: [PostModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class MockDataService: DataServiceProtocol {
    let testData: [PostModel]
  
    
    init(testData: [PostModel]?) {
        self.testData = testData ?? [
            PostModel(userId: 1, id: 1, title: "Yes", bode: "No"),
            PostModel(userId: 1, id: 1, title: "White", bode: "Black"),
        ]
    }
    
    func getData() -> AnyPublisher<[PostModel], Error> {
        Just(testData)
            .tryMap({ $0 })
            .eraseToAnyPublisher()
    }
}

//class Dependencies {
//    let dataService: DataServiceProtocol
//
//    init(dataService: DataServiceProtocol) {
//        self.dataService = dataService
//    }
//}

class MockDependencyInjectionViewModel: ObservableObject {
    @Published var dataArray: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        loadPosts()
    }
    
    private func loadPosts() {
        dataService.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedPosts in
                self?.dataArray = returnedPosts
            }
            .store(in: &cancellables)
    }
}


struct ContentView: View {
    @StateObject private var vm: MockDependencyInjectionViewModel
    
    init(dataService: DataServiceProtocol /*Dependencies*/) {
        _vm = StateObject(wrappedValue: MockDependencyInjectionViewModel(dataService: dataService))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.dataArray) { post in
                    Text(post.title)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
//    let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    static let dataService = MockDataService(testData: [
    PostModel(userId: 123, id: 123, title: "Test", bode: "test")
    ])
    
    static var previews: some View {
        ContentView(dataService: dataService)
    }
}
