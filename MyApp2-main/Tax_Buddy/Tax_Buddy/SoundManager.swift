import AVFoundation

final class SoundManager {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?

    private init() {}

    func playClick() {
        guard let url = Bundle.main.url(forResource: "click", withExtension: "mp3") else {
            print("Click sound not found.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
}
