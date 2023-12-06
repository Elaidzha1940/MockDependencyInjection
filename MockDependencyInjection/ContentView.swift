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
    
    func getData() -> AnyPublisher<[PostModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: [PostModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    class MockDependencyInjectionViewModel: ObservableObject {
        @Published var dataArray: [PostModel] = []
        var cancellables = Set<AnyCancellable>()
        let dataService: ProductionDataService
        
        init(dataService: ProductionDataService) {
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
        
        init(dataService: ProductionDataService) {
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
}

struct ContentView_Previews: PreviewProvider {
    let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    
    static var previews: some View {
        ContentView(dataService: dataService)
    }
}
