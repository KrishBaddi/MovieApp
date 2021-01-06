//
//  MovieViewViewModel.swift
//  Movie App
//
//  Created by Kaodim MacMini on 06/01/2021.
//

import Foundation

public struct MovieViewViewModel {

    private var movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }

    var id: Int {
        return movie.id
    }
    
    var title: String? {
        return movie.title
    }

    var overview: String? {
        return movie.overview
    }

    var posterPath: String {
        return movie.posterPath
    }

    var backdropPath: String? {
        return movie.backdropPath
    }

    var popularity: Double? {
        return movie.popularity
    }

    var rating: String {
        let rating = Int(movie.voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        return ratingText
    }

}
