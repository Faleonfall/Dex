import SwiftUI

struct FavoriteFilterButton: View {
  @Binding var isOn: Bool

  let isEnabled: Bool

  var body: some View {
    Button {
      withAnimation {
        isOn.toggle()
      }
    } label: {
      Label("Filter By Favorites", systemImage: isOn ? "star.fill" : "star")
    }
    .tint(.yellow)
    .disabled(!isEnabled)
  }
}

#Preview {
  FavoriteFilterButtonPreview()
}

private struct FavoriteFilterButtonPreview: View {
  @State private var isOn = false

  var body: some View {
    FavoriteFilterButton(isOn: $isOn, isEnabled: true)
  }
}
