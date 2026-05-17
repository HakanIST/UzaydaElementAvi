//
//  AudioManager.swift
//  UzaydaElementAvi
//
//  Background music and sound effects manager.
//

import AVFoundation
import AudioToolbox

final class AudioManager {
    static let shared = AudioManager()

    private var bgPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?

    private init() {
        // Allow audio to mix with other apps and play even in silent mode
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Background Music

    func startMusic() {
        guard bgPlayer == nil || bgPlayer?.isPlaying == false else { return }
        guard let url = Bundle.main.url(forResource: "element_avi_bgm", withExtension: "m4a") else { return }
        do {
            bgPlayer = try AVAudioPlayer(contentsOf: url)
            bgPlayer?.numberOfLoops = -1  // infinite loop
            bgPlayer?.volume = 0.35
            bgPlayer?.prepareToPlay()
            bgPlayer?.play()
        } catch {
            print("BGM error: \(error)")
        }
    }

    func stopMusic() {
        bgPlayer?.stop()
        bgPlayer = nil
    }

    func pauseMusic() {
        bgPlayer?.pause()
    }

    func resumeMusic() {
        bgPlayer?.play()
    }

    var isMusicPlaying: Bool {
        bgPlayer?.isPlaying ?? false
    }

    // MARK: - Sound Effects

    /// Correct answer — ascending bright ding
    func playCorrect() {
        playSynthTone(frequency: 880, duration: 0.12, volume: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playSynthTone(frequency: 1320, duration: 0.15, volume: 0.4)
        }
    }

    /// Crash / obstacle hit — low buzz
    func playCrash() {
        playSynthTone(frequency: 150, duration: 0.2, volume: 0.6)
    }

    /// Pickup collected — quick high blip
    func playPickup() {
        playSynthTone(frequency: 1047, duration: 0.06, volume: 0.2)
    }

    // MARK: - Synth Tone Generator

    private func playSynthTone(frequency: Double, duration: Double, volume: Float) {
        let sampleRate: Double = 44100
        let samples = Int(sampleRate * duration)
        let dataSize = samples * 2  // 16-bit mono

        var data = Data(count: dataSize)
        data.withUnsafeMutableBytes { rawBuf in
            let buf = rawBuf.bindMemory(to: Int16.self)
            for i in 0..<samples {
                let t = Double(i) / sampleRate
                // Envelope: quick attack, exponential decay
                let envelope = max(0, 1.0 - t / duration) * (1.0 - exp(-t * 200))
                let sample = sin(2.0 * .pi * frequency * t) * envelope * Double(Int16.max)
                buf[i] = Int16(clamping: Int(sample))
            }
        }

        // Build WAV header
        var wav = Data()
        let headerSize = 44
        let fileSize = headerSize + dataSize - 8

        wav.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(fileSize).littleEndian) { Array($0) })
        wav.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
        wav.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })  // PCM
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })  // mono
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(44100).littleEndian) { Array($0) })
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(88200).littleEndian) { Array($0) }) // byte rate
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Array($0) })  // block align
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Array($0) }) // bits
        wav.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Array($0) })
        wav.append(data)

        do {
            sfxPlayer = try AVAudioPlayer(data: wav)
            sfxPlayer?.volume = volume
            sfxPlayer?.play()
        } catch {}
    }
}
