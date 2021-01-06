//
//  MovieListViewController.swift
//  Movie App
//
//  Created by Kaodim MacMini on 04/01/2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


// Dependency Injection techniques with “Abstract Factory” pattern
protocol MovieListViewControllerFactory {
    func makeViewController() -> MovieListViewController
    func makeMovieViewModel() -> MovieViewModel
    func makeMovieDataSource() -> MovieDataSource
}

open class MovieListDependencyContainer: MovieListViewControllerFactory {
    // Instantiate View Controller
    func makeViewController() -> MovieListViewController {
        MovieListViewController(factory: self)
    }

    // Instantiate ViewModel
    func makeMovieViewModel() -> MovieViewModel {
        MovieViewModel(dataSource: makeMovieDataSource())
    }

    // Instantiate DataSource
    func makeMovieDataSource() -> MovieDataSource {
        MovieDataSource()
    }
}

final class MovieListViewController: UIViewController, UITableViewDelegate {


    // Here we use protocol composition to create a Factory type that includes
    // all the factory protocols that this view controller needs.
    typealias Factory = MovieListViewControllerFactory

    // We can now lazily create our viewModel using the injected factory.
    lazy var viewModel = factory.makeMovieViewModel()
    private let factory: Factory

    // MARK: - Private properties 🕶
    private let disposeBag = DisposeBag()
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl?

    // MARK: - LifeCycle 🌎
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // Injecting factory during view-controller Instantiation
    init(factory: Factory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Check if controller deallocates
    deinit {
        print("Deallocated...")
    }
}

private extension MovieListViewController {
    func setup() {
        self.title = "Movie App"
        configureTableView()
        bindRx()
        setupErrorBinding()
    }

    // MARK: - Binding data

    func bindRx() {
        self.viewModel.keyword(keyword: "")
        self.viewModel.inputs.refresh()

        // Binding tableView to the datasource
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MovieViewViewModel>>(
            configureCell: { dataSource, tableView, indexPath, movie in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MovieTableCell
                cell.bindViewModel(movie)
                return cell
            })

        // Binding pull to referesh control
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.inputs.loadPageTrigger)
            .disposed(by: disposeBag)

        // Binding tableview to load more data when tableview content offset reaches to bottom
        self.tableView.rx.reachedBottom
            .bind(to: self.viewModel.inputs.loadNextPageTrigger)
            .disposed(by: disposeBag)

        // Binding datasource to the outputs elements after API call
        self.viewModel.outputs.elements.asDriver()
            .map { [SectionModel(model: "Movie List", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // Binding tableview didselect row on cell tap to tapped function
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self]indexPath in
                self?.viewModel.inputs.tapped(indexRow: indexPath.row)
            }).disposed(by: disposeBag)

        // Binding refresh control to end refreshing
        self.viewModel.isLoading
            .do(onNext: { isLoading in
                if isLoading {
                    self.refreshControl?.endRefreshing()
                }
            })
            .drive(isLoading(for: self.view))
            .disposed(by: disposeBag)

        // Binding output selected movie to navigate to Movie Detail controller
        self.viewModel.outputs.selectedViewModel
            .drive(onNext: { movieDetails in
                let container = MovieDetailsDependencyContainer(viewModel: movieDetails)
                let controller = container.makeViewController()
                self.navigationController?.pushViewController(controller, animated: true)
            }).disposed(by: disposeBag)
    }

    // Binding to handle on API error to show alert
    private func setupErrorBinding() {
        viewModel.outputs.error.asDriver(onErrorRecover: { (error) -> Driver<String> in
            Driver.just("")
        })
            .drive(onNext: { [weak self] error in
                guard let self = self else { return }
                self.showAlert(alertMessage: error.description)
            }).disposed(by: disposeBag)
    }

    // Configure tableview
    func configureTableView() {
        self.tableView = UITableView(frame: UIScreen.main.bounds)
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "Cell")

        self.view = self.tableView

        // Set tableview delegates
        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.tableView.tableFooterView = UIView()

        self.refreshControl = UIRefreshControl()
        if let refreshControl = self.refreshControl {
            self.view.addSubview(refreshControl)
            refreshControl.backgroundColor = .clear
            refreshControl.tintColor = .lightGray
        }
    }

    // Show alert
    private func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
