//
//  MovieCell.swift
//  NewsArticlesApp
//
//  Created by Kaodim MacMini on 29/12/2020.
//

import UIKit

class MovieCell: UITableViewCell {
    let sectionLabel = UILabel()
    let titleLabel = UILabel()
    let abstrctLabel = UILabel()

    let titleImageView = ScaleAspectFitImageView.init(image: UIImage(named: "blank"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSectionLabel()
        setupTitileLabel()
        setupAbstrctLabel()
        setupTitleImageLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSectionLabel() {
        let marginGuide = contentView.layoutMarginsGuide
        contentView.addSubview(sectionLabel)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        sectionLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        sectionLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        sectionLabel.numberOfLines = 0
        sectionLabel.font = UIFont(name: "Avenir-Book", size: 12)
        sectionLabel.textColor = UIColor.lightGray
    }

    private func setupTitileLabel() {
        let marginGuide = contentView.layoutMarginsGuide
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10).isActive = true
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
    }

    private func setupAbstrctLabel() {
        let marginGuide = contentView.layoutMarginsGuide
        contentView.addSubview(abstrctLabel)
        abstrctLabel.translatesAutoresizingMaskIntoConstraints = false
        abstrctLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        abstrctLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        abstrctLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        abstrctLabel.numberOfLines = 0
        abstrctLabel.font = UIFont(name: "Avenir-Book", size: 12)
        abstrctLabel.textColor = UIColor.lightGray
    }

    private func setupTitleImageLabel() {
        let marginGuide = contentView.layoutMarginsGuide
        contentView.addSubview(titleImageView)
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.clipsToBounds = true
        titleImageView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        titleImageView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleImageView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        titleImageView.topAnchor.constraint(equalTo: abstrctLabel.bottomAnchor).isActive = true
        titleImageView.heightAnchor.constraint(equalToConstant: 293).isActive = true
        titleImageView.widthAnchor.constraint(equalToConstant: 440).isActive = true
    }

    func bindViewModel(_ movie: Movie?) {
        titleLabel.text = movie?.title
        sectionLabel.text = movie?.overview
        abstrctLabel.text = movie?.releaseDate

        let imagePath: String = movie?.backdropPath ?? movie?.posterPath ?? ""

        if !imagePath.isEmpty {
            let url = "https://image.tmdb.org/t/p/w500/" + imagePath
            titleImageView.downloaded(from: url, contentMode: .scaleAspectFit)
        } else {
            titleImageView.image = UIImage.init(systemName: "photo")
            titleImageView.tintColor = UIColor.lightGray
        }
    }
}
