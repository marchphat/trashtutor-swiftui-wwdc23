//
//  MusicPlayer.swift
//  TrashTutor
//
//  Created by Nantanat Thongthep on 19/4/2566 BE.
//

import AVFoundation

struct MusicPlayer {
    static var shared = MusicPlayer()
    private var player: AVAudioPlayer?
    
    mutating func playMusic(name: String, type: String, loop: Bool, action: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: type) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            if action == "BGM" {
                player?.volume = 0.2
            }
            else {
                player?.volume = 1.0
            }
            
            player?.play()
            
            if loop {
                player?.numberOfLoops = -1
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
}
