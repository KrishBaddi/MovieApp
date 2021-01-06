//
//  MovieDetailViewModel.swift
//  Movie App
//
//  Created by Kaodim MacMini on 04/01/2021.
//

import Foundation
import RxCocoa
import RxSwift

public protocol MovieDetailViewModelInputs { }

public protocol MovieDetailViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var dataObservable: Driver<[MovieDetailSectionModel]> { get }
    var error: Driver<String> { get }

}
public protocol MovieDetailViewModelType {
    var inputs: MovieDetailViewModelInputs { get }
    var outputs: MovieDetailViewModelOutputs { get }
}

public class MovieDetailViewModel: MovieDetailViewModelType, MovieDetailViewModelInputs, MovieDetailViewModelOutputs {
    public var isLoading: Driver<Bool>
    public var movie: Movie

    public var error: Driver<String> = Driver.just("")
    public var dataObservable: Driver<[MovieDetailSectionModel]>

    public var inputs: MovieDetailViewModelInputs { return self }
    public var outputs: MovieDetailViewModelOutputs { return self }


    private var dataSource: MovieDataSource

    init(movie: Movie, dataSource: MovieDataSource) {
        self.movie = movie
        self.dataSource = dataSource
        let errorRelay = PublishRelay<String>()

        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()

        self.error = errorRelay.asDriver(onErrorJustReturn: "Error occured")

        self.dataObservable = dataSource.getMoviesDetails(movie.id)
            .flatMap({ (movie) -> Driver<[MovieDetailSectionModel]> in
                Driver.just([MovieDetailSectionModel.init(movie)])
            }) .asDriver(onErrorRecover: { (error) -> Driver<[MovieDetailSectionModel]> in
                errorRelay.accept((error as? ErrorResult)?.localizedDescription ?? error.localizedDescription)
                return Driver.just([MovieDetailSectionModel]())
            })
    }
}


public struct MovieDetailSectionModel {
    let title: String
    let genres: [Genre]
    let languageCode: LanguageCodes?
    let runtime: Int?
    let releaseDate: String
    let popularity: Double
    let overView: String
    let backdropPath: String?
    let posterPath: String?

    var language: String? {
        languageCode?.language
    }

    init(_ movie: Movie) {
        self.title = movie.title ?? ""
        self.genres = movie.genres
        self.languageCode = LanguageCodes.init(rawValue: movie.originalLanguage?.uppercased() ?? "")
        self.overView = movie.overview ?? ""
        self.popularity = movie.popularity
        self.backdropPath = movie.backdropPath
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.runtime = movie.runtime

    }

    func getMovieDuration() -> String {
        if let interval = runtime {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .full

            // Movie duration is assumed in minutes
            let formattedString = formatter.string(from: TimeInterval(interval * 60))!
            return formattedString
        }
        return ""
    }

    func generateGenres() -> String {
        var generText: String = ""
        self.genres.forEach { (item) in
            if item != self.genres.last {
                generText += "\(item.name) |"
            } else {
                generText += "\(item.name)"
            }
        }
        return generText
    }
}
