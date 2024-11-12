import Foundation
import AVFoundation

class AlarmSoundService: NSObject, AVAudioPlayerDelegate {
    static let shared = AlarmSoundService()
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startAlarm() {
        print("startAlarm called")
        guard !isPlaying else { return }
        
        // Ensure audio session is active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
        
        do {
            // Try to load the custom alarm sound
            if let soundURL = Bundle.main.url(forResource: "digital-alarm-clock-151920", withExtension: "mp3") {
                print("Found sound file at: \(soundURL)")
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                print("Successfully created audio player")
                
                audioPlayer?.delegate = self
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = 1.0
                audioPlayer?.prepareToPlay()
                
                if audioPlayer?.play() == true {
                    print("Started playing alarm sound")
                    isPlaying = true
                } else {
                    print("Failed to start playing alarm sound")
                }
            } else {
                print("ERROR: Alarm sound file not found in bundle")
                return
            }
        } catch {
            print("Failed to play alarm sound: \(error)")
        }
    }
    
    func stopAlarm() {
        audioPlayer?.stop()
        isPlaying = false
        
        // Deactivate audio session when done
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    // AVAudioPlayerDelegate method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        
        // Deactivate audio session when playback finishes
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(String(describing: error))")
        isPlaying = false
    }
} 