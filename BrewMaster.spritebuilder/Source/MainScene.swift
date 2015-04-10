import Foundation

class MainScene: CCNode {

    func startGameplay() {
        var gameplay = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().replaceScene(gameplay)
    }

}
