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


      UINavigationBar.appearance().tintColor = UIColor.black

      let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
      let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")

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
    cell.imgView.setImageWith(imageURL as! URL)

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

          //print("response: \(responseDictionary)")
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



}
