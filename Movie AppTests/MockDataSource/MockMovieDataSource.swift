//
//  MockMovieDataSource.swift
//  Movie AppTests
//
//  Created by Kaodim MacMini on 06/01/2021.
//

import Foundation
import RxCocoa
import RxSwift
import RxOptional

@testable import Movie_App

public class MockMovieDataSource: MovieDataSourceProtocol {

    private var fakeMovieResponse: MovieResponse?
    private var fakeMovie: Movie?

    /// A new init method allowing to inject fake data
    init(fakeMovieResponse: MovieResponse) {
        self.fakeMovieResponse = fakeMovieResponse
    }

    init(fakeMovie: Movie) {
        self.fakeMovie = fakeMovie
    }

    public func getMovies(_ primaryDate: String, _ sortBy: SortMovies, page: Int) -> Observable<MovieResponse> {
        return Observable.just(self.fakeMovieResponse!)
    }

    public func getMoviesDetails(_ movieId: Int) -> Observable<Movie> {
        return Observable.just(self.fakeMovie!)
    }
}

public class MockMovieDataSourceError: MovieDataSourceProtocol {
    public func getMovies(_ primaryDate: String, _ sortBy: SortMovies, page: Int) -> Observable<MovieResponse> {
        Observable.error(ErrorResult.network(string: "Server error"))
    }

    public func getMoviesDetails(_ movieId: Int) -> Observable<Movie> {
        Observable.error(ErrorResult.network(string: "Server error"))
    }
}
