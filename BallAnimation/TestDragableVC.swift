//
//  TestDragableView.swift
//  BallAnimation
//
//  Created by Zeynep Müslim on 15.08.2025.
//

import UIKit
import SwiftUI

class TestDragableVC: UIViewController {

/*

 get progress : .didUpdateProgress
 update text : .updateText
 reach start : .draggableBallDidReturnToStart
 reach end : .draggableBallDidReachEnd
 set ball size : .updateBallSize
 indicator size : .updateIndicatorSize
 indicator offset : .updateIndicatorTopOffset
 capsule height : .updateCapsuleHeight
 capsule width : .updateCapsuleWidth
 font family-size-color : .updateFont, .updateFontSize, .updateFontColor
 inner shadow : .updateCornerInnerShadow
 top shadow : .updateTopInnerShadow
 fill gradient updates : .updateFillGradientColors
 
*/
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerContainer = UIView()
    private let headerLabel = UILabel()

    // Draggable
    private let draggableContainer = UIView()
    private let draggableLabel = UILabel()
    private var draggableBall: DraggableBall!

    // Progress
    private let progressContainer = UIView()
    private let progressLabel = UILabel()
    private let progressValueLabel = UILabel()

    // Delegate
    private let delegateContainer = UIView()
    private let delegateLabel = UILabel()
    private let delegateStateLabel = UILabel()
    private let delegateDescriptionLabel = UILabel()
    private let delegateGreenCircleLabel = UILabel()
    
    // Ball Size
    private let ballSizeContainer = UIView()
    private let ballSizeLabel = UILabel()
    private let ballSizeSlider = UISlider()
    private let ballSizeValueLabel = UILabel()

    // Appearance
    private let appearanceContainer = UIView()
    private let appearanceLabel = UILabel()
    private let indicatorSizeLabel = UILabel()
    private let indicatorSizeSlider = UISlider()
    private let indicatorSizeValueLabel = UILabel()
    private let indicatorTopOffsetLabel = UILabel()
    private let indicatorTopOffsetSlider = UISlider()
    private let indicatorTopOffsetValueLabel = UILabel()
    private let capsuleHeightLabel = UILabel()
    private let capsuleHeightSlider = UISlider()
    private let capsuleHeightValueLabel = UILabel()
    private let capsuleWidthLabel = UILabel()
    private let capsuleWidthSlider = UISlider()
    private let capsuleWidthValueLabel = UILabel()
    private let capsuleWidthSwitch = UISwitch()

    // Text
    private let textContainer = UIView()
    private let textLabel = UILabel()
    private let textInputLabel = UILabel()
    private let textInputField = UITextField()
    private let fontSelectionLabel = UILabel()
    private let fontSegmentedControl = UISegmentedControl()
    private let fontSizeLabel = UILabel()
    private let fontSizeSlider = UISlider()
    private let fontSizeValueLabel = UILabel()
    private let colorPickerLabel = UILabel()
    private let currentColorHexLabel = UILabel()
    private let colorPickerButton = UIButton(type: .system)
    private let colorPreviewCircle = UIView()
    private let colorPickerContainerView = UIView()

    // Shadow
    private let shadowContainer = UIView()
    private let shadowLabel = UILabel()
    private let cornerShadowSwitch = UISwitch()
    private let cornerShadowLabel = UILabel()
    private let cornerShadowAlphaSlider = UISlider()
    private let cornerShadowAlphaValueLabel = UILabel()
    private let topShadowSwitch = UISwitch()
    private let topShadowLabel = UILabel()
    private let topShadowAlphaSlider = UISlider()
    private let topShadowAlphaValueLabel = UILabel()

    // Gradient
    private let gradientContainer = UIView()
    private let gradientLabel = UILabel()
    private var gradientColorViews: [UIView] = []
    private var gradientHexFields: [UITextField] = []
    
    private var selectedGradientColors: [UIColor] = [
        UIColor.systemTeal,
        UIColor.systemBlue,
        UIColor.systemPurple,
        UIColor.systemPink
    ]
    private var editingGradientColorIndex: Int?

    // MARK: - Layout Constants
    private enum Layout {
        static let standardPadding: CGFloat = 12
        static let sectionSpacing: CGFloat = 16
        static let headerHeight: CGFloat = 40
        static let draggableHeight: CGFloat = 80
    }
    
    private let fontNames = ["Cheetah Kick - Personal Use", "Amarillo", "Bhineka"]
    private var selectedFontIndex = 0
    private var selectedFontSize: CGFloat = 16
    private var selectedTextColor: UIColor = .white
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDraggableBall()
        setupKeyboardObservers()
        setupTapToDismissKeyboard()
        
        currentColorHexLabel.text = colorToHex(selectedTextColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maxWidth = view.bounds.width - 2 * Layout.standardPadding
        if maxWidth > 150 {
            capsuleWidthSlider.maximumValue = Float(maxWidth)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        setupHeaderSection()
        setupDraggableSection()
        setupProgressSection()
        setupDelegateSection()
        setupBallSizeSection()
        setupAppearanceSection()
        setupTextSection()
        setupShadowsSection()
        setupGradientSection()
    }
    
    private func setupHeaderSection() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = .systemBackground
        view.addSubview(headerContainer)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "Draggable Ball Test"
        headerLabel.font = .systemFont(ofSize: 22, weight: .bold)
        headerLabel.textColor = .label
        headerLabel.textAlignment = .center
        headerContainer.addSubview(headerLabel)
    }
    
    private func setupDraggableSection() {
        draggableContainer.translatesAutoresizingMaskIntoConstraints = false
        draggableContainer.backgroundColor = .secondarySystemBackground
        draggableContainer.layer.cornerRadius = 12
        draggableContainer.layer.masksToBounds = true
        view.addSubview(draggableContainer)
        
        draggableLabel.translatesAutoresizingMaskIntoConstraints = false
        draggableLabel.text = "Draggable Ball"
        draggableLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        draggableLabel.textColor = .label
        draggableContainer.addSubview(draggableLabel)
        
        draggableBall = DraggableBall(frame: .zero, fillText: "Change me")
        draggableBall.translatesAutoresizingMaskIntoConstraints = false
        draggableBall.updateFont(name: "Cheetah Kick - Personal Use")
        draggableBall.delegate = self
        draggableContainer.addSubview(draggableBall)
    }
    
