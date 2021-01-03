//
//  ViewController.swift
//  Movie App
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let data = MovieDataSource()
        data.getMovies("2016-12-31", .releaseDateDesc, page: 1)
            .map { (result) -> [Movie] in
                result.movies
            }.subscribe { (movies) in

            } onError: { (error) in

            } onCompleted: {

            } onDisposed: {
                
            }

        
    }


}

