//
//  CustomViewController.swift
//  PlayseeSample
//
//  Created by jcyuwu on 2024/4/14.
//

import UIKit
import AVKit

class CustomViewController: UIViewController {
    
    var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setUpDataSource()
        requestOpenAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(setUpDataSource), name: NSNotification.Name("requestOpenAPICallBack"), object: nil)
        self.playVisibleVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playVisibleVideo(false)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("requestOpenAPICallBack"), object: nil)
    }
    
    func setUpUI() {
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.isScrollEnabled = true
        tableView.isPagingEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicTableViewCell")
        
        //self.view.backgroundColor = .red
        //tableView.backgroundColor = .blue
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: tableView!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: tableView!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: tableView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: tableView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    var dataSource:[String] = [
    ]
    var imageSource:[String] = [
    ]
    var imageLocalSource:[String:UIImage] = [:]
    
    @objc func setUpDataSource() {
        tableView.reloadData()
    }
    
    func requestOpenAPI() {
        let Url = String(format: "https://bandcamp.com/api/fancollection/1/wishlist_items")
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = ["fan_id" : "10236", "older_than_token" : "1504691191:1603563167:a::", "count" : "10"]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(json)
                    
                    let items = json.value(forKeyPath: "items") as! NSArray
                    for i in items {
                        let item = i as! NSDictionary
                        let jpg = item.value(forKeyPath: "item_art.thumb_url") as! String
                        print(jpg)
                        self.imageSource.append(jpg)
                    }
                    
                    let trackLists = json.value(forKeyPath: "tracklists") as! NSDictionary
                    let trackListsArr = trackLists.allValues
                    for t in trackListsArr {
                        let trackArray = t as! NSArray
                        let track = trackArray[0] as! NSDictionary
                        let mp3 = track.value(forKeyPath: "file.mp3-128") as! String
                        print(mp3)
                        self.dataSource.append(mp3)
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("requestOpenAPICallBack"), object: nil, userInfo: nil)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func requestDownloadImage(urlString: String) {
        let url = URL(string: urlString)
        var req: URLRequest?
        if let url {
            req = URLRequest(url: url)
        }
        var task: URLSessionDownloadTask?
        if let req {
            task = URLSession.shared.downloadTask(with: req, completionHandler: { location, response, error in
                let key = req.url?.absoluteString
                if let key {
                    if let location {
                        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        print("File documentDirectory: \(documentDirectory)")
                        let newFilePath = documentDirectory.appendingPathComponent(location.lastPathComponent+".jpg").path
                        print("File downloaded to: \(newFilePath)")
                        try? FileManager.default.moveItem(atPath: location.path, toPath: newFilePath)
                        
                        if let imageData = NSData(contentsOfFile: newFilePath) as Data? {
                            self.imageLocalSource[key] = (UIImage(data: imageData))
                            
                            DispatchQueue.main.async {
                                self.setUpDataSource()
                            }
                        }
                    }
                }
            })
        }
        task?.resume()
    }
}

extension CustomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTableViewCell", for: indexPath) as? MusicTableViewCell else {
            return UITableViewCell()
        }
        if imageLocalSource[imageSource[indexPath.row]] == nil {
            requestDownloadImage(urlString: imageSource[indexPath.row])
        }
        cell.configure(dataSource[indexPath.item], player: nil, thumb: imageLocalSource[imageSource[indexPath.row]])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.reuseIdentifier == "MusicTableViewCell" {
            let videoCell = cell as! MusicTableViewCell
            videoCell.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}

extension CustomViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playVisibleVideo()
    }
}

extension CustomViewController {
    
    func playVisibleVideo(_ shouldPlay:Bool = true) {
        // 1.
        let cells = tableView.visibleCells
        // 2.
        let videoCells = cells.compactMap({ $0.reuseIdentifier == "MusicTableViewCell" ? $0 : nil })
        if videoCells.count > 0 {
            // 3.
            for videoCell in videoCells {
                let cell = videoCell as! MusicTableViewCell
                if shouldPlay {
                    cell.play()
                }
                else {
                    cell.pause()
                }
            }
        }
    }
}
