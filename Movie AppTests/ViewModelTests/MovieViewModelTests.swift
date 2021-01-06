//
//  MovieViewModelTests.swift
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

class MovieViewModelTests: XCTestCase {

    private var disposeBag = DisposeBag()
    private var dataSource: MovieDataSourceProtocol!
    private var viewModel: MovieViewModel!

    func testFetchWithSuccess() {

        // Giving a dataSource with mocked movie response
        self.dataSource = MockMovieDataSource.init(fakeMovieResponse: mockMovieResponse)
        self.viewModel = MovieViewModel(dataSource: dataSource)

        // mock a reload
        self.viewModel.refresh()

        // Bind the result
        let expectMovieResults = expectation(description: "Fetech the movie list")
        self.viewModel.outputs.elements.asDriver()
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
        self.viewModel = MovieViewModel(dataSource: dataSource)

        let expectMovieFailedResults = expectation(description: "Fetch movie list contains network error")

        // mock a reload
        self.viewModel.refresh()

        // Bind the result
        self.viewModel.outputs.elements.asDriver()
            .drive { (result) in
                // Verify the results
                let hasResults = !result.isEmpty
                XCTAssertFalse(hasResults)
                expectMovieFailedResults.fulfill()

            }.disposed(by: disposeBag)

        wait(for: [expectMovieFailedResults], timeout: 0.1)
    }


    func testFetchWithNextPageSuccess() {

        // Giving a dataSource with mocked movie response
        self.dataSource = MockMovieDataSource.init(fakeMovieResponse: mockMovieResponse)
        self.viewModel = MovieViewModel(dataSource: dataSource)

        let expectMovieResults = expectation(description: "Fetech the movie list")

        // mock a reload
        self.viewModel.refresh()
        self.viewModel.loadNextPage()

        // Bind the result
        self.viewModel.outputs.elements.asDriver()
            .drive { (result) in

                // Verify the results
                let hasResults = !result.isEmpty
                XCTAssertTrue(hasResults)
                expectMovieResults.fulfill()

            }.disposed(by: disposeBag)

        wait(for: [expectMovieResults], timeout: 0.1)
    }

}
