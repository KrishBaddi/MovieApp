//
//  MovieTableCell.swift
//  Movie App
//
//  Created by Kaodim MacMini on 04/01/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MovieTableCell: UITableViewCell {

    @IBOutlet weak var posterImage: ScaleAspectFitImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var releaseData: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var bookContentView: UIView!
    @IBOutlet weak var bookBtnView: UIView!
    @IBOutlet weak var bookBtn: UIButton!

    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.bookBtnView.layer.cornerRadius = 4
    }

    // Configure data
    func bindViewModel(_ movie: MovieViewViewModel?) {
        self.configureMovieInfo(movie?.title, movie?.popularity, movie?.overview, rating: movie?.rating)
        addPosterImage(movie?.backdropPath, movie?.posterPath)
        self.bookContentView.isHidden = true
    }

    // Configure data
    func bindDetailsViewModel(_ movieDetails: MovieDetailViewViewModel) {
        self.bookContentView.isHidden = false

        self.configureMovieInfo(movieDetails.title, movieDetails.popularity, movieDetails.overView, rating: movieDetails.rating)
        releaseData.text = "Release Date: \(movieDetails.releaseDate)"

        addPosterImage(movieDetails.backdropPath, movieDetails.posterPath)

        if let language = movieDetails.language {
            languageLabel.text = "Language: \(language)"
        }

        // Generes are not loading actually, there is some issue with codable
        // But same data and model when I test in playground it works fine.
        if !movieDetails.generateGenres().isEmpty {
            genresLabel.text = movieDetails.generateGenres()
        } else {
            genresLabel.text = "No genres"
        }
        self.durationLabel.text = "Duration: \(movieDetails.getMovieDuration())"
    }

    func configureMovieInfo(_ title: String?, _ popularity: Double?, _ overview: String?, rating: String?) {
        self.titleLabel.text = "Title: " + (title ?? "")
        if let popularity = popularity {
            self.popularityLabel.text = "Popularity: " + String(format: "%.2f", popularity)
        } else {
            self.popularityLabel.text = "NA"
        }
        self.overViewLabel.text = overview

        self.ratingLabel.text = rating
    }

    func addPosterImage(_ backdropPath: String?, _ posterPath: String?) {
        let imagePath: String = backdropPath ?? posterPath ?? ""
        if !imagePath.isEmpty {
            let url = "https://image.tmdb.org/t/p/w500/" + imagePath
            posterImage.downloaded(from: url, contentMode: .scaleAspectFit)
        } else {
            posterImage.image = UIImage.init(systemName: "photo")
            posterImage.tintColor = UIColor.lightGray
        }
    }

    //Emit the cell's viewModel title when the button is clicked
    func bindViewModel<O>(viewModel: MovieDetailViewViewModel, buttonClicked: O) where O: ObserverType, O.Element == String {
        bookBtn.rx.tap
            .map { viewModel.title }
        .bind(to: buttonClicked)
        .disposed(by: disposeBag)
    }

    @IBAction func bookAction(_ sender: Any) {

    }

}