    private func setupProgressSection() {
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.backgroundColor = .secondarySystemBackground
        progressContainer.layer.cornerRadius = 12
        progressContainer.layer.masksToBounds = true
        contentView.addSubview(progressContainer)
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "Progress"
        progressLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        progressLabel.textColor = .label
        progressContainer.addSubview(progressLabel)
        
        progressValueLabel.translatesAutoresizingMaskIntoConstraints = false
        progressValueLabel.text = "Progress: 0.00"
        progressValueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        progressValueLabel.textColor = .secondaryLabel
        progressValueLabel.textAlignment = .center
        progressContainer.addSubview(progressValueLabel)
        
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: progressContainer.topAnchor, constant: Layout.standardPadding),
            progressLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: Layout.standardPadding),
            
            progressValueLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: Layout.standardPadding),
            progressValueLabel.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor),
            progressValueLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: Layout.standardPadding),
            progressValueLabel.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -Layout.standardPadding),
            progressValueLabel.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: -Layout.standardPadding)
        ])
    }
    
    private func setupDelegateSection() {
        delegateContainer.translatesAutoresizingMaskIntoConstraints = false
        delegateContainer.backgroundColor = .secondarySystemBackground
        delegateContainer.layer.cornerRadius = 12
        delegateContainer.layer.masksToBounds = true
        contentView.addSubview(delegateContainer)

        delegateLabel.translatesAutoresizingMaskIntoConstraints = false
        delegateLabel.text = "Delegate"
        delegateLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        delegateLabel.textColor = .label
        delegateContainer.addSubview(delegateLabel)

        delegateStateLabel.translatesAutoresizingMaskIntoConstraints = false
        delegateStateLabel.text = "❔"
        delegateStateLabel.font = .systemFont(ofSize: 20)
        delegateStateLabel.textAlignment = .center

        delegateGreenCircleLabel.translatesAutoresizingMaskIntoConstraints = false
        delegateGreenCircleLabel.text = "🟢"
        delegateGreenCircleLabel.font = .systemFont(ofSize: 20)
        delegateGreenCircleLabel.textAlignment = .center
        delegateGreenCircleLabel.alpha = 0.3

        let emojiStackView = UIStackView(arrangedSubviews: [delegateStateLabel, delegateGreenCircleLabel])
        emojiStackView.translatesAutoresizingMaskIntoConstraints = false
        emojiStackView.axis = .horizontal
        emojiStackView.spacing = Layout.standardPadding
        emojiStackView.distribution = .fillEqually
        emojiStackView.alignment = .center
        delegateContainer.addSubview(emojiStackView)

        delegateDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        delegateDescriptionLabel.text = "Can trigger by only delegate"
        delegateDescriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        delegateDescriptionLabel.textColor = .tertiaryLabel
        delegateDescriptionLabel.textAlignment = .center
        delegateDescriptionLabel.numberOfLines = 0
        delegateContainer.addSubview(delegateDescriptionLabel)

        NSLayoutConstraint.activate([
            delegateLabel.topAnchor.constraint(equalTo: delegateContainer.topAnchor, constant: Layout.standardPadding),
            delegateLabel.leadingAnchor.constraint(equalTo: delegateContainer.leadingAnchor, constant: Layout.standardPadding),

            emojiStackView.topAnchor.constraint(equalTo: delegateLabel.bottomAnchor, constant: Layout.standardPadding),
            emojiStackView.leadingAnchor.constraint(equalTo: delegateContainer.leadingAnchor, constant: Layout.standardPadding),
            emojiStackView.trailingAnchor.constraint(equalTo: delegateContainer.trailingAnchor, constant: -Layout.standardPadding),

            delegateDescriptionLabel.topAnchor.constraint(equalTo: emojiStackView.bottomAnchor, constant: Layout.standardPadding),
            delegateDescriptionLabel.centerXAnchor.constraint(equalTo: delegateContainer.centerXAnchor),
            delegateDescriptionLabel.leadingAnchor.constraint(equalTo: delegateContainer.leadingAnchor, constant: Layout.standardPadding),
            delegateDescriptionLabel.trailingAnchor.constraint(equalTo: delegateContainer.trailingAnchor, constant: -Layout.standardPadding),
            delegateDescriptionLabel.bottomAnchor.constraint(equalTo: delegateContainer.bottomAnchor, constant: -Layout.standardPadding)
        ])
    }
    
    private func setupBallSizeSection() {
        ballSizeContainer.translatesAutoresizingMaskIntoConstraints = false
        ballSizeContainer.backgroundColor = .secondarySystemBackground
        ballSizeContainer.layer.cornerRadius = 12
        ballSizeContainer.layer.masksToBounds = true
        contentView.addSubview(ballSizeContainer)

        ballSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        ballSizeLabel.text = "Ball Size"
        ballSizeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        ballSizeLabel.textColor = .label
        ballSizeContainer.addSubview(ballSizeLabel)

        ballSizeSlider.translatesAutoresizingMaskIntoConstraints = false
        ballSizeSlider.minimumValue = 40
        ballSizeSlider.maximumValue = 80
        ballSizeSlider.value = Float(draggableBall.ballSize)
        ballSizeSlider.addTarget(self, action: #selector(ballSizeChanged), for: .valueChanged)
        ballSizeContainer.addSubview(ballSizeSlider)

        ballSizeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        ballSizeValueLabel.text = "\(Int(draggableBall.ballSize))"
        ballSizeValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        ballSizeValueLabel.textColor = .secondaryLabel
        ballSizeContainer.addSubview(ballSizeValueLabel)

        NSLayoutConstraint.activate([
            ballSizeLabel.topAnchor.constraint(equalTo: ballSizeContainer.topAnchor, constant: Layout.standardPadding),
            ballSizeLabel.leadingAnchor.constraint(equalTo: ballSizeContainer.leadingAnchor, constant: Layout.standardPadding),
            
            ballSizeSlider.topAnchor.constraint(equalTo: ballSizeLabel.bottomAnchor, constant: Layout.standardPadding),
            ballSizeSlider.leadingAnchor.constraint(equalTo: ballSizeContainer.leadingAnchor, constant: Layout.standardPadding),
            ballSizeSlider.trailingAnchor.constraint(equalTo: ballSizeValueLabel.leadingAnchor, constant: -8),
            ballSizeSlider.bottomAnchor.constraint(equalTo: ballSizeContainer.bottomAnchor, constant: -Layout.standardPadding),

            ballSizeValueLabel.centerYAnchor.constraint(equalTo: ballSizeSlider.centerYAnchor),
            ballSizeValueLabel.trailingAnchor.constraint(equalTo: ballSizeContainer.trailingAnchor, constant: -Layout.standardPadding),
            ballSizeValueLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupAppearanceSection() {
        appearanceContainer.translatesAutoresizingMaskIntoConstraints = false
        appearanceContainer.backgroundColor = .secondarySystemBackground
        appearanceContainer.layer.cornerRadius = 12
        appearanceContainer.layer.masksToBounds = true
        contentView.addSubview(appearanceContainer)

        appearanceLabel.translatesAutoresizingMaskIntoConstraints = false
        appearanceLabel.text = "Appearance"
        appearanceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        appearanceLabel.textColor = .label
        appearanceContainer.addSubview(appearanceLabel)

        indicatorSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorSizeLabel.text = "Indicator Size:"
        indicatorSizeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        indicatorSizeLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(indicatorSizeLabel)

        indicatorSizeSlider.translatesAutoresizingMaskIntoConstraints = false
        indicatorSizeSlider.minimumValue = 50
        indicatorSizeSlider.maximumValue = 185
        indicatorSizeSlider.value = Float(draggableBall.indicatorDisplaySize)
        indicatorSizeSlider.addTarget(self, action: #selector(appearanceChanged), for: .valueChanged)
        appearanceContainer.addSubview(indicatorSizeSlider)

        indicatorSizeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorSizeValueLabel.text = "\(Int(draggableBall.indicatorDisplaySize))"
        indicatorSizeValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        indicatorSizeValueLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(indicatorSizeValueLabel)

        indicatorTopOffsetLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorTopOffsetLabel.text = "Indicator Top Offset:"
        indicatorTopOffsetLabel.font = .systemFont(ofSize: 14, weight: .medium)
        indicatorTopOffsetLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(indicatorTopOffsetLabel)

        indicatorTopOffsetSlider.translatesAutoresizingMaskIntoConstraints = false
        indicatorTopOffsetSlider.minimumValue = -50
        indicatorTopOffsetSlider.maximumValue = 50
        indicatorTopOffsetSlider.value = Float(draggableBall.indicatorTopOffset)
        indicatorTopOffsetSlider.addTarget(self, action: #selector(appearanceChanged), for: .valueChanged)
        appearanceContainer.addSubview(indicatorTopOffsetSlider)

        indicatorTopOffsetValueLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorTopOffsetValueLabel.text = "\(Int(draggableBall.indicatorTopOffset))"
        indicatorTopOffsetValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        indicatorTopOffsetValueLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(indicatorTopOffsetValueLabel)

        capsuleHeightLabel.translatesAutoresizingMaskIntoConstraints = false
        capsuleHeightLabel.text = "Capsule Height:"
        capsuleHeightLabel.font = .systemFont(ofSize: 14, weight: .medium)
        capsuleHeightLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(capsuleHeightLabel)

        capsuleHeightSlider.translatesAutoresizingMaskIntoConstraints = false
        capsuleHeightSlider.minimumValue = 30
        capsuleHeightSlider.maximumValue = 80
        capsuleHeightSlider.value = Float(draggableBall.capsuleHeight)
        capsuleHeightSlider.addTarget(self, action: #selector(appearanceChanged), for: .valueChanged)
        appearanceContainer.addSubview(capsuleHeightSlider)

        capsuleHeightValueLabel.translatesAutoresizingMaskIntoConstraints = false
        capsuleHeightValueLabel.text = "\(Int(draggableBall.capsuleHeight))"
        capsuleHeightValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        capsuleHeightValueLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(capsuleHeightValueLabel)

        capsuleWidthLabel.translatesAutoresizingMaskIntoConstraints = false
        capsuleWidthLabel.text = "Capsule Width:"
        capsuleWidthLabel.font = .systemFont(ofSize: 14, weight: .medium)
        capsuleWidthLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(capsuleWidthLabel)

        capsuleWidthSlider.translatesAutoresizingMaskIntoConstraints = false
        capsuleWidthSlider.minimumValue = 150
        capsuleWidthSlider.maximumValue = 300
        capsuleWidthSlider.value = 250
        capsuleWidthSlider.addTarget(self, action: #selector(appearanceChanged), for: .valueChanged)
        capsuleWidthSlider.isEnabled = false
        appearanceContainer.addSubview(capsuleWidthSlider)

        capsuleWidthValueLabel.translatesAutoresizingMaskIntoConstraints = false
        capsuleWidthValueLabel.text = "\(Int(capsuleWidthSlider.value))"
        capsuleWidthValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        capsuleWidthValueLabel.textColor = .secondaryLabel
        appearanceContainer.addSubview(capsuleWidthValueLabel)

        capsuleWidthSwitch.translatesAutoresizingMaskIntoConstraints = false
        capsuleWidthSwitch.isOn = false
        capsuleWidthSwitch.addTarget(self, action: #selector(appearanceChanged), for: .valueChanged)
        appearanceContainer.addSubview(capsuleWidthSwitch)

        NSLayoutConstraint.activate([
            appearanceLabel.topAnchor.constraint(equalTo: appearanceContainer.topAnchor, constant: Layout.standardPadding),
            appearanceLabel.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),

            indicatorSizeLabel.topAnchor.constraint(equalTo: appearanceLabel.bottomAnchor, constant: Layout.standardPadding),
            indicatorSizeLabel.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            
            indicatorSizeSlider.topAnchor.constraint(equalTo: indicatorSizeLabel.bottomAnchor, constant: 8),
            indicatorSizeSlider.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            indicatorSizeSlider.trailingAnchor.constraint(equalTo: indicatorSizeValueLabel.leadingAnchor, constant: -8),
            
            indicatorSizeValueLabel.centerYAnchor.constraint(equalTo: indicatorSizeSlider.centerYAnchor),
            indicatorSizeValueLabel.trailingAnchor.constraint(equalTo: appearanceContainer.trailingAnchor, constant: -Layout.standardPadding),
            indicatorSizeValueLabel.widthAnchor.constraint(equalToConstant: 40),
            
            indicatorTopOffsetLabel.topAnchor.constraint(equalTo: indicatorSizeSlider.bottomAnchor, constant: Layout.standardPadding),
            indicatorTopOffsetLabel.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            
            indicatorTopOffsetSlider.topAnchor.constraint(equalTo: indicatorTopOffsetLabel.bottomAnchor, constant: 8),
            indicatorTopOffsetSlider.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            indicatorTopOffsetSlider.trailingAnchor.constraint(equalTo: indicatorTopOffsetValueLabel.leadingAnchor, constant: -8),
            
            indicatorTopOffsetValueLabel.centerYAnchor.constraint(equalTo: indicatorTopOffsetSlider.centerYAnchor),
            indicatorTopOffsetValueLabel.trailingAnchor.constraint(equalTo: appearanceContainer.trailingAnchor, constant: -Layout.standardPadding),
            indicatorTopOffsetValueLabel.widthAnchor.constraint(equalToConstant: 40),

            capsuleHeightLabel.topAnchor.constraint(equalTo: indicatorTopOffsetSlider.bottomAnchor, constant: Layout.standardPadding),
            capsuleHeightLabel.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            
            capsuleHeightSlider.topAnchor.constraint(equalTo: capsuleHeightLabel.bottomAnchor, constant: 8),
            capsuleHeightSlider.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            capsuleHeightSlider.trailingAnchor.constraint(equalTo: capsuleHeightValueLabel.leadingAnchor, constant: -8),
            
            capsuleHeightValueLabel.centerYAnchor.constraint(equalTo: capsuleHeightSlider.centerYAnchor),
            capsuleHeightValueLabel.trailingAnchor.constraint(equalTo: appearanceContainer.trailingAnchor, constant: -Layout.standardPadding),
            capsuleHeightValueLabel.widthAnchor.constraint(equalToConstant: 40),

            capsuleWidthLabel.topAnchor.constraint(equalTo: capsuleHeightSlider.bottomAnchor, constant: Layout.standardPadding),
            capsuleWidthLabel.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            
            capsuleWidthSwitch.centerYAnchor.constraint(equalTo: capsuleWidthLabel.centerYAnchor),
            capsuleWidthSwitch.trailingAnchor.constraint(equalTo: appearanceContainer.trailingAnchor, constant: -Layout.standardPadding),
            
            capsuleWidthSlider.topAnchor.constraint(equalTo: capsuleWidthLabel.bottomAnchor, constant: 8),
            capsuleWidthSlider.leadingAnchor.constraint(equalTo: appearanceContainer.leadingAnchor, constant: Layout.standardPadding),
            capsuleWidthSlider.trailingAnchor.constraint(equalTo: capsuleWidthValueLabel.leadingAnchor, constant: -8),
            capsuleWidthSlider.bottomAnchor.constraint(equalTo: appearanceContainer.bottomAnchor, constant: -Layout.standardPadding),
            
            capsuleWidthValueLabel.centerYAnchor.constraint(equalTo: capsuleWidthSlider.centerYAnchor),
            capsuleWidthValueLabel.trailingAnchor.constraint(equalTo: appearanceContainer.trailingAnchor, constant: -Layout.standardPadding),
            capsuleWidthValueLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTextSection() {
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.backgroundColor = .secondarySystemBackground
        textContainer.layer.cornerRadius = 12
        textContainer.layer.masksToBounds = true
        contentView.addSubview(textContainer)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "Text"
        textLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        textLabel.textColor = .label
        textContainer.addSubview(textLabel)
        
        textInputLabel.translatesAutoresizingMaskIntoConstraints = false
        textInputLabel.text = "Text Content:"
        textInputLabel.font = .systemFont(ofSize: 14, weight: .medium)
        textInputLabel.textColor = .secondaryLabel
        textContainer.addSubview(textInputLabel)
        
        textInputField.translatesAutoresizingMaskIntoConstraints = false
        textInputField.text = "Change me"
        textInputField.borderStyle = .roundedRect
        textInputField.font = .systemFont(ofSize: 16, weight: .medium)
        textInputField.placeholder = "Enter text..."
        textInputField.delegate = self
        textInputField.addTarget(self, action: #selector(textInputChanged), for: .editingChanged)
        textContainer.addSubview(textInputField)
        
        fontSelectionLabel.translatesAutoresizingMaskIntoConstraints = false
        fontSelectionLabel.text = "Font:"
        fontSelectionLabel.font = .systemFont(ofSize: 14, weight: .medium)
        fontSelectionLabel.textColor = .secondaryLabel
        textContainer.addSubview(fontSelectionLabel)
        
        fontSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        fontNames.enumerated().forEach { index, name in
            let title = name.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespaces) ?? name
            fontSegmentedControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        fontSegmentedControl.selectedSegmentIndex = 0
        fontSegmentedControl.addTarget(self, action: #selector(fontSelectionChanged), for: .valueChanged)
        textContainer.addSubview(fontSegmentedControl)
        
        fontSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        fontSizeLabel.text = "Font Size:"
        fontSizeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        fontSizeLabel.textColor = .secondaryLabel
        textContainer.addSubview(fontSizeLabel)
        
        fontSizeSlider.translatesAutoresizingMaskIntoConstraints = false
        fontSizeSlider.minimumValue = 10
        fontSizeSlider.maximumValue = 50
        fontSizeSlider.value = Float(selectedFontSize)
        fontSizeSlider.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        textContainer.addSubview(fontSizeSlider)
        
        fontSizeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        fontSizeValueLabel.text = "\(Int(selectedFontSize))"
        fontSizeValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        fontSizeValueLabel.textColor = .secondaryLabel
        fontSizeValueLabel.textAlignment = .left
        textContainer.addSubview(fontSizeValueLabel)
        
        colorPickerLabel.translatesAutoresizingMaskIntoConstraints = false
        colorPickerLabel.text = "Text Color:"
        colorPickerLabel.font = .systemFont(ofSize: 14, weight: .medium)
        colorPickerLabel.textColor = .secondaryLabel
        textContainer.addSubview(colorPickerLabel)
        
        currentColorHexLabel.translatesAutoresizingMaskIntoConstraints = false
        currentColorHexLabel.text = colorToHex(selectedTextColor)
        currentColorHexLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        currentColorHexLabel.textAlignment = .left
        textContainer.addSubview(currentColorHexLabel)
        
        colorPickerButton.translatesAutoresizingMaskIntoConstraints = false
        colorPickerButton.setTitle("Pick Color", for: .normal)
        colorPickerButton.backgroundColor = .systemGray4
        colorPickerButton.setTitleColor(.label, for: .normal)
        colorPickerButton.layer.cornerRadius = 8
        colorPickerButton.titleLabel?.adjustsFontSizeToFitWidth = true
        colorPickerButton.titleLabel?.minimumScaleFactor = 0.8
        colorPickerButton.addTarget(self, action: #selector(colorPickerTapped), for: .touchUpInside)
        
        colorPickerButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        colorPickerButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        colorPreviewCircle.translatesAutoresizingMaskIntoConstraints = false
        colorPreviewCircle.layer.cornerRadius = 12
        colorPreviewCircle.layer.masksToBounds = true
        
        colorPreviewCircle.setContentHuggingPriority(.required, for: .horizontal)
        colorPreviewCircle.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let colorPreviewTapGesture = UITapGestureRecognizer(target: self, action: #selector(colorPreviewTapped))
        colorPreviewCircle.addGestureRecognizer(colorPreviewTapGesture)
        colorPreviewCircle.isUserInteractionEnabled = true
        
        colorPickerContainerView.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(colorPickerContainerView)
        
        colorPickerContainerView.addSubview(colorPreviewCircle)
        colorPickerContainerView.addSubview(colorPickerButton)
        
        colorPickerContainerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        colorPickerContainerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: Layout.standardPadding),
            textLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            
            textInputLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: Layout.standardPadding),
            textInputLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            
            textInputField.topAnchor.constraint(equalTo: textInputLabel.bottomAnchor, constant: 8),
            textInputField.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            textInputField.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -Layout.standardPadding),
            textInputField.heightAnchor.constraint(equalToConstant: 44),
            
            fontSelectionLabel.topAnchor.constraint(equalTo: textInputField.bottomAnchor, constant: Layout.standardPadding),
            fontSelectionLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            
            fontSegmentedControl.topAnchor.constraint(equalTo: fontSelectionLabel.bottomAnchor, constant: 8),
            fontSegmentedControl.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            fontSegmentedControl.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -Layout.standardPadding),
            fontSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            fontSizeLabel.topAnchor.constraint(equalTo: fontSegmentedControl.bottomAnchor, constant: Layout.standardPadding),
            fontSizeLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            
            fontSizeValueLabel.topAnchor.constraint(equalTo: fontSizeLabel.topAnchor),
            fontSizeValueLabel.leadingAnchor.constraint(equalTo: fontSizeLabel.trailingAnchor, constant: 8),
            fontSizeValueLabel.heightAnchor.constraint(equalTo: fontSizeLabel.heightAnchor),
            
            fontSizeSlider.topAnchor.constraint(equalTo: fontSizeLabel.bottomAnchor, constant: 8),
            fontSizeSlider.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            fontSizeSlider.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -Layout.standardPadding),
            
            colorPickerLabel.topAnchor.constraint(equalTo: fontSizeSlider.bottomAnchor, constant: Layout.standardPadding),
            colorPickerLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            
            currentColorHexLabel.centerYAnchor.constraint(equalTo: colorPickerLabel.centerYAnchor),
            currentColorHexLabel.leadingAnchor.constraint(equalTo: colorPickerLabel.trailingAnchor, constant: 8),
            currentColorHexLabel.widthAnchor.constraint(equalToConstant: 80),
            currentColorHexLabel.heightAnchor.constraint(equalToConstant: 24),
            
            colorPickerContainerView.topAnchor.constraint(equalTo: colorPickerLabel.bottomAnchor, constant: Layout.standardPadding),
            colorPickerContainerView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: Layout.standardPadding),
            colorPickerContainerView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -Layout.standardPadding),
            colorPickerContainerView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: -Layout.standardPadding),
            
            colorPreviewCircle.leadingAnchor.constraint(equalTo: colorPickerContainerView.leadingAnchor),
            colorPreviewCircle.centerYAnchor.constraint(equalTo: colorPickerContainerView.centerYAnchor),
            colorPreviewCircle.widthAnchor.constraint(equalToConstant: 24),
            colorPreviewCircle.heightAnchor.constraint(equalToConstant: 24),
            
            colorPickerButton.leadingAnchor.constraint(equalTo: colorPreviewCircle.trailingAnchor, constant: 16),
            colorPickerButton.trailingAnchor.constraint(lessThanOrEqualTo: colorPickerContainerView.trailingAnchor),
            colorPickerButton.centerYAnchor.constraint(equalTo: colorPickerContainerView.centerYAnchor),
            colorPickerButton.heightAnchor.constraint(equalToConstant: 40),
            colorPickerButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            colorPickerContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])
    }
    
    private func setupShadowsSection() {
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = .secondarySystemBackground
        shadowContainer.layer.cornerRadius = 12
        shadowContainer.layer.masksToBounds = true
        contentView.addSubview(shadowContainer)
        
        shadowLabel.translatesAutoresizingMaskIntoConstraints = false
        shadowLabel.text = "Shadows"
        shadowLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        shadowLabel.textColor = .label
        shadowContainer.addSubview(shadowLabel)
        
        cornerShadowLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerShadowLabel.text = "Corner Inner Shadow"
        cornerShadowLabel.font = .systemFont(ofSize: 14, weight: .medium)
        cornerShadowLabel.textColor = .secondaryLabel
        shadowContainer.addSubview(cornerShadowLabel)
        
        cornerShadowSwitch.translatesAutoresizingMaskIntoConstraints = false
        cornerShadowSwitch.isOn = draggableBall.showCornerInnerShadow
        cornerShadowSwitch.addTarget(self, action: #selector(shadowSettingsChanged), for: .valueChanged)
        shadowContainer.addSubview(cornerShadowSwitch)
        
        cornerShadowAlphaSlider.translatesAutoresizingMaskIntoConstraints = false
        cornerShadowAlphaSlider.minimumValue = 0.0
        cornerShadowAlphaSlider.maximumValue = 1.0
        cornerShadowAlphaSlider.value = Float(draggableBall.cornerInnerShadowAlpha)
        cornerShadowAlphaSlider.addTarget(self, action: #selector(shadowSettingsChanged), for: .valueChanged)
        shadowContainer.addSubview(cornerShadowAlphaSlider)
        
        cornerShadowAlphaValueLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerShadowAlphaValueLabel.text = String(format: "%.2f", draggableBall.cornerInnerShadowAlpha)
        cornerShadowAlphaValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        cornerShadowAlphaValueLabel.textColor = .secondaryLabel
        shadowContainer.addSubview(cornerShadowAlphaValueLabel)
        
        topShadowLabel.translatesAutoresizingMaskIntoConstraints = false
        topShadowLabel.text = "Top Inner Shadow"
        topShadowLabel.font = .systemFont(ofSize: 14, weight: .medium)
        topShadowLabel.textColor = .secondaryLabel
        shadowContainer.addSubview(topShadowLabel)
        
        topShadowSwitch.translatesAutoresizingMaskIntoConstraints = false
        topShadowSwitch.isOn = draggableBall.showTopInnerShadow
        topShadowSwitch.addTarget(self, action: #selector(shadowSettingsChanged), for: .valueChanged)
        shadowContainer.addSubview(topShadowSwitch)
        
        topShadowAlphaSlider.translatesAutoresizingMaskIntoConstraints = false
        topShadowAlphaSlider.minimumValue = 0.0
        topShadowAlphaSlider.maximumValue = 1.0
        topShadowAlphaSlider.value = Float(draggableBall.topInnerShadowAlpha)
        topShadowAlphaSlider.addTarget(self, action: #selector(shadowSettingsChanged), for: .valueChanged)
        shadowContainer.addSubview(topShadowAlphaSlider)
        
        topShadowAlphaValueLabel.translatesAutoresizingMaskIntoConstraints = false
        topShadowAlphaValueLabel.text = String(format: "%.2f", draggableBall.topInnerShadowAlpha)
        topShadowAlphaValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        topShadowAlphaValueLabel.textColor = .secondaryLabel
        shadowContainer.addSubview(topShadowAlphaValueLabel)
        
        NSLayoutConstraint.activate([
            shadowLabel.topAnchor.constraint(equalTo: shadowContainer.topAnchor, constant: Layout.standardPadding),
            shadowLabel.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor, constant: Layout.standardPadding),
            
            cornerShadowLabel.topAnchor.constraint(equalTo: shadowLabel.bottomAnchor, constant: Layout.standardPadding),
            cornerShadowLabel.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor, constant: Layout.standardPadding),
            
            cornerShadowSwitch.centerYAnchor.constraint(equalTo: cornerShadowLabel.centerYAnchor),
            cornerShadowSwitch.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor, constant: -Layout.standardPadding),
            
            cornerShadowAlphaSlider.topAnchor.constraint(equalTo: cornerShadowLabel.bottomAnchor, constant: 8),
            cornerShadowAlphaSlider.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor, constant: Layout.standardPadding),
            cornerShadowAlphaSlider.trailingAnchor.constraint(equalTo: cornerShadowAlphaValueLabel.leadingAnchor, constant: -8),
            
            cornerShadowAlphaValueLabel.centerYAnchor.constraint(equalTo: cornerShadowAlphaSlider.centerYAnchor),
            cornerShadowAlphaValueLabel.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor, constant: -Layout.standardPadding),
            cornerShadowAlphaValueLabel.widthAnchor.constraint(equalToConstant: 40),
            
            topShadowLabel.topAnchor.constraint(equalTo: cornerShadowAlphaSlider.bottomAnchor, constant: Layout.standardPadding),
            topShadowLabel.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor, constant: Layout.standardPadding),
            
            topShadowSwitch.centerYAnchor.constraint(equalTo: topShadowLabel.centerYAnchor),
            topShadowSwitch.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor, constant: -Layout.standardPadding),
            
            topShadowAlphaSlider.topAnchor.constraint(equalTo: topShadowLabel.bottomAnchor, constant: 8),
            topShadowAlphaSlider.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor, constant: Layout.standardPadding),
            topShadowAlphaSlider.trailingAnchor.constraint(equalTo: topShadowAlphaValueLabel.leadingAnchor, constant: -8),
            
            topShadowAlphaValueLabel.centerYAnchor.constraint(equalTo: topShadowAlphaSlider.centerYAnchor),
            topShadowAlphaValueLabel.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor, constant: -Layout.standardPadding),
            topShadowAlphaValueLabel.widthAnchor.constraint(equalToConstant: 40),
            
            topShadowAlphaSlider.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor, constant: -Layout.standardPadding)
        ])
    }

    private func setupGradientSection() {
        gradientContainer.translatesAutoresizingMaskIntoConstraints = false
        gradientContainer.backgroundColor = .secondarySystemBackground
        gradientContainer.layer.cornerRadius = 12
        gradientContainer.layer.masksToBounds = true
        contentView.addSubview(gradientContainer)

        gradientLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientLabel.text = "Fill Gradient"
        gradientLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        gradientLabel.textColor = .label
        gradientContainer.addSubview(gradientLabel)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Layout.standardPadding
        gradientContainer.addSubview(stackView)

        for i in 0..<4 {
            let colorControlStack = createGradientColorControl(for: i)
            stackView.addArrangedSubview(colorControlStack)
        }

        NSLayoutConstraint.activate([
            gradientLabel.topAnchor.constraint(equalTo: gradientContainer.topAnchor, constant: Layout.standardPadding),
            gradientLabel.leadingAnchor.constraint(equalTo: gradientContainer.leadingAnchor, constant: Layout.standardPadding),
            
            stackView.topAnchor.constraint(equalTo: gradientLabel.bottomAnchor, constant: Layout.standardPadding),
            stackView.leadingAnchor.constraint(equalTo: gradientContainer.leadingAnchor, constant: Layout.standardPadding),
            stackView.trailingAnchor.constraint(equalTo: gradientContainer.trailingAnchor, constant: -Layout.standardPadding),
            stackView.bottomAnchor.constraint(equalTo: gradientContainer.bottomAnchor, constant: -Layout.standardPadding)
        ])
    }

    private func createGradientColorControl(for index: Int) -> UIStackView {
        guard index < selectedGradientColors.count else {
            let colorView = UIView()
            colorView.backgroundColor = .systemGray
            colorView.tag = index
            colorView.layer.cornerRadius = 12
            colorView.layer.masksToBounds = true
            
            let hexField = UITextField()
            hexField.text = "#8E8E93"
            hexField.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
            hexField.borderStyle = .roundedRect
            hexField.autocapitalizationType = .allCharacters
            hexField.tag = index
            hexField.delegate = self
            
            let stackView = UIStackView(arrangedSubviews: [colorView, hexField])
            stackView.axis = .horizontal
            stackView.spacing = Layout.standardPadding
            stackView.distribution = .fill
            
            NSLayoutConstraint.activate([
                colorView.widthAnchor.constraint(equalToConstant: 40),
                colorView.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            return stackView
        }
        
        let colorView = UIView()
        colorView.backgroundColor = selectedGradientColors[index]
        colorView.tag = index
        colorView.layer.cornerRadius = 12
        colorView.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gradientColorTapped(_:)))
        colorView.addGestureRecognizer(tapGesture)
        gradientColorViews.append(colorView)

        let hexField = UITextField()
        hexField.text = colorToHex(selectedGradientColors[index])
        hexField.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        hexField.borderStyle = .roundedRect
        hexField.autocapitalizationType = .allCharacters
        hexField.tag = index
        hexField.delegate = self
        gradientHexFields.append(hexField)

        let stackView = UIStackView(arrangedSubviews: [colorView, hexField])
        stackView.axis = .horizontal
        stackView.spacing = Layout.standardPadding
        stackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 24),
            colorView.heightAnchor.constraint(equalToConstant: 24)
        ])

        return stackView
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: Layout.headerHeight),

            headerLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            draggableContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: Layout.sectionSpacing),
            draggableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.standardPadding),
            draggableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.standardPadding),

            draggableLabel.topAnchor.constraint(equalTo: draggableContainer.topAnchor, constant: Layout.standardPadding),
            draggableLabel.leadingAnchor.constraint(equalTo: draggableContainer.leadingAnchor, constant: Layout.standardPadding),

            draggableBall.topAnchor.constraint(equalTo: draggableLabel.bottomAnchor, constant: Layout.standardPadding),
            draggableBall.leadingAnchor.constraint(equalTo: draggableContainer.leadingAnchor, constant: Layout.standardPadding * 3),
            draggableBall.trailingAnchor.constraint(equalTo: draggableContainer.trailingAnchor, constant: -Layout.standardPadding * 3),
            draggableBall.heightAnchor.constraint(equalToConstant: 80),
            draggableBall.bottomAnchor.constraint(equalTo: draggableContainer.bottomAnchor, constant: -Layout.standardPadding),

            scrollView.topAnchor.constraint(equalTo: draggableContainer.bottomAnchor, constant: Layout.sectionSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            progressContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            progressContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardPadding),
            progressContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardPadding),
            
            delegateContainer.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: Layout.sectionSpacing),
            delegateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardPadding),
            delegateContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardPadding),
            
            ballSizeContainer.topAnchor.constraint(equalTo: delegateContainer.bottomAnchor, constant: Layout.sectionSpacing),
            ballSizeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardPadding),
            ballSizeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardPadding),

            appearanceContainer.topAnchor.constraint(equalTo: ballSizeContainer.bottomAnchor, constant: Layout.sectionSpacing),
            appearanceContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardPadding),
            appearanceContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardPadding),

            textContainer.topAnchor.constraint(equalTo: appearanceContainer.bottomAnchor, constant: Layout.sectionSpacing),
            textContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardPadding),
            textContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardPadding),
            
            shadowContainer.topAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: Layout.sectionSpacing),
            shadowContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardPadding),
            shadowContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardPadding),
            
            gradientContainer.topAnchor.constraint(equalTo: shadowContainer.bottomAnchor, constant: Layout.sectionSpacing),
            gradientContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardPadding),
            gradientContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardPadding),
            gradientContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.sectionSpacing)
        ])
    }
    
    // MARK: - Draggable Ball Setup
    private func setupDraggableBall() {
        draggableBall.fillGradientColors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemPurple.cgColor,
            UIColor.systemPink.cgColor
        ]
        draggableBall.fontColor = .white
        draggableBall.showCornerInnerShadow = true
        draggableBall.showTopInnerShadow = true
