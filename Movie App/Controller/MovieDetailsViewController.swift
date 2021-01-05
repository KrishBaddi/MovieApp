//
//  MovieDetailsViewController.swift
//  Movie App
//
//  Created by Kaodim MacMini on 04/01/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol MovieDetailsViewControllerFactory {
    func makeViewController() -> MovieDetailsViewController
    func makeMovieDetailViewModel() -> MovieDetailViewModel
    func makeMovieDataSource() -> MovieDataSource
}

open class MovieDetailsDependencyContainer: MovieDetailsViewControllerFactory {

    var viewModel: MovieDetailViewModel

    init(viewModel:MovieDetailViewModel ) {
        self.viewModel = viewModel
    }
    func makeViewController() -> MovieDetailsViewController {
        MovieDetailsViewController(factory: self)
    }

    func makeMovieDetailViewModel() -> MovieDetailViewModel {
        viewModel
    }

    func makeMovieDataSource() -> MovieDataSource {
        MovieDataSource()
    }
}


class MovieDetailsViewController: UIViewController {

    // Here we use protocol composition to create a Factory type that includes
    // all the factory protocols that this view controller needs.
    typealias Factory = MovieDetailsViewControllerFactory

    lazy var viewModel = factory.makeMovieDetailViewModel()
    private let factory: Factory

    private var tableView: UITableView!
    private let disposeBag = DisposeBag()

    init(factory: Factory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deallocated...")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        bindRx()
    }


    func bindRx() {
        viewModel.outputs.dataObservable.drive(onNext: { data in
            self.tableView.reloadData()
        })
    }

    func configureTableView() {
        self.tableView = UITableView(frame: UIScreen.main.bounds)
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "Cell")

        self.view = self.tableView
        self.tableView.tableFooterView = UIView()
    }
}

extension MovieDetailsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MovieTableCell
        return cell
    }
}
