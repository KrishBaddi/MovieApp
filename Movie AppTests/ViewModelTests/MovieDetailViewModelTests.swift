//
//  MovieDetailViewModelTests.swift
//  Movie AppTests
//
//  Created by Kaodim MacMini on 06/01/2021.
//

import XCTest
import RxCocoa
import RxSwift
import RxOptional
import RxDataSources

@testable import Movie_App

class MovieDetailViewModelTests: XCTestCase {

    private var disposeBag = DisposeBag()
    private var dataSource: MovieDataSourceProtocol!
    private var viewModel: MovieDetailViewModel!

    func testFetchMovieDetailsWithSuccess() {

        // Giving a dataSource with faked movie details
        self.dataSource = MockMovieDataSource.init(fakeMovie: mockMovieDetails)
        self.viewModel = MovieDetailViewModel(movieId: (mockMovie?.id)!, dataSource: dataSource)

        let expectMovieResults = expectation(description: "Fetech the movie details")

        // Bind the result
        self.viewModel.outputs.dataObservable.asDriver()
            .drive { (result) in
                // Verify the results
                let hasResults = !result.isEmpty
                XCTAssertTrue(hasResults)
                expectMovieResults.fulfill()

            }.disposed(by: disposeBag)
        wait(for: [expectMovieResults], timeout: 0.1)

    }

    func testFetchWithError() {
        // Create fake failed data source
        self.dataSource = MockMovieDataSourceError()
        self.viewModel = MovieDetailViewModel(movieId: 0, dataSource: dataSource)

        let expectMovieFailedResults = expectation(description: "Fetch movie details contains network error")

        // Bind the result
        self.viewModel.outputs.dataObservable.asDriver()
            .drive { (result) in
                // Verify the results
                let hasResults = !result.isEmpty
                XCTAssertFalse(hasResults)
                expectMovieFailedResults.fulfill()

            }.disposed(by: disposeBag)
        wait(for: [expectMovieFailedResults], timeout: 0.1)
    }

}