//        draggableBall.updateIndicatorImage(UIImage(named: "arrows"))
        
        updateColorPreviewCircle()
    }
    
    // MARK: - Ball Size Section Actions
    @objc private func ballSizeChanged(_ slider: UISlider) {
        let newSize = CGFloat(slider.value)
        ballSizeValueLabel.text = "\(Int(newSize))"
        draggableBall.updateBallSize(newSize)
    }
    
    // MARK: - Appearance Section Actions
    @objc private func appearanceChanged() {
        // Indicator Size
        let newSize = CGFloat(indicatorSizeSlider.value)
        indicatorSizeValueLabel.text = "\(Int(newSize))"
        draggableBall.updateIndicatorSize(newSize)

        // Indicator Top Offset
        let newOffset = CGFloat(indicatorTopOffsetSlider.value)
        indicatorTopOffsetValueLabel.text = "\(Int(newOffset))"
        draggableBall.updateIndicatorTopOffset(newOffset)

        // Capsule Height
        let newHeight = CGFloat(capsuleHeightSlider.value)
        capsuleHeightValueLabel.text = "\(Int(newHeight))"
        draggableBall.updateCapsuleHeight(newHeight)
        
        // Capsule Width
        let useCustomWidth = capsuleWidthSwitch.isOn
        capsuleWidthSlider.isEnabled = useCustomWidth
        
        if useCustomWidth {
            let newWidth = CGFloat(capsuleWidthSlider.value)
            capsuleWidthValueLabel.text = "\(Int(newWidth))"
            draggableBall.updateCapsuleWidth(newWidth)
        } else {
            draggableBall.updateCapsuleWidth(nil)
            capsuleWidthValueLabel.text = "Full"
        }
    }
    
    // MARK: - Text Section Actions
    @objc private func textInputChanged() {
        guard let text = textInputField.text else { return }
        draggableBall.updateText(text)
    }
    
    @objc private func fontSizeChanged(_ slider: UISlider) {
        selectedFontSize = CGFloat(slider.value)
        fontSizeValueLabel.text = "\(Int(selectedFontSize))"
        
        // Update font size only
        if let draggableBall = draggableBall {
            draggableBall.updateFontSize(selectedFontSize)
        }
    }
    
    @objc private func fontSelectionChanged(_ segmentedControl: UISegmentedControl) {
        selectedFontIndex = segmentedControl.selectedSegmentIndex
        print("Selected font: \(fontNames[selectedFontIndex])")
        
        // Update font
        if let draggableBall = draggableBall {
            draggableBall.updateFont(name: fontNames[selectedFontIndex], size: selectedFontSize, color: selectedTextColor)
        }
    }
    
    // MARK: - Shadow Section Actions
    @objc private func shadowSettingsChanged() {
        let showCorner = cornerShadowSwitch.isOn
        let cornerAlpha = CGFloat(cornerShadowAlphaSlider.value)
        let showTop = topShadowSwitch.isOn
        let topAlpha = CGFloat(topShadowAlphaSlider.value)
        
        cornerShadowAlphaValueLabel.text = String(format: "%.2f", cornerAlpha)
        topShadowAlphaValueLabel.text = String(format: "%.2f", topAlpha)
        
        draggableBall.updateCornerInnerShadow(show: showCorner, alpha: cornerAlpha)
        draggableBall.updateTopInnerShadow(show: showTop, alpha: topAlpha)
    }
    
    // MARK: - Gradient Section Actions
    @objc private func gradientColorTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        editingGradientColorIndex = index
        
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = selectedGradientColors[index]
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }

    private func updateDraggableGradient() {
        let cgColors = selectedGradientColors.map { $0.cgColor }
        draggableBall.updateFillGradientColors(cgColors)
    }

    @objc private func colorPickerTapped() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = selectedTextColor
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }
    
    @objc private func colorPreviewTapped() {
        colorPickerTapped()
    }
    
    private func updateColorPreviewCircle() {
        colorPreviewCircle.backgroundColor = selectedTextColor
        currentColorHexLabel.text = colorToHex(selectedTextColor)
    }
    
    private func colorToHex(_ color: UIColor) -> String {
        return color.toHex()
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        let textFieldFrame = textInputField.convert(textInputField.bounds, to: view)
        let textFieldBottom = textFieldFrame.maxY
        let keyboardTop = view.bounds.height - keyboardHeight
        
        if textFieldBottom > keyboardTop {
            let offsetNeeded = textFieldBottom - keyboardTop + Layout.standardPadding
            
            UIView.animate(withDuration: animationDuration) {
                self.scrollView.contentOffset.y += offsetNeeded
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentOffset.y = 0
        }
    }
}

