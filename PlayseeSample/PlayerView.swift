//
//  PlayerView.swift
//  PlayseeSample
//
//  Created by jcyuwu on 2024/4/13.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    static var videoIsMuted: Bool = true

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private var assetPlayer:AVPlayer? {
        didSet {
            if isDeinit {
                if let layer = self.layer as? AVPlayerLayer {
                    layer.player = self.assetPlayer
                }
                return
            }
            DispatchQueue.main.async {
                if let layer = self.layer as? AVPlayerLayer {
                    layer.player = self.assetPlayer
                }
            }
        }
    }
    
    private var playerItem:AVPlayerItem?
    private var urlAsset: AVURLAsset?
    
    var isMuted: Bool = true {
        didSet {
            self.assetPlayer?.isMuted = isMuted
        }
    }
    
    var url: URL?
    
    init() {
        super.init(frame: .zero)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        initialSetup()
    }
    
    private func initialSetup() {
        if let layer = self.layer as? AVPlayerLayer {
            layer.videoGravity = AVLayerVideoGravity.resizeAspect
        }
    }
    
    func prepareToPlay(withUrl url:URL, shouldPlayImmediately: Bool = false) {
        guard !(self.url == url && assetPlayer != nil && assetPlayer?.error == nil) else {
            if shouldPlayImmediately {
                play()
            }
            return
        }
        
        cleanUp()
        
        self.url = url
        
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
        let urlAsset = AVURLAsset(url: url, options: options)
        self.urlAsset = urlAsset
        
        
        if #available(iOS 16.0, *) {
            Task {
                await doAsyncWork(urlAsset: urlAsset, shouldPlayImmediately: shouldPlayImmediately)
            }
        } else {
            let keys = ["tracks"]
            urlAsset.loadValuesAsynchronously(forKeys: keys, completionHandler: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.startLoading(urlAsset, shouldPlayImmediately, [])
            })
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    private func doAsyncWork(urlAsset:AVURLAsset, shouldPlayImmediately:Bool) async {
        do {
            let tracks = try await urlAsset.load(.tracks)
            startLoading(urlAsset, shouldPlayImmediately, tracks)
        } catch {
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func startLoading(_ asset: AVURLAsset, _ shouldPlayImmediately: Bool, _ tracks:[AVAssetTrack]) {
        if #available(iOS 16.0, *) {
            let status = asset.status(of: .tracks)
            if status == .loaded(tracks) {
                let item = AVPlayerItem(asset: asset)
                self.playerItem = item
                self.assetPlayer = AVPlayer(playerItem: item)
                self.didFinishLoading(self.assetPlayer, shouldPlayImmediately)
            }
        } else {
            var error:NSError?
            let status:AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            if status == AVKeyValueStatus.loaded {
                let item = AVPlayerItem(asset: asset)
                self.playerItem = item
                self.assetPlayer = AVPlayer(playerItem: item)
                self.didFinishLoading(self.assetPlayer, shouldPlayImmediately)
            }
        }
    }
    
    private func didFinishLoading(_ player: AVPlayer?, _ shouldPlayImmediately: Bool) {
        guard let player = player, shouldPlayImmediately else { return }
        DispatchQueue.main.async {
            player.play()
        }
    }
    
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        guard notification.object as? AVPlayerItem == self.playerItem else { return }
        DispatchQueue.main.async {
            guard let videoPlayer = self.assetPlayer else { return }
            videoPlayer.seek(to: .zero)
            videoPlayer.play()
        }
    }
    
    func play() {
        guard self.assetPlayer?.isPlaying == false else { return }
        DispatchQueue.main.async {
            self.assetPlayer?.play()
        }
    }
    
    func pause() {
        guard self.assetPlayer?.isPlaying == true else { return }
        if isDeinit {
            self.assetPlayer?.pause()
            return
        }
        DispatchQueue.main.async {
            self.assetPlayer?.pause()
        }
    }
    
    var isDeinit = false
    
    func cleanUp() {
        pause()
        urlAsset?.cancelLoading()
        urlAsset = nil
        assetPlayer = nil
        removeObservers()
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    deinit {
        isDeinit = true
        cleanUp()
    }
}

extension AVPlayer {
    
    var isPlaying:Bool {
        get {
            return (self.rate != 0 && self.error == nil)
        }
    }
}
