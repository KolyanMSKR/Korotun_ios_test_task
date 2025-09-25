import Foundation

enum PokemonEndpoint {
    case list(offset: Int, limit: Int)
    case detail(url: URL)
    
    func makeRequest() throws -> URLRequest {
        switch self {
        case let .list(offset, limit):
            let baseURL = "https://pokeapi.co/api/v2/pokemon"
            let urlString = baseURL + "?offset=\(offset)&limit=\(limit)"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            return request
            
        case let .detail(url):
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            return request
        }
    }
}
