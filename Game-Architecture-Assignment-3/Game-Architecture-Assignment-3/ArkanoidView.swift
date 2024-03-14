import UIKit

class ArkanoidView: UIView {
    
    var livesLabel: UILabel!
    var scoreLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Set background color
        backgroundColor = UIColor.lightGray
        
        // Configure lives label
        livesLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 100, height: 30))
        livesLabel.textColor = .white
        livesLabel.font = UIFont.systemFont(ofSize: 18)
        addSubview(livesLabel)
        // Add constraints for lives label
        livesLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            livesLabel.topAnchor.constraint(equalTo: topAnchor, constant: 45),
            livesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
        
        // Configure score label
        scoreLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 100, height: 30))
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 18)
        scoreLabel.text = "Score: "
        addSubview(scoreLabel)
        // Add constraints for score label
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: topAnchor, constant: 45),
            scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 250)
        ])
    }

    
    public func updateLivesLabel(with lives: Int) {
        livesLabel.text = "Lives: \(lives)"
    }
    
    public func updateScoreLabel(with score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
}
