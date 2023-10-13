//
//  ContentView.swift
//  pokeDexSUI
//
//  Created by Muhammad Fahmi on 13/10/23.
//

import SwiftUI

struct Response: Codable{
    var results: [Result]
}

struct Result: Codable{
    //    var id: Int
    let name: String
    let url: String
    
    //    var types: String
}

struct ContentView: View {
    @State private var results = [Result]()
    @State private var linkAPI = "https://pokeapi.co/api/v2/pokemon/?offset=0&limit=20"
    @State private var offsetLink = 0
    let gabut: Result? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Previous") {
                        linkAPI = "https://pokeapi.co/api/v2/pokemon/?offset=\(offsetLink <= 0 ? 0 : offsetLink-20)&limit=20"
                        (offsetLink <= 0) ? (offsetLink = 0) : (offsetLink -= 20)
                        Task{
                            await loadData()
                        }
                    }
                    .disabled(offsetLink <= 0)
                    Spacer()
                    Button("Next") {
                        offsetLink += 20
                        linkAPI = "https://pokeapi.co/api/v2/pokemon/?offset=\(offsetLink)&limit=20"
                        Task{
                            await loadData()
                        }
                    }
                }
                .padding()
                ScrollView{
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]){
                        ForEach(results, id: \.url) { item in
                            NavigationLink{
                                VStack{
                                    AsyncImage(url: URL(string: "https://img.pokemondb.net/artwork/" + (item.name) + ".jpg")){ poke in
                                        poke
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    Text(item.name)
                                        .font(.largeTitle)
                                    Text("Source: "+item.url)
                                        .font(.caption)
                                    Spacer()
                                }
                            } label: {
                                VStack(alignment: .center) {
                                    Spacer()
                                    AsyncImage(url: URL(string: "https://img.pokemondb.net/artwork/" + (item.name) + ".jpg"), scale: 3){ image in
                                        image
                                    } placeholder: {
                                        ProgressView()
                                            .padding()
                                    }
                                    Spacer()
                                    Divider()
                                        .padding(.horizontal)
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .task {
                await loadData()
            }
        }
    }
    
    func loadData() async {
        guard let url = URL(string: linkAPI) else {
            print("Invalid URL")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                    results = decodedResponse.results
                }
            } catch {
                print("Invalid data")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
