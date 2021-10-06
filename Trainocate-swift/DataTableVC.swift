//
//  DataTableVC.swift
//  Trainocate-swift
//
//  Created by 大空太陽 on 5/10/21.
//

import UIKit

class DataTableVC: UITableViewController {
    
    //how to structure our codebase......
    
    private var postData: [Post] = []
    private var presentableData : [Post] = []
    
    private var limit: Int = 10

    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    private var isAPICalled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Posts"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isAPICalled {
            callAPI()
        }

    }
    
    // MARK: Private methods...
    private func callAPI() {
        // showing loader at the time of api call
        showLoader()
        
        self.getData { [weak self] success in // to avoid retain cycle....
            
            // weak can have nil value.... so only optionals can hold nil values.... ?
            
            // hiding loader, once we get the response..
            self?.hideLoader()
            self?.isAPICalled = true
            
            if (self?.postData.count ?? 0  > 0 && success) {
                
                DispatchQueue.main.async {
                    self?.tableView.delegate = self
                    self?.tableView.dataSource = self
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    
    private func showLoader() {
        DispatchQueue.main.async {
            self.activityIndicator.center = self.view.center
            self.activityIndicator.startAnimating()
            self.view.addSubview(self.activityIndicator)
            self.view.bringSubviewToFront(self.activityIndicator)
        }
    }
    
    private func hideLoader() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
        
    }
    
    // by default, it will return 0 -> 9 index elements ,i.e 10 elements
    private func fetchPaginatedData(starting : Int = 0) -> [Post] {
        var arr : [Post] = []
        let end = starting + 9
        let endIndex = end <= postData.count ? end : postData.count
        print("returning data from \(starting) -> \(endIndex) Index")
        
        // fetching data for the range....
        arr = Array(postData[starting...end]) // fetching locally....
        
        //but real time application...
        // usually we do it via an API call....
        
        print(arr)
        return arr
    }

    // MARK: - Table view data source
    
    // handling pagination on the basis of array.....
    // specific pagination..
    // next starting anf end index of the data..
    // 0- 9 // 10 elements..
    // 10-19 // next 10 elements... // append it to the main array....
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentableData.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "dataView"
        
        if indexPath.row == self.presentableData.count {
            cellIdentifier = "addLimitRow"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if (cellIdentifier == "dataView") {
            let rowData = self.presentableData[indexPath.row]
            
            let labelTitle = cell.viewWithTag(1) as? UILabel
            labelTitle?.text = rowData.title
            
            let labelBody = cell.viewWithTag(2) as? UILabel
            labelBody?.text = rowData.body
            
            let labelPostID = cell.viewWithTag(3) as? UILabel
            labelPostID?.text = "Post ID: \(rowData.id)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentableData += fetchPaginatedData(starting: self.presentableData.count)
        self.tableView.reloadData()
    }
    
    
    // one way to handle pagination......
    
    // using limit varibale....

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.limit > self.postData.count ? self.postData.count : (self.limit + 1)
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cellIdentifier = "dataView"
//        if (self.limit < self.postData.count && indexPath.row == limit){
//            cellIdentifier = "addLimitRow"
//        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        if (cellIdentifier == "dataView") {
//            let rowData = self.postData[indexPath.row]
//
//            let labelTitle: UILabel = cell.viewWithTag(1) as! UILabel
//            labelTitle.text = rowData.title
//            let labelBody: UILabel = cell.viewWithTag(2) as! UILabel
//            labelBody.text = rowData.body
//            let labelPostID: UILabel = cell.viewWithTag(3) as! UILabel
//            labelPostID.text = "Post ID: \(rowData.id)"
//        }
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (self.limit < self.postData.count && indexPath.row == limit){
//            self.limit += 10
//            self.tableView.reloadData()
//        }
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "viewPostDetails") {
            let rowData = self.postData[self.tableView.indexPathForSelectedRow!.row]
            let vc:DataVC = segue.destination as! DataVC
            vc.configure(data: rowData)
//            vc.title = rowData.title
//            vc.postTitle = rowData.title
//            vc.body = rowData.body
//            vc.postID = rowData.id
        }
    }
    
    
    //MARK: API Call
    
    func getData(completion: @escaping (Bool)->()) {
        
        let session = URLSession.shared
        
        // block 1
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            completion(false)
            return
        }
        
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            
            // block 2
            if let _error = error {
                print(_error)
                completion(false)
                return
            }
            
            
            // block 3....
            guard let _data = data else {
                completion(false)
                return
            }
            
            // Serialize the data into an object
            do {
                // block 4....
                let json = try JSONDecoder().decode([Post].self, from: _data )
                print(json) // an array of MyPosts...
                self.postData = json
                self.presentableData = self.fetchPaginatedData()
                completion(true)
            } catch {
                // block 5....
                print("Error during JSON serialization: \(error.localizedDescription)")
                completion(false)
            }
        })
        task.resume()
    }

}


struct Post: Codable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
    var random : String? = "random"
}
