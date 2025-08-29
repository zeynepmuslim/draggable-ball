//
//  DraggableBall.swift
//  BallAnimation
//
//  Created by Zeynep Müslim on 4.04.2025.
//

import UIKit
import SwiftUI


// MARK: - DraggableBallDelegate Protocol
protocol DraggableBallDelegate: AnyObject {
    /// Notifies the delegate that the drag progress has been updated.
    /// - Parameters:
    ///   - draggableBall: The view that triggered the event.
    ///   - progress: The new progress value, from 0.0 to 1.0.
    func draggableBall(_ draggableBall: DraggableBall, didUpdateProgress progress: CGFloat)
    
    /// Notifies the delegate that the drag has reached the end (progress >= 1.0).
    /// - Parameter draggableBall: The view that triggered the event.
    func draggableBallDidReachEnd(_ draggableBall: DraggableBall)
    
    /// Notifies the delegate that the drag has returned to the start (progress <= 0.0).
    /// - Parameter draggableBall: The view that triggered the event.
    func draggableBallDidReturnToStart(_ draggableBall: DraggableBall)
}

class DraggableBall: UIView {
    weak var delegate: DraggableBallDelegate?
    
    // MARK: - Private Properties
    public var capsuleHeight: CGFloat = 40
    public var ballSize: CGFloat = 60
    private var padding: CGFloat {
        (capsuleHeight - ballSize) / 2
    }
    
    private let indicatorSize = CGSize(width: 150, height: 150)
    private let maxIndicatorRotationAngle: CGFloat = .pi
    public var indicatorImage: UIImage? = UIImage(named: "arrows")
    public var indicatorDisplaySize: CGFloat = 150
    public var indicatorTopOffset: CGFloat = -5
    public var capsuleWidth: CGFloat?
    
    private var capsuleView: UIView!
    private var ballView: UIView!
    private var fillView: UIView!
    private var underBallShadowView: UIView!
    private var indicatorImageView: UIImageView!
    private var fillLabel: UILabel!
    
    private var shadowGradientLayer: CAGradientLayer!
    private var ballGradientLayer: CAGradientLayer!
    private var fillGradientLayer: CAGradientLayer!
    private var capsuleInnerShadowLayer: CALayer!
    private var capsuleTopInnerShadowLayer: CALayer!
    
    private var ballLeadingConstraint: NSLayoutConstraint!
    private var fillWidthConstraint: NSLayoutConstraint!
    private var ballHeightConstraint: NSLayoutConstraint!
    private var ballWidthConstraint: NSLayoutConstraint!
    private var underBallShadowViewWidthConstraint: NSLayoutConstraint!
    private var underBallShadowViewHeightConstraint: NSLayoutConstraint!
    private var capsuleHeightConstraint: NSLayoutConstraint!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var indicatorWidthConstraint: NSLayoutConstraint!
    private var indicatorHeightConstraint: NSLayoutConstraint!
    private var indicatorTopConstraint: NSLayoutConstraint!
    
    private var capsuleLeadingConstraint: NSLayoutConstraint!
    private var capsuleTrailingConstraint: NSLayoutConstraint!
    private var capsuleWidthConstraint: NSLayoutConstraint!
    private var capsuleCenterXConstraint: NSLayoutConstraint!
    
    private var hintAnimationCompleted = false
    private var hintAnimationAmount = 0.05
    private var dragStartLeadingConstant: CGFloat = 0.0
    
    // Timer properties for hint animation
    private var hintTimer: Timer?
    private let hintTimerInterval: TimeInterval = 2.0 // 2 seconds between hint animations
    
    // Drag state tracking
    private var isDragging = false
    
    private let progressTolerance: CGFloat = 0.001 // Tolerance for floating-point comparisons
    
    // MARK: - Public Customization Propertiess
    
    /// The current progress of the draggable ball, from 0.0 to 1.0.
    public var currentProgress: CGFloat {
        return getCurrentProgress()
    }
    
    /// Returns `true` if the drag progress has reached 100%.
    public var isCompleted: Bool {
        return currentProgress >= 0.99
    }
    
    /// The array of colors to use for the fill gradient. Defaults to a Teal/Blue/Purple/Pink gradient.
    public var fillGradientColors: [CGColor] = [
        UIColor.systemTeal.cgColor,
        UIColor.systemBlue.cgColor,
        UIColor.systemPurple.cgColor,
        UIColor.systemPink.cgColor,
    ] {
        didSet {
            if let fillGradientLayer = fillGradientLayer {
                fillGradientLayer.colors = fillGradientColors
            }
        }
    }
    
