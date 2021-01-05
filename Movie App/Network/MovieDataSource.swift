//
//  MovieDataSource.swift
//  Movie App
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import Foundation
import RxSwift

public enum APIError: Error {
    case incorrectArguments(message: String)
    case missingArgument(message: String)
    case invalidURL(message: String)

    var message: String {
        switch self {
        case .incorrectArguments(let message): return message
        case .missingArgument(let message): return message
        case .invalidURL(let message): return message
        }
    }
}

enum APIConstants: String {
    case domain = "http://api.themoviedb.org/3/"
    case requestDiscover = "discover/"
    case requestMovies = "movie"
}

enum SortMovies: String {
    case releaseDateDesc = "release_date.desc"
}

protocol MovieDataSourceProtocol {
    func getMovies(_ primaryDate: String, _ sortBy: SortMovies, page: Int) -> Observable<MovieResponse>
}

class MovieDataSource: MovieDataSourceProtocol {
    func getMoviesArray(_ primaryDate: String, _ sortBy: SortMovies, page: Int) -> Observable<[Movie]> {
        let data = self.getMovies(primaryDate, sortBy, page: page)
            .map { (result) -> [Movie] in
                return result.movies
            }
        return data
    }

    func getMoviesDetails(_ movieId: Int) -> Observable<Movie> {
        guard let url = URL(string: APIConstants.domain.rawValue  +  APIConstants.requestMovies.rawValue + "/\(movieId)") else { return Observable.error(APIError.invalidURL(message: "Invalid URL request")) }

        let apiRequest = RestManager()
        return send(url: url, apiRequest: apiRequest)
    }

    func getMovies(_ primaryDate: String, _ sortBy: SortMovies, page: Int) -> Observable<MovieResponse> {

        //http://api.themoviedb.org/3/discover/movie?api_key=328c283cd27bd1877d9080ccb1604c91&primary_release_date.lte=2016-12-31&sort_by=release_date.desc&page=1
        guard let url = URL(string: APIConstants.domain.rawValue + APIConstants.requestDiscover.rawValue + APIConstants.requestMovies.rawValue) else { return Observable.error(APIError.invalidURL(message: "Invalid URL request")) }

        let apiRequest = RestManager()
        apiRequest.urlQueryParameters.add(value: primaryDate, forKey: "primary_release_date.lte")
        apiRequest.urlQueryParameters.add(value: sortBy.rawValue, forKey: "sort_by")
        apiRequest.urlQueryParameters.add(value: String(page), forKey: "page")
        
        return send(url: url, apiRequest: apiRequest)
    }


    func send<T: Codable>(url: URL, apiRequest: RestManager) -> Observable<T> {
        return Observable<T>.create { observer in

            apiRequest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
                if let data = results.data {
                    do {
                        let model: T = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(model)
                    } catch let error {
                        observer.onError(error)
                    }
                }

                print("\n\nResponse HTTP Headers:\n")

                if let response = results.response {
                    for (key, value) in response.headers.allValues() {
                        print(key, value)
                    }
                }
                observer.onCompleted()
            }

            return Disposables.create {
                apiRequest.cancel()
            }
        }
    }
}
