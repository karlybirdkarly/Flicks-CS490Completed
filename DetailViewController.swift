//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Karlygash Zhuginissova on 1/25/16.
//  Copyright © 2016 Karlygash Zhuginissova. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, APParallaxViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
       
    var movieID: NSDictionary?
    var movie: NSDictionary!
    var endpoint: String!
    var id: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        let customView = UIImageView()
        customView.frame = CGRectMake(0, 0, 320, 200)
        customView.contentMode = UIViewContentMode.ScaleAspectFill
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + infoView.frame.height)
        scrollView.setContentOffset(CGPoint(x: 0, y: -700), animated: true)
        
        addStarRatingView()
        
        requestMovieWithIDFromJSON()
//        print(movie)
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        
        overviewLabel.sizeToFit()
        id = movie["id"] as? Int
        endpoint = String(id)
        
        //Retrieve low resolution first, and then high resolution
        let highBaseUrl = "https://image.tmdb.org/t/p/original"
        let lowBaseUrl = "https://image.tmdb.org/t/p/w45"
        if let posterPath = movie["poster_path"] as? String {
            
            let largeImageUrl = NSURL(string: highBaseUrl + posterPath)
            let smallImageUrl = NSURL(string: lowBaseUrl + posterPath)
            
            let smallImageRequest = NSURLRequest(URL: smallImageUrl!)
            let largeImageRequest = NSURLRequest(URL: largeImageUrl!)
            
            customView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: UIImage(named: "placeholder.jpg"),
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    customView.alpha = 0.0
                    customView.image = smallImage;
      
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        customView.alpha = 1.0
                        }, completion: { (sucess) -> Void in
                            
                            customView.setImageWithURLRequest(largeImageRequest,
                                                            placeholderImage: smallImage,
                                                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    customView.image = largeImage;
                                },
                                failure: { (request, response, error) -> Void in
                                })
                    })
                },
                failure: { (request, response, error) -> Void in
            })  
        }
    else {
            customView.image = UIImage(named: "placeholder.jpg")
         }
        
         scrollView.addParallaxWithView(customView, andHeight: 700, andShadow: true)
   }
    
    func requestMovieWithIDFromJSON() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        print("I am here")
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            NSLog("response: \(responseDictionary)")
                            
                            self.movieID = responseDictionary
                            
                            //MARK: - runtime settings
                            let runtime = self.movieID!["runtime"] as? Int
                            self.durationLabel.text = String(runtime!) + " min"
                            
                            //MARK: - country settings
                            let movieCountries = self.movieID!["production_countries"] as! [NSDictionary]
                            var xPoint: CGFloat = 8
                            for country in movieCountries {
                                
                                let countryImageView = UIImageView(frame: CGRectMake(xPoint, 82, 30, 15))
                                xPoint = xPoint + countryImageView.frame.size.width + 7
                                let countryName = country["name"] as! String
                                print(countryName)
                                
                                
                                
                                let space = NSCharacterSet.whitespaceCharacterSet()
                                let range = countryName.rangeOfCharacterFromSet(space)
                                
                                
                                if let test = range {
                                    
                                    let countryUrlName = countryName.stringByReplacingOccurrencesOfString(" ", withString: "-")
                                    
                                    countryImageView.setImageWithURL(NSURL(string: "https://www.countries-ofthe-world.com/flags/flag-of-\(countryUrlName).png")!)
                                }
                                else {
                                    countryImageView.setImageWithURL(NSURL(string: "https://www.countries-ofthe-world.com/flags/flag-of-\(countryName).png")!)
                                }
                                self.infoView.addSubview(countryImageView)
                                
                            }
                            
                            //MARK: - genre settings
                            let movieGenres = self.movieID!["genres"] as! [NSDictionary]
                            var genreArray = [String]()
                            for genre in movieGenres {
                                print(genre)
                                let genreName = genre["name"] as! String
                                genreArray.append(genreName)
                                
                            }
                            let genreString = genreArray.joinWithSeparator(", ")
                            self.genreLabel.text = genreString
                            self.genreLabel.sizeToFit()
                    }
                }
                else {
                    
                }
        });
        task.resume()

    }
    
    func addStarRatingView() {
        let starRatingView = AXRatingView()
        starRatingView.frame = CGRectMake(7, titleLabel.frame.size.height + 20, 110, 30)
        starRatingView.numberOfStar = 5
        starRatingView.minimumValue = 0.0
        starRatingView.userInteractionEnabled = false
        print("width of stars is : ", starRatingView.frame.size.width)
        
        starRatingView.backgroundColor = UIColor.blackColor()
        starRatingView.highlightColor = UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        starRatingView.baseColor = UIColor.whiteColor()
        
        let vote = movie["vote_average"] as? Float
        starRatingView.value = vote!/2
        voteLabel.text =  String(format: "%.1f", vote!) + "/10"
//        print(starRatingView.value)
        infoView.addSubview(starRatingView)
    }
    
   override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
