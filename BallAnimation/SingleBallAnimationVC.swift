//
//  SingleBallAnimationVC.swift
//  BallAnimation
//
//  Created by Zeynep Müslim on 27.07.2025.
//

import Foundation

import UIKit
import SwiftUI

class SingleBallAnimationVC: UIViewController {
    
    var draggableBall: DraggableBall!
    
    var progressLabel: UILabel!
    var emojiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Single Ball"
        
        let randomButton = UIButton(type: .system)
        randomButton.setTitle("RANDOM", for: .normal)
        randomButton.addTarget(self, action: #selector(randomButtonTapped), for: .touchUpInside)
        randomButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(randomButton)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        scrollView.addSubview(stackView)
        
        emojiLabel = UILabel()
        emojiLabel.text = "❔"
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        progressLabel = UILabel()
        progressLabel.text = "Progress: 0.00"
        progressLabel.textAlignment = .center
        
        let labelStackView01 = UIStackView(arrangedSubviews: [emojiLabel, progressLabel])
        labelStackView01.axis = .horizontal
        labelStackView01.spacing = 8
        
        stackView.addArrangedSubview(labelStackView01)
        
        draggableBall = DraggableBall(frame: .zero, fillText: "Draggable Ball ", showCornerInnerShadow: true, showTopInnerShadow: true, cornerInnerShadowAlpha: 0.1, topInnerShadowAlpha: 0.1)
        draggableBall.translatesAutoresizingMaskIntoConstraints = false
        draggableBall.delegate = self
        draggableBall.updateFont(name: "Cheetah Kick - Personal Use", size: 32, color: .white)
        draggableBall.fillGradientColors = [ // didSet will update gradient directly
            UIColor.systemBlue.cgColor,
            UIColor.systemCyan.cgColor,
            UIColor.systemTeal.cgColor
        ]
        
        stackView.addArrangedSubview(draggableBall)
        draggableBall.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        NSLayoutConstraint.activate([
            randomButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            randomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: randomButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -80)
        ])
        
//        draggableBall.updateCapsuleWidth(320)
//        draggableBall.updateCapsuleHeight(50)
//        draggableBall.updateBallSize(65)
//        draggableBall.updateIndicatorSize(190)
//        draggableBall.updateIndicatorTopOffset(-5)
//        draggableBall.updateFont(name: "Cheetah Kick - Personal Use", size: 44, color: .white)
//        draggableBall.fillGradientColors = [ // didSet will update gradient directly
//            UIColor.renk02.cgColor,
//            UIColor.renk03.cgColor
//        ]
        
//        updateCapsuleHeight(_:)
//        updateCapsuleWidth(_:)
    }
    
    @objc func randomButtonTapped() {
        let randomProgress = CGFloat.random(in: 0...1)
        draggableBall.setProgress(randomProgress, animated: true)
    }
}

// MARK: - DraggableBallDelegate
extension SingleBallAnimationVC: DraggableBallDelegate {
    func draggableBall(_ draggableBall: DraggableBall, didUpdateProgress progress: CGFloat) {
        progressLabel.text = String(format: "Progress: %.2f", progress)
    }

    func draggableBallDidReachEnd(_ draggableBall: DraggableBall) {
        print("Ball reached the end!")
        emojiLabel.text = "🎬"
    }

    func draggableBallDidReturnToStart(_ draggableBall: DraggableBall) {
        print("Ball returned to the start.")
        emojiLabel.text = "🎉"
    }
}

struct SingleBallAnimationVC_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            SingleBallAnimationVC()
        }
    }
}
