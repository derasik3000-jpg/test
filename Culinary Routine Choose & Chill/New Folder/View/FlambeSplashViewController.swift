// ──────────────────────────────────────────────
// FlambeSplashViewController.swift
// с8 – "Menu of 12 Dishes"
//
// Animated loading screen shown on every launch.
// Dark background, gold pulsing ring, rotating
// abstract micro-copy, fires callback when done.
// ──────────────────────────────────────────────

import UIKit

final class FlambeSplashViewController: UIViewController {

    // ── Callback ─────────────────────────────

    /// Called when the splash is ready to hand off.
    var onFlameOut: (() -> Void)?

    // ── UI Elements ──────────────────────────

    /// Outer glowing ring.
    private let auraRing = CAShapeLayer()

    /// Inner pulsing ring.
    private let emberRing = CAShapeLayer()

    /// Central "12" digit display.
    private let plateCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "12"
        lbl.font = TypographyRecipe.ovenDigit()
        lbl.textColor = SaffronPalette.honeyComb
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.alpha = 0
        lbl.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        return lbl
    }()

    /// App name below the ring.
    private let brandMark: UILabel = {
        let lbl = UILabel()
        lbl.text = "Menu of 12 Dishes"
        lbl.font = TypographyRecipe.sectionRoast()
        lbl.textColor = SaffronPalette.flour
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.alpha = 0
        return lbl
    }()

    /// Rotating abstract loading phrases.
    private let whisperLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = TypographyRecipe.sideNote()
        lbl.textColor = SaffronPalette.steamGrey
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.alpha = 0
        return lbl
    }()

    /// Decorative floating particles.
    private var sparkLayers: [CALayer] = []

    /// Small progress bar.
    private let simmerBar: UIView = {
        let v = UIView()
        v.backgroundColor = SaffronPalette.honeyComb.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let simmerFill: UIView = {
        let v = UIView()
        v.backgroundColor = SaffronPalette.honeyComb
        v.layer.cornerRadius = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var fillWidthConstraint: NSLayoutConstraint?

    // ── Phrases ──────────────────────────────

    private let whispers: [String] = [
        "Warming up the kitchen…",
        "Seasoning your menu…",
        "Gathering ingredients…",
        "Setting the table…",
        "Lighting the stove…",
        "Almost ready to serve…",
    ]
    private var whisperIndex = 0
    private var whisperTimer: Timer?

    // ── Timing ───────────────────────────────

    private let totalDuration: TimeInterval = 2.6

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SaffronPalette.crust
        layoutElements()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runIgnitionSequence()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        whisperTimer?.invalidate()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Layout
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func layoutElements() {

        // ── Rings (drawn in viewDidLayoutSubviews) ──

        // ── Plate Count ──────────────────────
        view.addSubview(plateCountLabel)
        NSLayoutConstraint.activate([
            plateCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plateCountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
        ])

        // ── Brand Mark ───────────────────────
        view.addSubview(brandMark)
        NSLayoutConstraint.activate([
            brandMark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandMark.topAnchor.constraint(equalTo: plateCountLabel.bottomAnchor, constant: 60),
        ])

        // ── Whisper Label ────────────────────
        view.addSubview(whisperLabel)
        NSLayoutConstraint.activate([
            whisperLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whisperLabel.topAnchor.constraint(equalTo: brandMark.bottomAnchor, constant: KitchenSpacing.napkin),
        ])

        // ── Simmer Bar ──────────────────────
        view.addSubview(simmerBar)
        simmerBar.addSubview(simmerFill)

        let barWidth: CGFloat = 160
        NSLayoutConstraint.activate([
            simmerBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            simmerBar.topAnchor.constraint(equalTo: whisperLabel.bottomAnchor, constant: KitchenSpacing.tray),
            simmerBar.widthAnchor.constraint(equalToConstant: barWidth),
            simmerBar.heightAnchor.constraint(equalToConstant: 4),

            simmerFill.leadingAnchor.constraint(equalTo: simmerBar.leadingAnchor),
            simmerFill.topAnchor.constraint(equalTo: simmerBar.topAnchor),
            simmerFill.bottomAnchor.constraint(equalTo: simmerBar.bottomAnchor),
        ])

        let fw = simmerFill.widthAnchor.constraint(equalToConstant: 0)
        fw.isActive = true
        fillWidthConstraint = fw
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawRings()
        if sparkLayers.isEmpty { scatterSparks() }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Ring Drawing
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func drawRings() {
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 30)
        let outerRadius: CGFloat = 56
        let innerRadius: CGFloat = 44

        // Aura (outer glow ring)
        let outerPath = UIBezierPath(
            arcCenter: center, radius: outerRadius,
            startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true
        )
        auraRing.path = outerPath.cgPath
        auraRing.fillColor = UIColor.clear.cgColor
        auraRing.strokeColor = SaffronPalette.honeyComb.withAlphaComponent(0.2).cgColor
        auraRing.lineWidth = 3
        auraRing.lineCap = .round
        if auraRing.superlayer == nil {
            view.layer.insertSublayer(auraRing, at: 0)
        }

        // Ember (inner progress ring)
        let innerPath = UIBezierPath(
            arcCenter: center, radius: innerRadius,
            startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true
        )
        emberRing.path = innerPath.cgPath
        emberRing.fillColor = UIColor.clear.cgColor
        emberRing.strokeColor = SaffronPalette.honeyComb.cgColor
        emberRing.lineWidth = 4
        emberRing.lineCap = .round
        emberRing.strokeEnd = 0
        if emberRing.superlayer == nil {
            view.layer.insertSublayer(emberRing, above: auraRing)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Floating Sparks
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func scatterSparks() {
        guard !FrostBox.shouldReduceMotion else { return }

        let sparkCount = 8
        for _ in 0..<sparkCount {
            let spark = CALayer()
            let size: CGFloat = CGFloat.random(in: 2...5)
            let x = CGFloat.random(in: 40...(view.bounds.width - 40))
            let y = CGFloat.random(in: 80...(view.bounds.height - 120))
            spark.frame = CGRect(x: x, y: y, width: size, height: size)
            spark.cornerRadius = size / 2
            spark.backgroundColor = SaffronPalette.honeyComb.withAlphaComponent(
                CGFloat.random(in: 0.15...0.45)
            ).cgColor
            spark.opacity = 0
            view.layer.insertSublayer(spark, at: 0)
            sparkLayers.append(spark)
        }
    }

    private func animateSparks() {
        guard !FrostBox.shouldReduceMotion else { return }

        for (i, spark) in sparkLayers.enumerated() {
            let delay = Double(i) * 0.12
            let drift = CABasicAnimation(keyPath: "position.y")
            drift.fromValue = spark.position.y
            drift.toValue = spark.position.y - CGFloat.random(in: 20...60)
            drift.duration = Double.random(in: 1.8...2.6)
            drift.beginTime = CACurrentMediaTime() + delay
            drift.fillMode = .forwards
            drift.isRemovedOnCompletion = false

            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0
            fade.toValue = 1
            fade.duration = 0.6
            fade.beginTime = CACurrentMediaTime() + delay
            fade.autoreverses = true
            fade.fillMode = .forwards
            fade.isRemovedOnCompletion = false

            spark.add(drift, forKey: "sparkDrift_\(i)")
            spark.add(fade, forKey: "sparkFade_\(i)")
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Ignition Sequence
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func runIgnitionSequence() {

        let reduced = FrostBox.shouldReduceMotion

        // ── Phase 1: Show "12" + ring stroke ──
        let ringAnim = CABasicAnimation(keyPath: "strokeEnd")
        ringAnim.fromValue = 0
        ringAnim.toValue = 1
        ringAnim.duration = reduced ? 0.3 : totalDuration * 0.75
        ringAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        ringAnim.fillMode = .forwards
        ringAnim.isRemovedOnCompletion = false
        emberRing.add(ringAnim, forKey: "ignite")

        // Pulse outer ring
        if !reduced {
            let pulse = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue = 0.2
            pulse.toValue = 0.5
            pulse.duration = 0.8
            pulse.autoreverses = true
            pulse.repeatCount = 3
            auraRing.add(pulse, forKey: "auraPulse")
        }

        // Animate "12" label
        UIView.animate(
            withDuration: reduced ? 0.15 : 0.6,
            delay: reduced ? 0 : 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: []
        ) {
            self.plateCountLabel.alpha = 1
            self.plateCountLabel.transform = .identity
        }

        // ── Phase 2: Brand + whisper + bar ────
        UIView.animate(
            withDuration: reduced ? 0.1 : 0.4,
            delay: reduced ? 0.15 : 0.55
        ) {
            self.brandMark.alpha = 1
            self.whisperLabel.alpha = 1
            self.simmerBar.alpha = 1
        }

        // Start whisper rotation
        whisperLabel.text = whispers[0]
        whisperTimer = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { [weak self] _ in
            self?.rotateWhisper()
        }

        // Animate progress bar
        let barWidth: CGFloat = 160
        UIView.animate(
            withDuration: reduced ? 0.3 : totalDuration * 0.85,
            delay: reduced ? 0.05 : 0.3,
            options: [.curveEaseInOut]
        ) {
            self.fillWidthConstraint?.constant = barWidth
            self.simmerBar.layoutIfNeeded()
        }

        // ── Phase 3: Sparks ──────────────────
        animateSparks()

        // ── Phase 4: Finish ──────────────────
        let finishDelay = reduced ? 0.6 : totalDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + finishDelay) { [weak self] in
            self?.flameOutTransition()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Whisper Rotation
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func rotateWhisper() {
        whisperIndex = (whisperIndex + 1) % whispers.count

        let reduced = FrostBox.shouldReduceMotion
        if reduced {
            whisperLabel.text = whispers[whisperIndex]
            return
        }

        UIView.animate(withDuration: 0.15, animations: {
            self.whisperLabel.alpha = 0
            self.whisperLabel.transform = CGAffineTransform(translationX: 0, y: -6)
        }) { _ in
            self.whisperLabel.text = self.whispers[self.whisperIndex]
            self.whisperLabel.transform = CGAffineTransform(translationX: 0, y: 6)
            UIView.animate(withDuration: 0.2) {
                self.whisperLabel.alpha = 1
                self.whisperLabel.transform = .identity
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Exit
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func flameOutTransition() {
        whisperTimer?.invalidate()

        let reduced = FrostBox.shouldReduceMotion
        let duration: TimeInterval = reduced ? 0.1 : 0.35

        UIView.animate(withDuration: duration, animations: {
            self.view.alpha = 0
            if !reduced {
                self.plateCountLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
        }) { _ in
            self.onFlameOut?()
        }
    }
}
