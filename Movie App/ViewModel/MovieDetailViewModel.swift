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

// Values
public protocol MovieDetailViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var dataObservable: Driver<[MovieDetailViewViewModel]> { get }
    var error: Driver<String> { get }

}
public protocol MovieDetailViewModelType {
    var inputs: MovieDetailViewModelInputs { get }
    var outputs: MovieDetailViewModelOutputs { get }
}

public class MovieDetailViewModel: MovieDetailViewModelType, MovieDetailViewModelInputs, MovieDetailViewModelOutputs {
    public var isLoading: Driver<Bool>

    public var error: Driver<String> = Driver.just("")
    public var dataObservable: Driver<[MovieDetailViewViewModel]>

    public var inputs: MovieDetailViewModelInputs { return self }
    public var outputs: MovieDetailViewModelOutputs { return self }


    private var dataSource: MovieDataSourceProtocol

    init(movieId: Int, dataSource: MovieDataSourceProtocol) {
        self.dataSource = dataSource
        let errorRelay = PublishRelay<String>()

        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()

        self.error = errorRelay.asDriver(onErrorJustReturn: "Error occurred")

        self.dataObservable = dataSource.getMoviesDetails(movieId)
            .flatMap({ (movie) -> Single<[MovieDetailViewViewModel]> in
                Single.just([MovieDetailViewViewModel.init(movie)])
            }).asDriver(onErrorRecover: { (error) -> Driver<[MovieDetailViewViewModel]> in
                errorRelay.accept((error as? ErrorResult)?.localizedDescription ?? error.localizedDescription)
                return Driver.just([MovieDetailViewViewModel]())
            })
    }
}
