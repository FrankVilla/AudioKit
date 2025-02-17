// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// AudioKit version of Apple's Reverb Audio Unit
///
public class Reverb: Node {
    fileprivate let reverbAU = AVAudioUnitReverb()

    let input: Node
    
    /// Connected nodes
    public var connections: [Node] { [input] }
    
    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode

    // Hacking start, stop, play, and bypass to use dryWetMix because reverbAU's bypass results in no sound

    /// Start the node
    public func start() { reverbAU.wetDryMix = dryWetMix * 100.0 }
    /// Stop the node
    public func stop() { reverbAU.wetDryMix = 0.0  }
    /// Play the node
    public func play() { reverbAU.wetDryMix = dryWetMix * 100.0 }
    /// Bypass the node
    public func bypass() { reverbAU.wetDryMix = 0.0 }

    /// Dry/Wet Mix (Default 0.5)
    public var dryWetMix: AUValue = 0.5 {
        didSet {
            dryWetMix = dryWetMix.clamped(to: 0...1)
            reverbAU.wetDryMix = dryWetMix * 100.0
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: Node to reverberate
    ///   - dryWetMix: Amount of processed signal (Default: 0.5, Range: 0 - 1)
    ///
    public init(_ input: Node, dryWetMix: AUValue = 0.5) {
        self.input = input
        self.dryWetMix = dryWetMix

        avAudioNode = reverbAU

        reverbAU.wetDryMix = dryWetMix * 100.0
    }

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
    }

}

public extension AVAudioUnitReverbPreset {
    static var allCases: [AVAudioUnitReverbPreset] =
    [.smallRoom, .mediumRoom,
     .largeHall, .mediumHall, .largeHall,
     .plate,
     .mediumChamber, .largeChamber,
     .cathedral,
     .largeRoom2, .mediumHall2, .mediumHall3, .largeHall2]


    public var name: String {
        switch self {

        case .smallRoom:
            return "Small Room"
        case .mediumRoom:
            return "Medium Room"
        case .largeRoom:
            return "Large Hall"
        case .mediumHall:
            return "Medium Hall"
        case .largeHall:
            return "Large Hall"
        case .plate:
            return "Plate"
        case .mediumChamber:
            return "Medium Chamber"
        case .largeChamber:
            return "Large Chamber"
        case .cathedral:
            return "Cathedral"
        case .largeRoom2:
            return "Large Room 2"
        case .mediumHall2:
            return "Medium Hall 2"
        case .mediumHall3:
            return "Medium Hall 3"
        case .largeHall2:
            return "Large Hall 2"
        @unknown default:
            return "Unknown "
        }
    }

    static var defaultValue: AVAudioUnitReverbPreset {
        return .smallRoom
    }

    public var next: AVAudioUnitReverbPreset {
        return AVAudioUnitReverbPreset(rawValue: (rawValue + 1) % AVAudioUnitReverbPreset.allCases.count) ?? AVAudioUnitReverbPreset.defaultValue
    }

    public var previous: AVAudioUnitReverbPreset {
        var newValue = rawValue - 1
        while newValue < 0 {
            newValue += AVAudioUnitReverbPreset.allCases.count
        }
        return AVAudioUnitReverbPreset(rawValue: newValue) ?? AVAudioUnitReverbPreset.defaultValue
    }
}