    /// The text to display centered within the fill view.
    private let fillText: String?
    
    public var fontName: String = "Bhineka" // can change
    
    /// The color of the text displayed in the fill view. Defaults to white.
    public var fontColor: UIColor = .white
    
    /// Whether to show the 4-corner inner shadow. Defaults to true.
    public var showCornerInnerShadow: Bool = true
    
    /// Whether to show the top inner shadow. Defaults to true.
    public var showTopInnerShadow: Bool = true
    
    /// Alpha value for the 4-corner inner shadow. Range: 0.0 to 1.0. Defaults to 0.1
    public var cornerInnerShadowAlpha: CGFloat = 0.1
    
    /// Alpha value for the top inner shadow. Range: 0.0 to 1.0. Defaults to 0.1.
    public var topInnerShadowAlpha: CGFloat = 0.1
    
    // MARK: - Initialization
    
    // Initializer
    init(frame: CGRect, fillText: String?, showCornerInnerShadow: Bool = true, showTopInnerShadow: Bool = true, cornerInnerShadowAlpha: CGFloat = 0.1, topInnerShadowAlpha: CGFloat = 0.1) {
        self.fillText = fillText
        self.showCornerInnerShadow = showCornerInnerShadow
        self.showTopInnerShadow = showTopInnerShadow
        self.cornerInnerShadowAlpha = cornerInnerShadowAlpha
        self.topInnerShadowAlpha = topInnerShadowAlpha
        super.init(frame: frame)
        commonInit()
    }
    
