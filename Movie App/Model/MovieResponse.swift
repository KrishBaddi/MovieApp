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
public struct Movie: Codable {
    let adult: Bool
    let backdropPath: String?
    let belongsToCollection: BelongsToCollection?
    let budget: Int?
    let genres: [Genre] = []
    let genreIDS: [Int] = []
    let homepage: String?
    let id: Int
    let imdbID, originalLanguage, originalTitle, overview: String?
    let popularity: Double
    let posterPath: String
    let productionCompanies: [ProductionCompany] = []
    let productionCountries: [ProductionCountry] = []
    let releaseDate: String
    let revenue, runtime: Int?
    let spokenLanguages: [SpokenLanguage] = []
    let status, tagline, title: String?
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case genres
        case backdropPath = "backdrop_path"
        case belongsToCollection = "belongs_to_collection"
        case budget, homepage, id
        case genreIDS = "genre_ids"
        case imdbID = "imdb_id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case status, tagline, title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}


struct SectionOfMovies: Codable {
    var header: String
    var items: [Movie]
}


// MARK: - BelongsToCollection
struct BelongsToCollection: Codable {
    let id: Int
    let name, posterPath, backdropPath: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

// MARK: - Genre
struct Genre: Codable, Equatable {
    let id: Int
    let name: String
}


// MARK: - ProductionCompany
struct ProductionCompany: Codable {
    let id: Int
    let logoPath, name, originCountry: String

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

// MARK: - ProductionCountry
struct ProductionCountry: Codable {
    let iso3166_1, name: String

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}

// MARK: - SpokenLanguage
struct SpokenLanguage: Codable {
    let englishName, iso639_1, name: String

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1 = "iso_639_1"
        case name
    }
}
