//
//  MovieViewController.swift
//  movieViewer
//
//  Created by victoria_ku on 6/7/17.
//  Copyright © 2017 victoria_ku. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!
  var movies: [NSDictionary]?
  var endpoint: NSString!
  var pagenum = 1
  var dict2: [NSDictionary]?



  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }


    override func viewDidLoad() {
      super.viewDidLoad()

      tableView.delegate = self
      tableView.dataSource = self

        // Do any additional setup after loading the view.

      let refreshControl = UIRefreshControl()
      refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
      tableView.insertSubview(refreshControl, at: 0)

      let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
      loadingMoreView = InfiniteScrollActivityView(frame: frame)
      loadingMoreView!.isHidden = true
      tableView.addSubview(loadingMoreView!)

      var insets = tableView.contentInset
      insets.bottom += InfiniteScrollActivityView.defaultHeight
      tableView.contentInset = insets


      UINavigationBar.appearance().tintColor = UIColor.black

      let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
      let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)&page=\(pagenum)")

      let request = URLRequest(
        url: url! as URL,
        cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
        timeoutInterval: 10)

      let session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate: nil,
        delegateQueue: OperationQueue.main
      )
      MBProgressHUD.showAdded(to: self.view, animated: true)

      let task: URLSessionDataTask = session.dataTask(with: request,
       completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! JSONSerialization.jsonObject(
            with: data, options:[]) as? NSDictionary {
            self.movies = responseDictionary["results"] as? [NSDictionary]
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
          }
        }
      })
      task.resume()




  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let movies = movies {
      return movies.count
    } else{
      return 0
    }

  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell

    let movie = movies?[indexPath.row]
    let title = movie?["original_title"] as! String
    let overview = movie?["overview"] as! String
    let posterpath = movie?["poster_path"] as! String
    let baseURL = "https://image.tmdb.org/t/p/w500"
    let imageURL = NSURL(string:baseURL + posterpath)

    cell.title.text = title
    cell.title.textColor = UIColor.gray
    cell.overview.text = overview
    cell.overview.textColor = UIColor.white
    cell.backgroundColor = UIColor.black

    cell.title.text = title as String
    cell.overview.text = overview as String
    cell.imgView.setImageWith(imageURL! as URL)

    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

      let cell = sender as! UITableViewCell
      let indexPath = tableView.indexPath(for: cell)
      let movie = movies?[(indexPath?.row)!]

      let detailViewController = segue.destination as! DetailViewController
      detailViewController.movie = movie



      print("prepare")

    }

  func refreshControlAction(_ refreshControl: UIRefreshControl) {

    // ... Create the URLRequest `myRequest` ...
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")

    let request = URLRequest(
      url: url! as URL,
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      timeoutInterval: 10)

    // Configure session so that completion handler is executed on main UI thread
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

      // ... Use the new data to update the data source ...
      if let data = data {
        if let responseDictionary = try! JSONSerialization.jsonObject( with: data, options:[]) as? NSDictionary {
          MBProgressHUD.hide(for: self.view, animated: true)

          //print("response2!: \(responseDictionary)")
          self.movies = responseDictionary["results"] as? [NSDictionary]
          self.tableView.reloadData()
        }
      }

      // Reload the tableView now that there is new data
      self.tableView.reloadData()

      // Tell the refreshControl to stop spinning
      refreshControl.endRefreshing()
    }
    task.resume()
  }

  var isMoreDataLoading = false
  var loadingMoreView:InfiniteScrollActivityView?

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Handle scroll behavior here

    if (!isMoreDataLoading) {



      let currentOffset = scrollView.contentOffset.y
      print(currentOffset)
      let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
      print(maximumOffset)
      let deltaOffset = maximumOffset - currentOffset
      print(deltaOffset)

      if deltaOffset <= 0 {
        isMoreDataLoading = true
        print("secondtrue")
        loadMoreData()

      }

    let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
      loadingMoreView?.frame = frame
      loadingMoreView!.startAnimating()
    }
  }
  func loadMoreData() {

    // ... Create the NSURLRequest (myRequest) ...
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    pagenum = pagenum + 1
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)&page=\(pagenum)")

    let request = URLRequest(
      url: url! as URL,
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      timeoutInterval: 10)

    // Configure session so that completion handler is executed on main UI thread
    let session = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate:nil,
      delegateQueue:OperationQueue.main
    )

    let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in

        // Update flag
        self.isMoreDataLoading = false
        print("should be false",self.isMoreDataLoading)
        self.loadingMoreView!.stopAnimating()


        // ... Use the new data to update the data source ...
      if let data = data {
        print("data")
      if let responseDictionary = try! JSONSerialization.jsonObject( with: data, options:[]) as? NSDictionary {
        MBProgressHUD.hide(for: self.view, animated: true)

        self.movies = responseDictionary["results"] as? [NSDictionary]

        self.tableView.reloadData()

        }
      }

    })
    task.resume()
  }


}

class InfiniteScrollActivityView: UIView {
  var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
  static let defaultHeight:CGFloat = 60.0

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupActivityIndicator()
  }

  override init(frame aRect: CGRect) {
    super.init(frame: aRect)
    setupActivityIndicator()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
  }

  func setupActivityIndicator() {
    activityIndicatorView.activityIndicatorViewStyle = .gray
    activityIndicatorView.hidesWhenStopped = true
    self.addSubview(activityIndicatorView)
  }

  func stopAnimating() {
    self.activityIndicatorView.stopAnimating()
    self.isHidden = true
  }

  func startAnimating() {
    self.isHidden = false
    self.activityIndicatorView.startAnimating()
  }
}


