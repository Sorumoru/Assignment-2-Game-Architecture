import UIKit

class ArkanoidView: UIView {
    
    var livesLabel: UILabel!
    
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
            livesLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            livesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }

    
    public func updateLivesLabel(with lives: Int) {
        livesLabel.text = "Lives: \(lives)"
    }
}