// MARK: - DraggableBallDelegate
extension TestDragableVC: DraggableBallDelegate {
    
    func draggableBall(_ draggableBall: DraggableBall, didUpdateProgress progress: CGFloat) {
        // Update progress label dynamically
        progressValueLabel.text = String(format: "Progress: %.2f", progress)
        
        /*
         or you can use
         progressValueLabel.text = String(format: "%.2f", draggableBall.currentProgress)
         
         But it will only change the label after release your finger. Because it gets the value from contraints.
         The progress parameter is more real-time, it gets the value from transform during dragging.
         After the end of dragging, the transform values transfer to constraint values
          */
        
        // Trigger green circle animation
        delegateGreenCircleLabel.alpha = 1.0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.delegateGreenCircleLabel.alpha = 0.3
        }
    }
    
    func draggableBallDidReturnToStart(_ draggableBall: DraggableBall) {
        // Handle when drag returns to start
        print("Ball returned to start!")
        delegateStateLabel.text = "🎬"
    }

    func draggableBallDidReachEnd(_ draggableBall: DraggableBall) {
        // Handle when drag reaches the end
        print("Ball reached end!")
        delegateStateLabel.text = "🎉"
    }
}

// MARK: - UIColorPickerViewControllerDelegate
extension TestDragableVC: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if let index = editingGradientColorIndex {
            // Gradient color updated
            let newColor = viewController.selectedColor
            selectedGradientColors[index] = newColor
            gradientColorViews[index].backgroundColor = newColor
            gradientHexFields[index].text = colorToHex(newColor)
            updateDraggableGradient()
        } else {
            // Main text color updated
            selectedTextColor = viewController.selectedColor
            updateColorPreviewCircle()
            if let draggableBall = draggableBall {
                draggableBall.updateFontColor(selectedTextColor)
            }
        }
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        editingGradientColorIndex = nil
    }
}


// MARK: - UITextFieldDelegate
extension TestDragableVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textInputField {
            // Handle text input field
            guard let text = textField.text else { return }
            draggableBall.updateText(text)
        } else {
            // Handle gradient hex color fields
            guard let text = textField.text else { return }
            let index = textField.tag
            
            if let color = UIColor(hex: text) {
                selectedGradientColors[index] = color
                gradientColorViews[index].backgroundColor = color
                updateDraggableGradient()
            } else {
                textField.text = colorToHex(selectedGradientColors[index])
            }
        }
    }
}

// MARK: - Preview
struct TestDragableVC_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            TestDragableVC()
        }
    }
}
