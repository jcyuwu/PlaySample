//
//  ViewController.swift
//  PlaySample
//
//  Created by jcyuwu on 2024/4/13.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var collectionView:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setUpDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetCollectionView()
        self.playVisibleVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playVisibleVideo(false)
    }
    
    func resetCollectionView() {
//        collectionView.isPagingEnabled = false
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
//        self.view.addSubview(collectionView)
//
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        let horizontalConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
//        let verticalConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
//        let widthConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
//        let heightConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
//        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    func setUpUI() {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.isPagingEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "VideoCollectionViewCell")
        
        //self.view.backgroundColor = .red
        //collectionView.backgroundColor = .blue
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    var dataSource:[String] = [
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
    ]
    
    func setUpDataSource() {
        collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(dataSource[indexPath.item], player: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 240)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.playVisibleVideo(false)
        
        let vc = DetailViewController()
        let cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
        vc.playerSource[0] = cell.playerView.getAssetPlayer()
        vc.dataSource[0] = self.dataSource[indexPath.row]
//        vc.collectionView = self.collectionView
        
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .fullScreen
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        nvc.navigationBar.standardAppearance = appearance
        nvc.navigationBar.scrollEdgeAppearance = appearance
        self.present(nvc, animated: false) {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.reuseIdentifier == "VideoCollectionViewCell" {
            let videoCell = cell as! VideoCollectionViewCell
            videoCell.pause()
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playVisibleVideo()
    }
}

extension ViewController {
    
    func playVisibleVideo(_ shouldPlay:Bool = true) {
        // 1.
        let cells = collectionView.visibleCells
        // 2.
        let videoCells = cells.compactMap({ $0.reuseIdentifier == "VideoCollectionViewCell" ? $0 : nil })
        if videoCells.count > 0 {
            // 3.
            for videoCell in videoCells {
                let cell = videoCell as! VideoCollectionViewCell
                let visibility = checkVideoFrameVisibility(ofCell: cell)
                if shouldPlay && visibility {
                    cell.play()
                }
                else {
                    cell.pause()
                }
            }
        }
    }
    
    func checkVideoFrameVisibility(ofCell cell: VideoCollectionViewCell) -> Bool {
        var cellRect = cell.contentView.bounds
        cellRect = cell.contentView.convert(cell.contentView.bounds, to: collectionView.superview)
        return collectionView.frame.contains(cellRect)
    }
}
