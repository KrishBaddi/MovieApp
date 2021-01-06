//
//  MovieViewModel.swift
//  Movie App
//
//  Created by Kaodim MacMini on 04/01/2021.
//

import Foundation
import RxCocoa
import RxSwift
import RxOptional

public protocol MovieViewModelInputs {
    func refresh()
    func tapped(indexRow: Int)
    func keyword(keyword: String)

    var loadPageTrigger: PublishRelay<Void> { get }
    var loadNextPageTrigger: PublishRelay<Void> { get }
}

public protocol MovieViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var moreLoading: Driver<Bool> { get }
    var elements: BehaviorRelay<[MovieViewViewModel]> { get }
    var selectedViewModel: Driver<MovieDetailViewModel> { get }
    var error: Driver<String> { get }
}

public protocol MovieViewModelType {
    var inputs: MovieViewModelInputs { get }
    var outputs: MovieViewModelOutputs { get }
}

public class MovieViewModel: MovieViewModelType, MovieViewModelInputs, MovieViewModelOutputs {
    public var error: Driver<String> = Driver.just("")

    private var keyword = ""
    private var pageIndex: Int = 1
    private var primaryDate = "2016-12-31"
    private let disposeBag = DisposeBag()

    // MARK: - Visible properties 👓
    let movie = BehaviorRelay<MovieViewViewModel?>(value: nil)

    public var isLoading: Driver<Bool>
    public var moreLoading: Driver<Bool>
    public var elements: BehaviorRelay<[MovieViewViewModel]>

    public var loadPageTrigger: PublishRelay<Void>
    public var loadNextPageTrigger: PublishRelay<Void>

    public var selectedViewModel: Driver<MovieDetailViewModel>
    public var inputs: MovieViewModelInputs { return self }
    public var outputs: MovieViewModelOutputs { return self }


    var totalPages = 0


    // MARK: - Constructor 🏗
    init(dataSource: MovieDataSourceProtocol) {

        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        let moreLoading = ActivityIndicator()
        self.selectedViewModel = Driver.empty()
        self.moreLoading = moreLoading.asDriver()

        self.loadPageTrigger = PublishRelay<Void>()
        self.loadNextPageTrigger = PublishRelay<Void>()

        let errorRelay = PublishRelay<String>()
        self.elements = BehaviorRelay<[MovieViewViewModel]>(value: [])


        // First time load date
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Observable<[MovieViewViewModel]> in
                if isLoading {
                    return Observable.empty()
                } else {
                    self.totalPages = 0
                    self.pageIndex = 1
                    self.primaryDate = "2020-01-01"
                    self.elements.accept([])
                    return dataSource.getMovies(self.primaryDate, .releaseDateDesc, page: self.pageIndex)
                        .observeOn(MainScheduler.instance)
                        .map({ (movieResponse) -> [Movie] in
                            self.pageIndex = movieResponse.page
                            self.totalPages = movieResponse.totalPages
                            return movieResponse.movies
                        })
                        .map({ (movie) -> [MovieViewViewModel] in
                            return movie.map({ MovieViewViewModel.init(movie: $0)})
                        })
                        .asDriver(onErrorRecover: { (error) -> Driver<[MovieViewViewModel]> in
                            errorRelay.accept((error as? ErrorResult)?.localizedDescription ?? error.localizedDescription)
                            return Driver.just([MovieViewViewModel]())
                        })
                        .trackActivity(Loading)
                }

        }

        self.error = errorRelay.asDriver(onErrorJustReturn: "Error occured")

        // Get more data by page
        let nextRequest = self.moreLoading.asObservable()
            .sample(self.loadNextPageTrigger)
            .flatMap { isLoading -> Observable<[MovieViewViewModel]> in
                if isLoading {
                    return Observable.empty()
                } else {
                    if (self.pageIndex + 1) != self.totalPages {
                        self.pageIndex = self.pageIndex + 1
                        return dataSource.getMovies(self.primaryDate, .releaseDateDesc, page: self.pageIndex)
                            .observeOn(MainScheduler.instance)
                            .map({ (movieResponse) -> [Movie] in
                                self.pageIndex = movieResponse.page
                                return movieResponse.movies
                            })
                            .map({ (movie) -> [MovieViewViewModel] in
                                return movie.map({ MovieViewViewModel.init(movie: $0)})
                            })
                            .trackActivity(moreLoading)
                    } else {
                        return Observable.empty()
                    }
                }
        }

        let request = Observable.of(loadRequest, nextRequest)
            .merge()
            .share(replay: 1)

        let response = request.flatMap { repositories -> Observable<[MovieViewViewModel]> in
            request
                .do(onError: { _error in
                    //self.error.onNext(_error)
                    errorRelay.accept((_error as? ErrorResult)?.localizedDescription ?? _error.localizedDescription)
                }).catchError({ error -> Observable<[MovieViewViewModel]> in
                    Observable.empty()
                })
        }.share(replay: 1)

        // combine data when get more data by paging
        Observable
            .combineLatest(request, response, elements.asObservable()) { request, response, elements in
                return self.pageIndex == 1 ? response : elements + response
            }
            .sample(response)
            .bind(to: elements)
            .disposed(by: disposeBag)

        //binding selected item
        self.selectedViewModel = self.movie.asDriver().filterNil().flatMapLatest { movie -> Driver<MovieDetailViewModel> in
            return Driver.just(MovieDetailViewModel(movieId: movie.id, dataSource: dataSource))
        }
    }

    public func refresh() {
        self.loadPageTrigger.accept({ }())
    }

    public func loadNextPage() {
        self.loadNextPageTrigger.accept({ }())
    }

    public func tapped(indexRow: Int) {
        let movie = self.elements.value[indexRow]
        self.movie.accept(movie)
    }

    public func keyword(keyword: String) {
        self.keyword = keyword
    }
}
