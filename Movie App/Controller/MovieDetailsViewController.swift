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
import WebKit

protocol MovieDetailsViewControllerFactory {
    func makeViewController() -> MovieDetailsViewController
    func makeMovieDetailViewModel() -> MovieDetailViewModel
    func makeMovieDataSource() -> MovieDataSource
}

open class MovieDetailsDependencyContainer: MovieDetailsViewControllerFactory {

    var viewModel: MovieDetailViewModel

    init(viewModel: MovieDetailViewModel) {
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
    var datasource: [MovieDetailSectionModel] = []
    let buttonClicked = PublishSubject<String>()
    private let factory: Factory
    var webView: WKWebView!

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
        setupErrorBinding()
    }


    func bindRx() {
        viewModel.outputs.dataObservable.drive(onNext: { data in
            self.datasource = data
            self.tableView.reloadData()
        }).disposed(by: disposeBag)

        buttonClicked.subscribe { [weak self] (string) in
            self?.bookTapped()
        }.disposed(by: disposeBag)
    }

    private func setupErrorBinding() {
        viewModel.outputs.error.asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] error in
                guard let self = self else { return }
                self.showAlert(alertMessage: error.description)
            }).disposed(by: disposeBag)
    }

    func configureTableView() {
        self.tableView = UITableView(frame: UIScreen.main.bounds)
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.view = self.tableView
        self.tableView.tableFooterView = UIView()
    }

    func bookTapped() {
        self.openUrl(urlStr: "https://www.cathaycineplexes.com.sg")
    }

    private func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MovieDetailsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MovieTableCell
        let movieDetails = self.datasource[indexPath.row]
        cell.bindDetailsViewModel(movieDetails)
        cell.bindViewModel(viewModel: movieDetails, buttonClicked: buttonClicked)
        return cell
    }
}
