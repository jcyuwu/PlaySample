//
//  VideoTableViewCell.swift
//  PlayseeSample
//
//  Created by jcyuwu on 2024/4/13.
//

import UIKit
import AVKit

class VideoTableViewCell: UITableViewCell {
    
    let playerView:PlayerView = {
        let view = PlayerView()
        view.clipsToBounds = true
        return view
    }()
    
    let textView:UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var url: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setUpUI()
    }
    
    func setUpUI() {
        //self.backgroundColor = .green
        //self.contentView.backgroundColor = .yellow
        playerView.backgroundColor = .black
        self.contentView.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 0.5, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.5, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        self.contentView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        textView.backgroundColor = .clear
        self.contentView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint2 = NSLayoutConstraint(item: textView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.5, constant: 0)
        let verticalConstraint2 = NSLayoutConstraint(item: textView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint2 = NSLayoutConstraint(item: textView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.5, constant: 0)
        let heightConstraint2 = NSLayoutConstraint(item: textView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 0.5, constant: 0)
        self.contentView.addConstraints([horizontalConstraint2, verticalConstraint2, widthConstraint2, heightConstraint2])
    }
    
    @objc
    func volumeAction(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        playerView.isMuted = sender.isSelected
        PlayerView.videoIsMuted = sender.isSelected
    }
    
    func play() {
        if let url = url {
            playerView.prepareToPlay(withUrl: url, shouldPlayImmediately: true, player: nil)
        }
    }
    
    func pause() {
        playerView.pause()
    }
    
    func configure(_ videoUrl: String, player: AVPlayer?) {
        guard let url = URL(string: videoUrl) else { return }
        self.url = url
        playerView.prepareToPlay(withUrl: url, shouldPlayImmediately: false, player: player)
        textView.text = url.absoluteString
    }
}
