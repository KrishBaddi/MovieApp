//
//  MovieTableCell.swift
//  Movie App
//
//  Created by Kaodim MacMini on 04/01/2021.
//

import UIKit

class MovieTableCell: UITableViewCell {

    @IBOutlet weak var posterImage: ScaleAspectFitImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bindViewModel(_ movie: Movie?) {
        self.titleLabel.text = "Title: " + (movie?.title ?? "")
        if let popularity = movie?.popularity {
            self.popularityLabel.text = "Popularity: " + String(describing: popularity)
        } else {
            self.popularityLabel.text = "NA"
        }

        self.overViewLabel.text = movie?.overview
        let imagePath: String = movie?.backdropPath ?? movie?.posterPath ?? ""

        if !imagePath.isEmpty {
            let url = "https://image.tmdb.org/t/p/w500/" + imagePath
            posterImage.downloaded(from: url, contentMode: .scaleAspectFit)
        } else {
            posterImage.image = UIImage.init(systemName: "photo")
            posterImage.tintColor = UIColor.lightGray
        }
    }
}
