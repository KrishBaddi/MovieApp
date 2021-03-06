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
    func getMovies(_ primaryDate: String, _ sortBy: SortMovies, page: Int) -> Single<MovieResponse>
    func getMoviesDetails(_ movieId: Int) -> Single<Movie>
}

class MovieDataSource: MovieDataSourceProtocol {

    func getMoviesDetails(_ movieId: Int) -> Single<Movie> {
        guard let url = URL(string: APIConstants.domain.rawValue  +  APIConstants.requestMovies.rawValue + "/\(movieId)") else { return Single.error(APIError.invalidURL(message: "Invalid URL request")) }

        let apiRequest = RestManager()
        return send(url: url, apiRequest: apiRequest)
    }

    func getMovies(_ primaryDate: String, _ sortBy: SortMovies, page: Int) -> Single<MovieResponse> {

        //http://api.themoviedb.org/3/discover/movie?api_key=328c283cd27bd1877d9080ccb1604c91&primary_release_date.lte=2016-12-31&sort_by=release_date.desc&page=1
        guard let url = URL(string: APIConstants.domain.rawValue + APIConstants.requestDiscover.rawValue + APIConstants.requestMovies.rawValue) else { return Single.error(APIError.invalidURL(message: "Invalid URL request")) }

        let apiRequest = RestManager()
        apiRequest.urlQueryParameters.add(value: primaryDate, forKey: "primary_release_date.lte")
        apiRequest.urlQueryParameters.add(value: sortBy.rawValue, forKey: "sort_by")
        apiRequest.urlQueryParameters.add(value: String(page), forKey: "page")
        
        return send(url: url, apiRequest: apiRequest)
    }


    func send<T: Codable>(url: URL, apiRequest: RestManager) -> Single<T> {
        return Single<T>.create { single in
            apiRequest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
                if let data = results.data {
                    do {
                        let model: T = try JSONDecoder().decode(T.self, from: data)
                        single(.success(model))
                    } catch let error {
                        single(.error(error))
                    }
                }
            }
            return Disposables.create {
                apiRequest.cancel()
            }
        }
    }
}
