//
//  MovieDetailViewModel.swift
//  Movie App
//
//  Created by Kaodim MacMini on 04/01/2021.
//

import Foundation
import RxCocoa
import RxSwift

public protocol MovieDetailViewModelInputs {
}

public protocol MovieDetailViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var synopsis: String { get }
    var genres: String { get }
    var language: String { get }
    var duration: String { get }
    var dataObservable: Driver<MovieDetailCellModel> { get }
}

public protocol MovieDetailViewModelType {
    var inputs: MovieDetailViewModelInputs { get }
    var outputs: MovieDetailViewModelOutputs { get }
}

public class MovieDetailViewModel: MovieDetailViewModelType, MovieDetailViewModelInputs, MovieDetailViewModelOutputs {
    public var isLoading: Driver<Bool>
    public var movie: Movie

    public var synopsis: String { return "" }
    public var genres: String { return "movie.genreIDS" }
    public var language: String { return movie.originalLanguage ?? "" }
    public var duration: String { return movie.releaseDate ?? "" }
    public var dataObservable: Driver<MovieDetailCellModel>

    public var inputs: MovieDetailViewModelInputs { return self }
    public var outputs: MovieDetailViewModelOutputs { return self }


    private var dataSource: MovieDataSource

    init(movie: Movie, dataSource: MovieDataSource) {
        self.movie = movie
        self.dataSource = dataSource


        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()

        self.dataObservable = dataSource.getMoviesDetails(movie.id)
            .asDriver(onErrorJustReturn: movie)
            .flatMap({ (movie) -> Driver<MovieDetailCellModel> in
                Driver.just(MovieDetailCellModel(title: movie.title, genres: movie.something, synopsis: movie.overview, language: movie.originalLanguage, duration: movie.runtime))
            })
    }
}


public struct MovieDetailCellModel {
    let title: String?
    let genres: [Genre]
    let synopsis: String?
    let language: String?
    let duration: Int?
}
