//
//  MainSound.swift
//  Ladybug
//
//  Created by Yannis Lang on 01/01/2017.
//  Copyright © 2017 Yannis. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MainSound {
    var player: AVAudioPlayer?
    
    func playSound(nameOfAudioFileInAssetCatalog: String) {
        if let sound = NSDataAsset(name: nameOfAudioFileInAssetCatalog) {
            do {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                try player = AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeAIFC)
                player!.play()
            } catch {
                print("error initializing AVAudioPlayer")
            }
        }
    }
}