    // Required initializer for Storyboards/XIBs
    required init?(coder: NSCoder) {
        self.fillText = "DRAG"
        self.showCornerInnerShadow = true
        self.showTopInnerShadow = true
        self.cornerInnerShadowAlpha = 0.1
        self.topInnerShadowAlpha = 0.1
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupViewsInternal() // View setup
        setupGestureRecognizer() // Gesture setup
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() { // Called when the view's frame changes
        super.layoutSubviews()
        updateGradientFrames()    // Update frames on subsequent layouts
        
        // Start hint animation only once after a delay to avoid layoutSubviews chaos
        if !hintAnimationCompleted && bounds.width > 0 {
            hintAnimationCompleted = true // Prevent multiple calls immediately
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.performSimpleHintAnimation()
                // Start the timer after the first animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
                    self?.checkProgressAndManageTimer()
                }
            }
        }
    }
    
    private func updateGradientFrames() {
        // Update gradient layer frames if they exist and views have bounds
        if underBallShadowView != nil && underBallShadowView.bounds != .zero && shadowGradientLayer != nil {
            shadowGradientLayer.frame = underBallShadowView.bounds
        }
        if ballView != nil && ballView.bounds != .zero && ballGradientLayer != nil {
            ballGradientLayer.frame = ballView.bounds
        }
        if fillView != nil && capsuleView != nil && capsuleView.bounds != .zero && fillGradientLayer != nil {
            fillGradientLayer.frame = capsuleView.bounds
        }
        if capsuleView != nil && capsuleView.bounds != .zero && capsuleInnerShadowLayer != nil {
            capsuleInnerShadowLayer.frame = capsuleView.bounds
        }
        if capsuleView != nil && capsuleView.bounds != .zero && capsuleTopInnerShadowLayer != nil {
            capsuleTopInnerShadowLayer.frame = capsuleView.bounds
        }
    }
    
    // MARK: - Setup Logic
    
    private func setupViewsInternal() {
        capsuleView = UIView()
        capsuleView.layer.cornerRadius = capsuleHeight / 2
        capsuleView.layer.masksToBounds = true
        self.addSubview(capsuleView)
        
        fillView = UIView()
        fillView.layer.masksToBounds = true
        capsuleView.addSubview(fillView)
        
        fillLabel = UILabel()
        fillLabel.text = self.fillText ?? "Placeholder"
        fillLabel.textAlignment = .center
        fillLabel.textColor = self.fontColor
        
        if let customFont = UIFont(name: fontName, size: 20) {
            fillLabel.font = customFont
        } else {
            fillLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            print("Custom font '\(fontName)' not available, using system font")
        }
        fillView.addSubview(fillLabel)
        setupFillGradient()
        
        setupCapsuleInnerShadow()
        setupCapsuleTopInnerShadow()
        
        underBallShadowView = UIView()
        self.addSubview(underBallShadowView)
        setupBallShadowGradient()
        
        ballView = UIView()
        ballView.layer.cornerRadius = ballSize / 2
        ballView.layer.masksToBounds = true
        self.addSubview(ballView)
        setupBallGradient()
        
        indicatorImageView = UIImageView()
        indicatorImageView.image = indicatorImage
        indicatorImageView.contentMode = .scaleAspectFit
        ballView.addSubview(indicatorImageView) // added to ball not view itself
        // updateIndicatorRotation(progress: 20) // We set it in the default position
        
        // Set translatesAutoresizingMaskIntoConstraints to false for all views
        capsuleView.translatesAutoresizingMaskIntoConstraints = false
        fillView.translatesAutoresizingMaskIntoConstraints = false
        fillLabel.translatesAutoresizingMaskIntoConstraints = false
        underBallShadowView.translatesAutoresizingMaskIntoConstraints = false
        ballView.translatesAutoresizingMaskIntoConstraints = false
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        let shadowHeight = ballSize * 3
        let shadowWidth = ballSize * 3
        ballHeightConstraint = ballView.heightAnchor.constraint(equalToConstant: ballSize)
        ballWidthConstraint = ballView.widthAnchor.constraint(equalToConstant: ballSize)
        underBallShadowViewWidthConstraint = underBallShadowView.widthAnchor.constraint(equalToConstant: shadowWidth)
        underBallShadowViewHeightConstraint = underBallShadowView.heightAnchor.constraint(equalToConstant: shadowHeight)
        capsuleHeightConstraint = capsuleView.heightAnchor.constraint(equalToConstant: capsuleHeight)
        
        indicatorWidthConstraint = indicatorImageView.widthAnchor.constraint(equalToConstant: indicatorDisplaySize)
        indicatorHeightConstraint = indicatorImageView.heightAnchor.constraint(equalToConstant: indicatorDisplaySize)
        indicatorTopConstraint = indicatorImageView.topAnchor.constraint(equalTo: capsuleView.topAnchor, constant: indicatorTopOffset)
        
        capsuleLeadingConstraint = capsuleView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        capsuleTrailingConstraint = capsuleView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        capsuleCenterXConstraint = capsuleView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        
        // Adjust constraints to be relative to 'self' (DraggableBall) where appropriate
        NSLayoutConstraint.activate([
            // Capsule constraints (relative to DraggableBall bounds)
            capsuleView.centerYAnchor.constraint(equalTo: self.centerYAnchor), // Center vertically in DraggableBall
            capsuleHeightConstraint,
            
            fillView.leadingAnchor.constraint(equalTo: capsuleView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: capsuleView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: capsuleView.bottomAnchor),
            
            fillLabel.centerXAnchor.constraint(equalTo: capsuleView.centerXAnchor),
            fillLabel.centerYAnchor.constraint(equalTo: fillView.centerYAnchor),
            fillLabel.heightAnchor.constraint(equalTo: capsuleView.heightAnchor, multiplier: 0.8), // Relative to capsule height
            
            ballView.centerYAnchor.constraint(equalTo: capsuleView.centerYAnchor),
            ballHeightConstraint,
            ballWidthConstraint,
            
            underBallShadowView.centerXAnchor.constraint(equalTo: ballView.centerXAnchor),
            underBallShadowView.centerYAnchor.constraint(equalTo: ballView.bottomAnchor),
            underBallShadowViewWidthConstraint,
            underBallShadowViewHeightConstraint,
            
            indicatorTopConstraint,
            indicatorWidthConstraint,
            indicatorHeightConstraint,
            indicatorImageView.centerXAnchor.constraint(equalTo: ballView.centerXAnchor)
        ])
        
        updateCapsuleWidthConstraints()
        
        // Constraints to be modified by gesture
        ballLeadingConstraint = ballView.leadingAnchor.constraint(equalTo: capsuleView.leadingAnchor, constant: padding)
        ballLeadingConstraint.isActive = true
        
        fillWidthConstraint = fillView.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint.isActive = true
    }
    
    private func setupGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        ballView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        ballView.addGestureRecognizer(tapGestureRecognizer)
        
        ballView.isUserInteractionEnabled = true
    }
    
    private func setupFillGradient() {
        fillGradientLayer = CAGradientLayer()
        fillGradientLayer.colors = self.fillGradientColors
        fillGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        fillGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        if fillView != nil {
            fillView.layer.insertSublayer(fillGradientLayer, at: 0)
        }
    }
    
    private func setupBallShadowGradient() {
        shadowGradientLayer = CAGradientLayer()
        shadowGradientLayer.type = .radial
        let shadowBaseColor = UIColor.black
        shadowGradientLayer.colors = [
            shadowBaseColor.withAlphaComponent(0.6).cgColor, // center color
            shadowBaseColor.withAlphaComponent(0.4).cgColor,
            shadowBaseColor.withAlphaComponent(0.1).cgColor,
            shadowBaseColor.withAlphaComponent(0.00).cgColor, // edges color
            UIColor.clear.cgColor
        ]
        shadowGradientLayer.locations = [0.2, 0.3, 0.5, 0.7] // center -> edge
        shadowGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.47) // center coordinates
        shadowGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.63) // edge coordinates
        
        if underBallShadowView != nil {
            underBallShadowView.layer.addSublayer(shadowGradientLayer)
        }
    }
    
    private func setupBallGradient() {
        ballGradientLayer = CAGradientLayer()
        ballGradientLayer.type = .radial
        ballGradientLayer.colors = [
            UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0).cgColor, // center color
            UIColor(red: 149/255.0, green: 149/255.0, blue: 169/255.0, alpha: 1.0).cgColor,
            UIColor(red: 129/255.0, green: 129/255.0, blue: 149/255.0, alpha: 1.0).cgColor,
            UIColor(red: 149/255.0, green: 149/255.0, blue: 159/255.0, alpha: 1.0).cgColor,
            UIColor(red: 210/255.0, green: 210/255.0, blue: 240/255.0, alpha: 0.9).cgColor // edges color
        ]
        ballGradientLayer.locations = [0.0, 0.5 ,0.7, 0.9, 1.2] // center -> edge
        ballGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.35)
        ballGradientLayer.endPoint = CGPoint(x: 1.1, y: 0.95)
        
        if ballView != nil {
            ballView.layer.addSublayer(ballGradientLayer)
        }
    }
    
    private func setupCapsuleInnerShadow() {
        let shadowGradient = CAGradientLayer()
        shadowGradient.frame = capsuleView.bounds
        shadowGradient.cornerRadius = capsuleHeight / 2
        shadowGradient.masksToBounds = true
        shadowGradient.type = .radial
        
        //transparent center to dark edges
        shadowGradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(cornerInnerShadowAlpha * 0.5).cgColor,
            UIColor.black.withAlphaComponent(cornerInnerShadowAlpha).cgColor
        ]
        shadowGradient.locations = [0.4, 0.7, 1.0]
        shadowGradient.startPoint = CGPoint(x: 0.5, y: 0.5) // center
        shadowGradient.endPoint = CGPoint(x: 1.0, y: 1.0) // edges
        
        if showCornerInnerShadow {
            fillView.layer.addSublayer(shadowGradient)
            capsuleInnerShadowLayer = shadowGradient
        }
    }
    
    private func setupCapsuleTopInnerShadow() {
        let topShadowGradient = CAGradientLayer()
        topShadowGradient.frame = capsuleView.bounds
        topShadowGradient.cornerRadius = capsuleHeight / 2
        
        // from dark at top to transparent
        topShadowGradient.colors = [
            UIColor.black.withAlphaComponent(topInnerShadowAlpha).cgColor,
            UIColor.black.withAlphaComponent(topInnerShadowAlpha * 0.5).cgColor,
            UIColor.clear.cgColor,
        ]
        topShadowGradient.locations = [0.0, 0.3, 0.6]
        topShadowGradient.startPoint = CGPoint(x: 0.5, y: 0.0) // Top
        topShadowGradient.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom
        
        if showTopInnerShadow {
            fillView.layer.addSublayer(topShadowGradient)
            capsuleTopInnerShadowLayer = topShadowGradient
        }
    }
    
    private func updateCapsuleWidthConstraints() {
        capsuleLeadingConstraint.isActive = false
        capsuleTrailingConstraint.isActive = false
        capsuleWidthConstraint?.isActive = false
        capsuleCenterXConstraint.isActive = false

        if let width = capsuleWidth {
            if capsuleWidthConstraint == nil {
                capsuleWidthConstraint = capsuleView.widthAnchor.constraint(equalToConstant: width)
            } else {
                capsuleWidthConstraint.constant = width
            }
            capsuleWidthConstraint.isActive = true
            capsuleCenterXConstraint.isActive = true
        } else {
            capsuleLeadingConstraint.isActive = true
            capsuleTrailingConstraint.isActive = true
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets the progress of the draggable ball to a specific value.
    /// - Parameters:
    ///   - progress: The desired progress, from 0.0 to 1.0.
    ///   - animated: A boolean indicating whether to animate the change.
    public func setProgress(_ progress: CGFloat, animated: Bool) {
        guard let capsuleView = self.capsuleView, capsuleView.bounds.width > 0 else {
            // If layout is not ready, schedule to set progress later.
            DispatchQueue.main.async {
                self.setProgress(progress, animated: animated)
            }
            return
        }
        
        stopHintTimer() // Stop hint animation when progress is set manually
        
        let capsuleWidth = capsuleView.bounds.width
        let minX = padding
        let maxX = capsuleWidth - ballSize - padding
        
        guard maxX > minX else { return }
        
        let clampedProgress = max(0.0, min(1.0, progress)) // Ensure progress is between 0 and 1
        let newLeadingConstant = minX + (maxX - minX) * clampedProgress
        let newFillWidth = capsuleWidth * clampedProgress
        
        let updateLayout = {
            self.ballLeadingConstraint.constant = newLeadingConstant
            self.fillWidthConstraint.constant = newFillWidth
            self.updateIndicatorRotation(progress: clampedProgress)
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { // apply change with animation
                updateLayout()
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.draggableBall(self, didUpdateProgress: clampedProgress) // notify delegates
                checkProgressThresholdsAndNotifyDelegate(progress: clampedProgress)
            })
        } else { // apply change without animation
            updateLayout()
            delegate?.draggableBall(self, didUpdateProgress: clampedProgress) // notify delegates
            checkProgressThresholdsAndNotifyDelegate(progress: clampedProgress)
        }
    }
    
    // Updates the font used for the text
    public func updateFont(name: String, size: CGFloat = 20, color: UIColor? = nil) {
        fontName = name
        if let customFont = UIFont(name: name, size: size) {
            fillLabel.font = customFont
        } else {
            fillLabel.font = UIFont.systemFont(ofSize: size, weight: .bold)
            print("Custom font '\(name)' not available, using system font")
        }
        
        // Update color if provided
        if let color = color {
            fontColor = color
            fillLabel.textColor = color
        }
    }
    
    // Updates ONLY the size of the text
    public func updateFontSize(_ size: CGFloat) {
        if let currentFont = fillLabel.font {
            let fontName = currentFont.fontName
            fillLabel.font = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        } else {
            // Fallback to current fontName property
            fillLabel.font = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        }
    }
    
    // Updates ONLY the color of the text
    public func updateFontColor(_ color: UIColor) {
        fillLabel.textColor = color
    }
    
    // Updates the text 
    public func updateText(_ text: String) {
        fillLabel.text = text
    }
    
    public func updateFillGradientColors(_ colors: [CGColor]) { // fillGradientColors have already didSet but this is more explicit
        fillGradientColors = colors
        if let fillGradientLayer = fillGradientLayer {
            fillGradientLayer.colors = colors
        }
    }
    
    public func updateCornerInnerShadow(show: Bool, alpha: CGFloat) {
        showCornerInnerShadow = show
        cornerInnerShadowAlpha = alpha
        
        // Remove existing shadow layer if it exists
        capsuleInnerShadowLayer?.removeFromSuperlayer()
        capsuleInnerShadowLayer = nil
        
        // Recreate the shadow if needed
        if show {
            setupCapsuleInnerShadow()
        }
    }
    
    public func updateTopInnerShadow(show: Bool, alpha: CGFloat) {
        showTopInnerShadow = show
        topInnerShadowAlpha = alpha
        
        // Remove existing shadow layer if it exists
        capsuleTopInnerShadowLayer?.removeFromSuperlayer()
        capsuleTopInnerShadowLayer = nil
        
        // Recreate the shadow if needed
        if show {
            setupCapsuleTopInnerShadow()
        }
    }
    
    public func updateBallSize(_ newSize: CGFloat) {
        let progress = self.getCurrentProgress()

        self.ballSize = newSize
        ballView.layer.cornerRadius = newSize / 2

        // Update constraints
        ballHeightConstraint.constant = newSize
        ballWidthConstraint.constant = newSize
        underBallShadowViewWidthConstraint.constant = newSize * 3
        underBallShadowViewHeightConstraint.constant = newSize * 3

        // Re-apply layout to let the system recalculate frames
        self.layoutIfNeeded()

        // Restore the progress with the new dimensions
        self.setProgress(progress, animated: false)
    }

    public func updateIndicatorSize(_ newSize: CGFloat) {
        self.indicatorDisplaySize = newSize
        indicatorWidthConstraint.constant = newSize
        indicatorHeightConstraint.constant = newSize
        self.layoutIfNeeded()
    }

    public func updateIndicatorTopOffset(_ newOffset: CGFloat) {
        self.indicatorTopOffset = newOffset
        indicatorTopConstraint.constant = newOffset
        self.layoutIfNeeded()
    }

    public func updateCapsuleHeight(_ newHeight: CGFloat) {
        let progress = self.getCurrentProgress()

        self.capsuleHeight = newHeight
        capsuleHeightConstraint.constant = newHeight
        capsuleView.layer.cornerRadius = newHeight / 2

        updateCornerInnerShadow(show: showCornerInnerShadow, alpha: cornerInnerShadowAlpha) // they sould adapt
        updateTopInnerShadow(show: showTopInnerShadow, alpha: topInnerShadowAlpha)
        
        self.layoutIfNeeded()
        self.setProgress(progress, animated: false)
    }

    public func updateCapsuleWidth(_ newWidth: CGFloat?) {
        let progress = self.getCurrentProgress()
        
        self.capsuleWidth = newWidth
        updateCapsuleWidthConstraints()
        
        self.layoutIfNeeded()
        self.setProgress(progress, animated: false)
    }
    
    // MARK: - Private Animation Methods
    
    /// Gets the current normalized progress (0.0 to 1.0) of the ball position
    private func getCurrentProgress() -> CGFloat {
        guard let capsuleView = self.capsuleView,
              capsuleView.bounds.width > 0 else { return 0.0 }
        
        let capsuleWidth = capsuleView.bounds.width
        let minX = padding
        let maxX = capsuleWidth - ballSize - padding
        
        guard maxX > minX else { return 0.0 }
        
        let currentConstant = ballLeadingConstraint.constant
        return (currentConstant - minX) / (maxX - minX)
    }
    
    private func performSimpleHintAnimation() {
        // Don't perform hint animation if user is actively dragging
        guard !isDragging else { return }
        
        // Use tolerance for floating-point comparison instead of exact equality
        guard abs(getCurrentProgress()) < progressTolerance else { return }
        
        guard let capsuleView = self.capsuleView,
              capsuleView.bounds.width > 0 else { return }
        
        let capsuleWidth = capsuleView.bounds.width
        let minX = padding
        let maxX = capsuleWidth - ballSize - padding
        
        let startConstant = ballLeadingConstraint.constant
        let startFillWidth = fillWidthConstraint.constant
        
        let hintDistance = (maxX - minX) * hintAnimationAmount
        let targetConstant = startConstant + hintDistance
        
        let normalizedProgress = (targetConstant - minX) / (maxX - minX)
        let targetFillWidth = capsuleWidth * normalizedProgress
        
        // Animate with keyframes: Start -> Forward -> Back -> Forward -> Back
        UIView.animateKeyframes(withDuration: 1.4, delay: 0, options: [.calculationModeLinear, .allowUserInteraction], animations: {
            // First forward movement (0-20%)
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                self.ballLeadingConstraint.constant = targetConstant
                self.fillWidthConstraint.constant = targetFillWidth
                self.updateIndicatorRotation(progress: normalizedProgress)
                self.layoutIfNeeded()
            }
            
            // Back to start (20-40%)
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                self.ballLeadingConstraint.constant = startConstant
                self.fillWidthConstraint.constant = startFillWidth
                self.updateIndicatorRotation(progress: 0.0)
                self.layoutIfNeeded()
            }
            
            // Second forward movement (50-70%)
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
                self.ballLeadingConstraint.constant = targetConstant
                self.fillWidthConstraint.constant = targetFillWidth
                self.updateIndicatorRotation(progress: normalizedProgress)
                self.layoutIfNeeded()
            }
            
            // Final return to start (70-100%)
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                self.ballLeadingConstraint.constant = startConstant
                self.fillWidthConstraint.constant = startFillWidth
                self.updateIndicatorRotation(progress: 0.0)
                self.layoutIfNeeded()
            }
        }, completion: { [weak self] _ in
            // Check progress after animation completes
            self?.checkProgressAndManageTimer()
        })
    }
    
    // Checks the current progress and manages the timer accordingly
    private func checkProgressAndManageTimer() {
        let currentProgress = getCurrentProgress()
        // Use tolerance instead of exact comparison - only start timer when very close to start
        if abs(currentProgress) < progressTolerance {
            startHintTimer() // Progress is essentially 0.0, keep the timer active
        } else {
            stopHintTimer() // Progress is greater than tolerance, stop the timer
        }
    }
    
    // Starts the hint timer
    private func startHintTimer() {
        stopHintTimer() // Stop any existing timer first
        
        hintTimer = Timer.scheduledTimer(withTimeInterval: hintTimerInterval, repeats: true) { [weak self] _ in
            self?.performSimpleHintAnimation()
        }
    }
    
    // Stops the hint timer
    private func stopHintTimer() {
        hintTimer?.invalidate()
        hintTimer = nil
    }
    
    // Cleanup timer when the view is deallocated
    deinit {
        stopHintTimer()
    }
    
    private func performTapHintAnimation() {
        guard let capsuleView = self.capsuleView,
              capsuleView.bounds.width > 0 else { return } // precaution
        
        if ballView.layer.animationKeys()?.isEmpty == false { 
            let currentBallConstant = ballView.layer.presentation()?.frame.origin.x ?? ballLeadingConstraint.constant
            let currentFillWidth = fillView.layer.presentation()?.bounds.width ?? fillWidthConstraint.constant
            let finalIndicatorTransform: CGAffineTransform
            if let presentationTransform = indicatorImageView.layer.presentation()?.transform {
                finalIndicatorTransform = CATransform3DGetAffineTransform(presentationTransform)
            } else {
                finalIndicatorTransform = indicatorImageView.transform
            }
            ballView.layer.removeAllAnimations()
            fillView.layer.removeAllAnimations()
            indicatorImageView.layer.removeAllAnimations()
            underBallShadowView.layer.removeAllAnimations()
            ballLeadingConstraint.constant = currentBallConstant
            fillWidthConstraint.constant = currentFillWidth
            indicatorImageView.transform = finalIndicatorTransform
            self.layoutIfNeeded() // Apply the final values before starting new animation
        }
        
        let capsuleWidth = capsuleView.bounds.width // same mechanisim as in handlePanGesture
        let minX = padding
        let maxX = capsuleWidth - ballSize - padding
        
        guard maxX > minX else { return }
        
        let totalDistance = maxX - minX
        let startConstant = ballLeadingConstraint.constant
        let hintDistance = totalDistance * hintAnimationAmount * 2 // hintAnimationAmount = 0.05
        
        var targetConstant = startConstant + hintDistance // Determine target position to reach
        if targetConstant > maxX { //If the target position exceeds the right boundary, the direction of movement is reversed (shifted to the left).
            targetConstant = startConstant - hintDistance
        }
        targetConstant = max(minX, min(targetConstant, maxX)) // Ensure the target position is within the valid range just in case
        
        let startNormalizedProgress = (startConstant - minX) / totalDistance // example: 0.42
        let targetNormalizedProgress = (targetConstant - minX) / totalDistance // example: 0.46
        
        let startFillWidth = fillWidthConstraint.constant
        let targetFillWidth = capsuleWidth * targetNormalizedProgress
        
        // One step forward, then one step back animation
        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [.calculationModeLinear, .allowUserInteraction], animations: {
            // Forward movement (at 0-40% duration)
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                self.ballLeadingConstraint.constant = targetConstant // move the ball to forward
                self.fillWidthConstraint.constant = targetFillWidth // move fill to forward
                self.updateIndicatorRotation(progress: targetNormalizedProgress) // update rotation of arrows
                self.layoutIfNeeded()
            }
            // Back to start (at 40-100% duration)
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                self.ballLeadingConstraint.constant = startConstant // move the ball back to start
                self.fillWidthConstraint.constant = startFillWidth // move fill back to start
                self.updateIndicatorRotation(progress: startNormalizedProgress) // update rotation of arrows
                self.layoutIfNeeded()
            }
        }, completion: { [weak self] _ in
            self?.checkProgressAndManageTimer() // Check progress and manage timer after tap animation completes
        })
    }
    
    private func updateIndicatorRotation(progress: CGFloat) {
        let rotationAngle = progress * maxIndicatorRotationAngle
        indicatorImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
    }
    
    private func checkProgressThresholdsAndNotifyDelegate(progress: CGFloat) {
        if progress >= 0.97 {
            delegate?.draggableBallDidReachEnd(self)
        } else if progress <= 0.03 {
            delegate?.draggableBallDidReturnToStart(self)
        }
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        stopHintTimer() // Stop hint animation
        performTapHintAnimation() // Start tap animation
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let capsuleView = self.capsuleView else { return }
        
        let capsuleWidth = capsuleView.bounds.width
        let minX = padding // 0% progress
        let maxX = capsuleWidth - ballSize - padding // 100% progress
        
        guard maxX > minX else { return } // precaution
        
        switch gesture.state {
        case .began:
            isDragging = true // Set dragging state and stop the hint timer when user starts dragging
            stopHintTimer() // stop the which give feedback to usesr
            
            if ballView.layer.animationKeys()?.isEmpty == false { // if there is active animation
                let currentBallConstant = ballView.layer.presentation()?.frame.origin.x ?? ballLeadingConstraint.constant // Get the current live position
                let currentFillWidth = fillView.layer.presentation()?.bounds.width ?? fillWidthConstraint.constant // Get the current live fill width
                let finalIndicatorTransform: CGAffineTransform
                if let presentationTransform = indicatorImageView.layer.presentation()?.transform {
                    finalIndicatorTransform = CATransform3DGetAffineTransform(presentationTransform) // Get the current indicator live transform
                } else {
                    finalIndicatorTransform = indicatorImageView.transform // get the normal trasnform, if cant access the live one
                }
                ballView.layer.removeAllAnimations() // remove all other animaitions form views.
                fillView.layer.removeAllAnimations()
                indicatorImageView.layer.removeAllAnimations()
                underBallShadowView.layer.removeAllAnimations()
                ballLeadingConstraint.constant = currentBallConstant
                fillWidthConstraint.constant = currentFillWidth
                indicatorImageView.transform = finalIndicatorTransform
                /// if there is active animation, set the live position to Constraint.constant,
                /// for example if we intrupt an animation, froze it at began of touch and set that 'live' value to our drag start value.
                /// this prevents animations from overlapping
                self.layoutIfNeeded()
            }
            dragStartLeadingConstant = ballLeadingConstraint.constant // set the drag start value from with the values you updated above
            
        case .changed:
            let translationX = gesture.translation(in: capsuleView).x // get the current drag translation at x axis
            var newLeadingConstant = dragStartLeadingConstant + translationX // start + drag = new location
            newLeadingConstant = max(minX, min(newLeadingConstant, maxX)) // set boundaries
            
            let transformTx = newLeadingConstant - dragStartLeadingConstant
            let dragTransform = CGAffineTransform(translationX: transformTx, y: 0) // not new location, the diffrence between new and start to move, the delta
            ballView.transform = dragTransform // apply the transform
            underBallShadowView.transform = dragTransform
            
            let normalizedProgress = (newLeadingConstant - minX) / (maxX - minX) // like 73% -> 0.73 normalization
            delegate?.draggableBall(self, didUpdateProgress: normalizedProgress) // notify delegate
            fillWidthConstraint.constant = capsuleWidth * normalizedProgress // set the fill width according to the progress
            updateIndicatorRotation(progress: normalizedProgress) // update the indicator rotation
            
        case .ended, .cancelled:
            isDragging = false // set new state
            
            let finalTranslationX = gesture.translation(in: capsuleView).x // set the final coordinate
            var finalLeadingConstant = dragStartLeadingConstant + finalTranslationX
            finalLeadingConstant = max(minX, min(finalLeadingConstant, maxX))
            
            ballLeadingConstraint.constant = finalLeadingConstant // move the ball to the final location, permanently
            
            self.ballView.transform = .identity // set back to normal
            self.underBallShadowView.transform = .identity // set back to normal
            self.layoutIfNeeded() // UI done
            
            let finalProgress = self.getCurrentProgress() // its get progress from position of ballLeadingConstraint according to capsule
            self.delegate?.draggableBall(self, didUpdateProgress: finalProgress) // notify delegate
            checkProgressThresholdsAndNotifyDelegate(progress: finalProgress) // notify delegate
            
            // Check progress and manage timer after drag animation completes
            self.checkProgressAndManageTimer() // Check progress and manage timer
        default:
            break
        }
    }
}

struct ViewControllerView_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            SingleBallAnimationVC()
        }
    }
}
