//
//  MovieDetailSectionModel.swift
//  Movie App
//
//  Created by Kaodim MacMini on 06/01/2021.
//

import Foundation

public struct MovieDetailViewViewModel {
    let title: String
    let genres: [Genre]
    let languageCode: LanguageCodes?
    let runtime: Int?
    let releaseDate: String
    let popularity: Double
    let overView: String
    let backdropPath: String?
    let posterPath: String?

    var language: String? {
        languageCode?.language
    }

    var voteAverage: Double

    var rating: String {
        let rating = Int(voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        if ratingText.isEmpty {
            return "No Rating"
        }
        return ratingText
    }

    init(_ movie: Movie) {
        self.title = movie.title ?? ""
        self.genres = movie.genres
        self.languageCode = LanguageCodes.init(rawValue: movie.originalLanguage?.uppercased() ?? "")
        self.overView = movie.overview ?? ""
        self.popularity = movie.popularity
        self.backdropPath = movie.backdropPath
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.runtime = movie.runtime
        self.voteAverage = movie.voteAverage
    }

    // Function to convert intervals to hours and minutes
    func getMovieDuration() -> String {
        if let interval = runtime {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .full

            // Movie duration is assumed in minutes
            let formattedString = formatter.string(from: TimeInterval(interval * 60))!
            return formattedString
        }
        return ""
    }

    // Generate list of genres separated by |
    func generateGenres() -> String {
        var genresText: String = ""
        self.genres.forEach { (item) in
            if item != self.genres.last {
                genresText += "\(item.name) |"
            } else {
                genresText += "\(item.name)"
            }
        }
        return genresText
    }
}
