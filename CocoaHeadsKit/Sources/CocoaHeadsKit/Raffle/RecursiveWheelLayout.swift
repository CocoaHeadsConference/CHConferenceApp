// Author: SwiftUI-Lab (swiftui-lab.com)
// Description: A demonstration of a recursive Layout
// blog article: https://swiftui-lab.com/layout-protocol-part-2

import SwiftUI

struct WheelExampleView: View {
  let colors: [Color] = [.yellow, .orange, .red, .pink, .purple, .blue, .cyan, .green]

  @State var angle: Angle = .zero
  @State var components = [
    "Jimmy"
  ]

  var body: some View {
    VStack {

      Spacer()

      RecursiveWheel(radius: 150, rotation: angle) {
        contents()
      }

      Spacer()

      Button("Begin Rotation") {
        withAnimation(.easeInOut(duration: 6).repeatForever()) {
          angle = angle == .zero ? .degrees(360) : .zero
        }
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
  }

  @ViewBuilder func contents() -> some View {
    ForEach(0..<44) { idx in
      RecursiveWheelComponent {
        RoundedRectangle(cornerRadius: 8)
          .fill(colors[idx % colors.count].opacity(0.7))
          .frame(width: 70, height: 70)
          .overlay { Text("\(idx+1)") }
      }
    }
  }
}

#Preview {
  WheelExampleView()
}

struct RecursiveWheelValue {
  var rotation: Angle
  var scale: CGFloat
}

struct RecursiveWheelValueKey: LayoutValueKey {
  static let defaultValue: Binding<RecursiveWheelValue>? = nil
}

struct RecursiveWheelComponent<V: View>: View {
  @ViewBuilder let content: () -> V
  @State private var value = RecursiveWheelValue(rotation: .zero, scale: 1.0)

  var body: some View {
    content()
      .rotationEffect(value.rotation)
      .scaleEffect(value.scale)
      .layoutValue(key: RecursiveWheelValueKey.self, value: $value)
  }
}

struct RecursiveWheel: Layout {
  var animatableData: AnimatablePair<CGFloat, CGFloat> {
    get { AnimatablePair(rotation.radians, radius) }
    set {
      rotation = Angle.radians(newValue.first)
      radius = newValue.second
    }
  }

  var radius: CGFloat
  var rotation: Angle

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {

    let maxSize = subviews.map { $0.sizeThatFits(proposal) }.reduce(CGSize.zero) {

      return CGSize(width: max($0.width, $1.width), height: max($0.height, $1.height))

    }

    return CGSize(
      width: (maxSize.width / 2 + radius) * 2,
      height: (maxSize.height / 2 + radius) * 2)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
    let viewsPerRing = 12

    let ringViewsCount = min(subviews.count, viewsPerRing)

    let angleStep = (Angle.degrees(360).radians / Double(ringViewsCount))

    for (index, subview) in subviews[0..<ringViewsCount].enumerated() {
      var angle = angleStep * CGFloat(index) + rotation.radians

      // Alternate rotation direction in each ring
      if !cache.clockwise {
        angle = -1 * angle
      }

      // Find a vector with an appropriate size and rotation.
      var point = CGPoint(x: 0, y: -cache.radius).applying(CGAffineTransform(rotationAngle: angle))

      // Shift the vector to the middle of the region.
      point.x += bounds.midX
      point.y += bounds.midY

      // Place the subview.
      subview.place(at: point, anchor: .center, proposal: .unspecified)

      let value = RecursiveWheelValue(rotation: .radians(angle), scale: cache.scale)

      DispatchQueue.main.async {
        subview[RecursiveWheelValueKey.self]?.wrappedValue = value
      }
    }

    // Save cache values to restore them after all sub-layouts finished
    let saveCache = cache

    cache.radius = cache.radius / 2
    cache.scale = cache.scale / 2
    cache.clockwise.toggle()

    // Place sub-layout views
    if subviews.count > viewsPerRing {
      placeSubviews(
        in: bounds,
        proposal: proposal,
        subviews: subviews[viewsPerRing..<subviews.count],
        cache: &cache)
    }

    // restore cache
    cache = saveCache
  }

  // this will only be called for the outer layout
  func makeCache(subviews: Subviews) -> CacheData {
    CacheData(radius: radius, scale: 1.0, clockwise: true)
  }

  // The cache type shared by all layouts
  struct CacheData {
    var radius: CGFloat
    var scale: CGFloat
    var clockwise: Bool
  }
}
