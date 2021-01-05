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
    var elements: BehaviorRelay<[Movie]> { get }
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
    let movie = BehaviorRelay<Movie?>(value: nil)

    public var isLoading: Driver<Bool>
    public var moreLoading: Driver<Bool>
    public var elements: BehaviorRelay<[Movie]>

    public var loadPageTrigger: PublishRelay<Void>
    public var loadNextPageTrigger: PublishRelay<Void>

    public var selectedViewModel: Driver<MovieDetailViewModel>
    public var inputs: MovieViewModelInputs { return self }
    public var outputs: MovieViewModelOutputs { return self }

    // MARK: - Constructor 🏗
    init(dataSource: MovieDataSource) {

        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        let moreLoading = ActivityIndicator()
        self.selectedViewModel = Driver.empty()
        self.moreLoading = moreLoading.asDriver()

        self.loadPageTrigger = PublishRelay<Void>()
        self.loadNextPageTrigger = PublishRelay<Void>()

        let errorRelay = PublishRelay<String>()
        self.elements = BehaviorRelay<[Movie]>(value: [])

        // First time load date
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Observable<[Movie]> in
                if isLoading {
                    return Observable.empty()
                } else {
                    self.pageIndex = 1
                    self.primaryDate = "2020-01-01"
                    self.elements.accept([])
                    return dataSource.getMoviesArray(self.primaryDate, .releaseDateDesc, page: self.pageIndex)
                        .observeOn(MainScheduler.instance)
                        .asDriver(onErrorRecover: { (error) -> Driver<[Movie]> in
                            errorRelay.accept((error as? ErrorResult)?.localizedDescription ?? error.localizedDescription)
                            return Driver.just([Movie]())
                        })
                        .trackActivity(Loading)
                }

        }

        self.error = errorRelay.asDriver(onErrorJustReturn: "Error occured")

        // Get more data by page
        let nextRequest = self.moreLoading.asObservable()
            .sample(self.loadNextPageTrigger)
            .flatMap { isLoading -> Observable<[Movie]> in
                if isLoading {
                    return Observable.empty()
                } else {
                    self.pageIndex = self.pageIndex + 1
                    return dataSource.getMoviesArray(self.primaryDate, .releaseDateDesc, page: self.pageIndex)
                        .trackActivity(moreLoading)
                }
        }

        let request = Observable.of(loadRequest, nextRequest)
            .merge()
            .share(replay: 1)

        let response = request.flatMap { repositories -> Observable<[Movie]> in
            request
                .do(onError: { _error in
                    //self.error.onNext(_error)
                    errorRelay.accept((_error as? ErrorResult)?.localizedDescription ?? _error.localizedDescription)
                }).catchError({ error -> Observable<[Movie]> in
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
            return Driver.just(MovieDetailViewModel(movie: movie, dataSource: dataSource))
        }
    }

    public func refresh() {
        self.loadPageTrigger.accept({}())
    }

    public func tapped(indexRow: Int) {
        let movie = self.elements.value[indexRow]
        self.movie.accept(movie)
    }

    public func keyword(keyword: String) {
        self.keyword = keyword
    }
}
