//
//  MovieResponse.swift
//  Movie App
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import Foundation
import RxDataSources

// MARK: - MovieResponse
struct MovieResponse: Codable {
    let page: Int
    let movies: [Movie]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case movies = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}


// MARK: - Result
struct Movie: Codable {
    let adult: Bool
    let backdropPath: String?
    let genreIDS: [Int]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String?
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}


struct SectionOfMovies: Codable {
    var header: String
    var items: [Movie]
}

extension SectionOfMovies: SectionModelType {
    typealias Item = Movie
    init(original: SectionOfMovies, items: [Movie]) {
        self = original
        self.items = items
    }
}
