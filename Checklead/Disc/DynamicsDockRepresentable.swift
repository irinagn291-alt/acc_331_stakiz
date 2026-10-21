import SwiftUI
import UIKit

struct DiscToken: Identifiable, Equatable {
    var id: UUID
    var label: String
    var enabled: Bool
}

/// Hero surface. UISnapBehavior commits a disc onto a slot, or springs it home.
struct DynamicsDockRepresentable: UIViewRepresentable {
    var discs: [DiscToken]
    var slotFrames: [UUID: CGRect]
    var reduceMotion: Bool
    var onRelease: (UUID, UUID?) -> ReleaseOutcome

    func makeCoordinator() -> Coordinator { Coordinator(onRelease: onRelease) }

    func makeUIView(context: Context) -> StageView {
        let view = StageView()
        view.backgroundColor = .clear
        view.coordinator = context.coordinator
        return view
    }

    func updateUIView(_ uiView: StageView, context: Context) {
        context.coordinator.onRelease = onRelease
        context.coordinator.reduceMotion = reduceMotion
        context.coordinator.slotFrames = slotFrames
        uiView.sync(discs: discs, coordinator: context.coordinator)
    }

    final class Coordinator: NSObject {
        var onRelease: (UUID, UUID?) -> ReleaseOutcome
        var slotFrames: [UUID: CGRect] = [:]
        var reduceMotion = false
        var homeCenters: [UUID: CGPoint] = [:]

        init(onRelease: @escaping (UUID, UUID?) -> ReleaseOutcome) {
            self.onRelease = onRelease
        }
    }
}

final class DiscChip: UIView {
    var routineID: UUID = UUID()
}

final class StageView: UIView, UIDynamicAnimatorDelegate {
    weak var coordinator: DynamicsDockRepresentable.Coordinator?
    private var animator: UIDynamicAnimator?
    private var discs: [UUID: DiscChip] = [:]
    private var attachment: UIAttachmentBehavior?
    private var pending: (id: UUID, target: UUID?)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        animator = UIDynamicAnimator(referenceView: self)
        clipsToBounds = true
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func sync(discs tokens: [DiscToken], coordinator: DynamicsDockRepresentable.Coordinator) {
        self.coordinator = coordinator
        let keep = Set(tokens.map(\.id))
        for (id, view) in discs where !keep.contains(id) {
            view.removeFromSuperview()
            discs[id] = nil
        }
        for (index, token) in tokens.enumerated() {
            let chip = discs[token.id] ?? makeChip(id: token.id)
            discs[token.id] = chip
            (chip.subviews.compactMap { $0 as? UILabel }.first)?.text = token.label
            chip.accessibilityLabel = token.label
            chip.alpha = token.enabled ? 1 : 0.4
            chip.isUserInteractionEnabled = token.enabled
            chip.layer.borderWidth = token.enabled ? 2 : 1
            chip.layer.borderColor = UIColor(token.enabled ? DesignTokens.accent : DesignTokens.muted).cgColor
            if chip.superview == nil { addSubview(chip) }
            if chip.layer.animationKeys()?.isEmpty != false && attachment == nil {
                let home = homeCenter(index: index)
                chip.center = home
                coordinator.homeCenters[token.id] = home
            }
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        discs.values.contains { $0.frame.contains(point) && $0.isUserInteractionEnabled }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let coordinator else { return }
        for (index, pair) in discs.sorted(by: { $0.key.uuidString < $1.key.uuidString }).enumerated() {
            let center = homeCenter(index: index)
            coordinator.homeCenters[pair.key] = center
            if attachment != nil { continue }
            pair.value.center = center
        }
    }

    /// Chip row stays in a short lane under the caption, even if the host is tall.
    private func homeCenter(index: Int) -> CGPoint {
        CGPoint(x: 24 + CGFloat(index) * 108 + 44, y: 36)
    }

    private func makeChip(id: UUID) -> DiscChip {
        let chip = DiscChip(frame: CGRect(x: 0, y: 0, width: 88, height: 48))
        chip.routineID = id
        chip.backgroundColor = UIColor(DesignTokens.bg)
        chip.layer.cornerRadius = ThemeTokens.chipRadius
        chip.layer.shadowColor = UIColor(ThemeTokens.shadow).cgColor
        chip.layer.shadowOpacity = 1
        chip.layer.shadowRadius = ThemeTokens.shadowRadius
        chip.layer.shadowOffset = CGSize(width: 0, height: ThemeTokens.shadowY)
        let label = UILabel(frame: chip.bounds.insetBy(dx: 8, dy: 8))
        label.font = UIFont(name: DesignTokens.fontFamily, size: 17)
        label.textColor = UIColor(DesignTokens.ink)
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chip.addSubview(label)
        chip.isAccessibilityElement = true
        chip.accessibilityLabel = "Disc"
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        chip.addGestureRecognizer(pan)
        return chip
    }

    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        guard let chip = gesture.view as? DiscChip, let coordinator else { return }
        let id = chip.routineID
        let point = gesture.location(in: self)
        switch gesture.state {
        case .began:
            clipsToBounds = false
            animator?.removeAllBehaviors()
            pending = nil
            let attach = UIAttachmentBehavior(item: chip, attachedToAnchor: point)
            attachment = attach
            animator?.addBehavior(attach)
        case .changed:
            attachment?.anchorPoint = point
        case .ended, .cancelled:
            if let attachment { animator?.removeBehavior(attachment) }
            attachment = nil
            let global = convert(chip.center, to: nil)
            let target = coordinator.slotFrames.first { $0.value.insetBy(dx: -12, dy: -12).contains(global) }?.key
            if coordinator.reduceMotion {
                finish(id: id, chip: chip, target: target, coordinator: coordinator)
                return
            }
            let home = coordinator.homeCenters[id] ?? chip.center
            let localTarget: CGPoint
            if let target, let frame = coordinator.slotFrames[target] {
                localTarget = convert(CGPoint(x: frame.midX, y: frame.midY), from: nil)
            } else {
                localTarget = home
            }
            pending = (id, target)
            let snap = UISnapBehavior(item: chip, snapTo: localTarget)
            snap.damping = 0.72
            animator?.addBehavior(snap)
            animator?.delegate = self
        default:
            break
        }
    }

    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        guard let pending, let coordinator, let chip = discs[pending.id] else { return }
        self.pending = nil
        animator.removeAllBehaviors()
        finish(id: pending.id, chip: chip, target: pending.target, coordinator: coordinator)
    }

    private func finish(id: UUID, chip: UIView, target: UUID?, coordinator: DynamicsDockRepresentable.Coordinator) {
        clipsToBounds = false
        let outcome = coordinator.onRelease(id, target)
        let home = coordinator.homeCenters[id] ?? CGPoint(x: 68, y: bounds.midY)
        let shouldReturn = outcome != .seated && outcome != .clipped
        if shouldReturn {
            if coordinator.reduceMotion {
                chip.center = home
            } else {
                let snap = UISnapBehavior(item: chip, snapTo: home)
                snap.damping = 0.55
                animator?.addBehavior(snap)
            }
        } else {
            chip.center = home
            chip.alpha = 0.4
            chip.isUserInteractionEnabled = false
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}
