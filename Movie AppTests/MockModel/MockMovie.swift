//
//  MockMovie.swift
//  Movie AppTests
//
//  Created by Kaodim MacMini on 06/01/2021.
//

import Foundation
@testable import Movie_App

let mockMovieResponseJson = """
{
    "page": 1,
    "results": [{
        "adult": false,
        "backdrop_path": "/gSIoLWHbNR1fDKd6hLQjoLFT7Ov.jpg",
        "genre_ids": [16, 10751, 35, 10770],
        "id": 13187,
        "original_language": "en",
        "original_title": "A Charlie Brown Christmas",
        "overview": "When Charlie Brown complains about the overwhelming materialism that he sees amongst everyone during the Christmas season, Lucy suggests that he become director of the school Christmas pageant. Charlie Brown accepts, but is a frustrating struggle. When an attempt to restore the proper spirit with a forlorn little fir Christmas tree fails, he needs Linus' help to learn the meaning of Christmas.",
        "popularity": 11.464,
        "poster_path": "/6UnkNFYKrrUOCC8Tm9oOWZk597M.jpg",
        "release_date": "1965-12-09",
        "title": "A Charlie Brown Christmas",
        "video": false,
        "vote_average": 7.7,
        "vote_count": 388
    }],
    "total_pages": 500,
    "total_results": 10000
}
"""

let movieResponseData = mockMovieResponseJson.data(using: .utf8)!
let mockMovieResponse = try! JSONDecoder().decode(MovieResponse.self, from: movieResponseData)

let mockMovie = mockMovieResponse.movies.first



let mockMovieDetailsResponseJson = """
{
    "adult": false,
    "backdrop_path": "/nOK6mVgBUkt7IVSfesVVJd4i5uU.jpg",
    "belongs_to_collection": {
        "id": 427084,
        "name": "The Secret Life of Pets Collection",
        "poster_path": "/d83LVydlQonKdshwQyLYx48D3LH.jpg",
        "backdrop_path": "/lB4l8H0jgPp2bf4NV2aZPIyytdQ.jpg"
    },
    "budget": 75000000,
    "genres": [{
        "id": 12,
        "name": "Adventure"
    }],
    "homepage": "http://www.thesecretlifeofpets.com/",
    "id": 328111,
    "imdb_id": "tt2709768",
    "original_language": "en",
    "original_title": "The Secret Life of Pets",
    "overview": "The quiet life of a terrier named Max is upended when his owner takes in Duke, a stray whom Max instantly dislikes.",
    "popularity": 13.422,
    "poster_path": "/gJo9G56QlXKRe2tcdDVSt28xVsP.jpg",
    "production_companies": [{
        "id": 33,
        "logo_path": "/8lvHyhjr8oUKOOy2dKXoALWKdp0.png",
        "name": "Universal Pictures",
        "origin_country": "US"
    }, {
        "id": 3341,
        "logo_path": "/dTG5dXE1kU2mpmL9BNnraffckLU.png",
        "name": "Fuji Television Network",
        "origin_country": "JP"
    }],
    "production_countries": [{
        "iso_3166_1": "US",
        "name": "United States of America"
    }],
    "release_date": "2016-06-18",
    "revenue": 875457937,
    "runtime": 87,
    "spoken_languages": [{
        "english_name": "English",
        "iso_639_1": "en",
        "name": "English"
    }],
    "status": "Released",
    "tagline": "Think this is what they do all day?",
    "title": "The Secret Life of Pets",
    "video": false,
    "vote_average": 6.2,
    "vote_count": 6542
}
"""
let movieDetailsData = mockMovieDetailsResponseJson.data(using: .utf8)!
let mockMovieDetails = try! JSONDecoder().decode(Movie.self, from: movieDetailsData)
