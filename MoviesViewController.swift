//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Karlygash Zhuginissova on 1/14/16.
//  Copyright © 2016 Karlygash Zhuginissova. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var collectionViewDisplayed: Bool = false
    
    //var moviesArray = [Movie]()
    // var filteredMovies = [Movie]()
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    
    var refreshControl: UIRefreshControl!
    var button: UIButton = UIButton(type: UIButtonType.Custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //image for button
        button.setImage(UIImage(named: "collection.png"), forState: UIControlState.Normal)
        //function for button
        button.addTarget(self, action: "changeViewClicked", forControlEvents: UIControlEvents.TouchUpInside)
        //frame
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        //leftbarbuttonitem is custom button(barbutton)
        self.navigationItem.leftBarButtonItem = barButton
        
        //MARK: - navigation bar settings
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0), NSFontAttributeName: UIFont(name: "KohinoorBangla-Semibold", size: 20.0)!]
        print(navigationController?.navigationBar.titleTextAttributes)
        navigationItem.title = "FLICKS"
        
        searchBar.tintColor = UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        
        //MARK: - refresh control settings
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.blackColor()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //dismissKeyboard when user taps screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.collectionView.hidden = true
        networkErrorView.hidden = true
        
        //MARK: - data sourses and delegates for collection view and table view
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        
        filteredMovies = movies
        
//        let nipName=UINib(nibName: "MovieCellNib", bundle:nil)
//        collectionView.registerNib(nipName, forCellWithReuseIdentifier: "CollectionMovieCell")

//        refreshControl.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
//        actInd.color = UIColor.blackColor()
//        footerView.addSubview(actInd)
//        actInd.startAnimating()
//        self.tableVIew.tableFooterView = footerView
        
//        searchBar.frame.origin.y  = (navigationController?.navigationBar.frame.height)!
//        tableView.frame.origin.y = (navigationController?.navigationBar.frame.height)! + searchBar.frame.height
        
        
        //EZLoadingActivity.showWithDelay("Loading movies...", disableUI: false, seconds: 2)
        //EZLoadingActivity.show("Loading", disableUI: true)
        
//        var refreshControlViewFrame = self.tableView.bounds;
//        refreshControlViewFrame.origin.y = -refreshControlViewFrame.size.height
//        let refreshControlView = UIView(frame: refreshControlViewFrame)
//        refreshControlView.backgroundColor = UIColor.blackColor()
        
        //MARK: - Parse data using API
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
                    
                    print("I am here 1")
                    self.tableView.frame.origin.y = (self.navigationController?.navigationBar.frame.height)! + self.searchBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            EZLoadingActivity.showWithDelay("Uploading movies...", disableUI: false, seconds: 1)
                            //EZLoadingActivity.hide(success: true, animated: true)
                            print("I am here 2")
                            
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.filteredMovies = self.movies
                            
//                            for item in self.m®ovies! {
//                               
//                                let title = item["title"] as! String
//                                let overview = item["overview"] as! String
//                                
//                                let oneMovie = Movie()
//                                oneMovie.title = title
//                                oneMovie.overview = overview
//                                
//                                let baseUrl = "http://image.tmdb.org/t/p/w500"
//                                if let posterPath = item["poster_path"] as? String {
//                                    let imageUrl = NSURL(string: baseUrl + posterPath)
//                                   oneMovie.posterUrl = imageUrl!
//                                } else {
//                                    oneMovie.posterUrl = NSURL(string: "http://img4.wikia.nocookie.net/__cb20150504190753/clashofclans/images/4/47/Placeholder.png")!
//                                }
//                                self.moviesArray.append(oneMovie)
//                            }
                            self.tableView.reloadData()
                            self.collectionView.reloadData()
                    }
                }
                else {
                    self.networkErrorView.hidden = false
                    self.searchBar.hidden = true
                }
        });
        task.resume()
    }
    
    //MARK: - SearchBar
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        if (collectionView.hidden) {
            tableView.reloadData()

        } else if (tableView.hidden == true) {
        collectionView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

  //MARK: - Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return filteredMovies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

//        let movie = moviesArray[indexPath.row] as Movie
//        cell.titleLabel.text = movie.title
//        cell.overviewLabel.text = movie.overview
//        cell.posterView.setImageWithURL(movie.posterUrl)
        
        let movie = filteredMovies![indexPath.row]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            if let posterPath = movie["poster_path"] as? String {
                let imageUrl = NSURL(string: baseUrl + posterPath)
                let imageRequest = NSURLRequest(URL: imageUrl!)

                cell.posterView.setImageWithURLRequest(imageRequest, placeholderImage: UIImage(named: "placeholder,jpg"), success: {(imageRequest, imageResponse, image) -> Void in
                    
                    if imageResponse != nil {
                        print("Image was not cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(2.0, animations: {() -> Void in
                            cell.posterView.alpha = 1.0
                        })
                        
                    } else {
                        print("Image was not cached so just update the image")
                        cell.posterView.image = image
                        }
                    }, failure: { (imageRequest, imageResponse, error) -> Void in
                        cell.posterView.image = UIImage(named: "placeholder.jpg")
                })
                
                cell.posterView.setImageWithURL(imageUrl!)
            } else {
                cell.posterView.image = UIImage(named: "placeholder.jpg")
            }
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview

        print("row \(indexPath.row)")
        return cell
    }
    
    
//MARK: - CollectionView
   
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies?.count ?? 0
        print("I am displayed")
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionMovieCell", forIndexPath: indexPath) as! CollectionMovieCell
        
        let movie = filteredMovies![indexPath.row]
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: imageUrl!)

            cell.posterImage.setImageWithURLRequest(imageRequest, placeholderImage: UIImage(named: "placeholder,jpg"), success: {(imageRequest, imageResponse, image) -> Void in
                
                if imageResponse != nil {
                    print("Image was not cached, fade in image")
                    cell.posterImage.alpha = 0.0
                    cell.posterImage.image = image
                    UIView.animateWithDuration(2.0, animations: {() -> Void in
                        cell.posterImage.alpha = 1.0
                    })
                    
                } else {
                    print("Image was not cached so just update the image")
                    cell.posterImage.image = image
                }
                }, failure: { (imageRequest, imageResponse, error) -> Void in
                    cell.posterImage.image = UIImage(named: "placeholder.jpg")
            })
            cell.posterImage.setImageWithURL(imageUrl!)
        } else {
            cell.posterImage.image = UIImage(named: "placeholder.jpg")
        }
        return cell
    }
    
    //MARK: - Switch between CollectionView and TableView
    func changeViewClicked() {
        
        var fromView, toView: UIView!
        if (self.collectionView.hidden) {
            fromView = self.tableView
            toView = self.collectionView
            fromView.hidden = true
            toView.hidden = false
            
            button.setImage(UIImage(named: "table.png"), forState: UIControlState.Normal)
            
            UIView.transitionFromView(fromView, toView: toView, duration: 0.75, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
        }
            
        else if (self.tableView.hidden == true) {
            fromView = self.collectionView
            toView = self.tableView
            fromView.hidden = true
            toView.hidden = false
            
            button.setImage(UIImage(named: "collection.png"), forState: UIControlState.Normal)
            
            UIView.transitionFromView(fromView, toView: toView, duration: 0.75, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            }
        print(self.tableView.hidden)
        self.view.addSubview(searchBar)
    }


    //MARK: - Refresh
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    //MARK: - Dismiss keyboard
    func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    //MARK: - Status bar style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewDidAppear(animated: Bool) {
//        UIView.animateWithDuration(3.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//                self.button.alpha = 1.0
//                }, completion: nil)
//
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
