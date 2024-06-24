//
//  PhotoView_UI.swift
//  
//
//  Created by Michał Śmiałko on 15/10/2021.
//

import SwiftUI

@available(iOS 14.0, *)
struct PhotoView_UI: View {
    let photo: UnsplashPhoto
    let onSelect: (UnsplashPhoto) -> Void
    
    @State private var imageDownloader = ImageDownloader()
    @State private var image: NativeImage?
    @State private var isHovered = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(nativeImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(photo.color ?? NativeColor.lightGray)
                }
            }
            .onHover { hover in
                withAnimation(.easeOut(duration: 0.15)) {
                    isHovered = hover
                }
            }
            .overlay(authorOverlay)
            .onTapGesture {
                onSelect(photo)
            }
            .onAppear {
                guard let url = sizedImageURL(from: geometry) else { return }
                imageDownloader.downloadPhoto(with: url) { image, isCached in
                    withAnimation(isCached ? nil : Animation.default) {
                        self.image = image
                    }
                }
            }
            .onDisappear {
                imageDownloader.cancel()
            }
        }
        .clipped()
    }
    
    private var authorOverlay: some View {
        VStack(alignment: .leading) {
            Spacer()
            
            if (isHovered) {
                Button(action: {
                    guard var url = photo.user.profileURL else { return }
                    url = url.appending(queryItems: [
                        URLQueryItem(name: "utm_source", value: "pompom"),
                        URLQueryItem(name: "utm_medium", value: "referral"),
                    ])
                    
                    openURL(url)
                }) {
                    Label(photo.user.displayName, systemImage: "arrow.up.forward.app")
                        .foregroundColor(.white)
                        .font(Font.system(size: 10).weight(.medium))
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .frame(height: 25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.0),
                                                                       Color.black.opacity(0.9)]),
                                           startPoint: .top, endPoint: .bottom)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func sizedImageURL(from geometry: GeometryProxy) -> URL? {
        let screenScale: CGFloat
        #if os(macOS)
        screenScale = NSScreen.main?.backingScaleFactor ?? 1.0
        #else
        screenScale = UIScreen.main.scale
        #endif
        guard let url = photo.urls[.regular] else { return nil }
        return url.appending(queryItems: [
            URLQueryItem(name: "w", value: "\(geometry.size.width)"),
            URLQueryItem(name: "dpr", value: "\(Int(screenScale))")
        ])
    }
}

//struct PhotoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoView()
//    }
//}

@available(iOS 13.0, *)
extension Image {
    
    init(nativeImage: NativeImage) {
        #if os(macOS)
        self.init(nsImage: nativeImage)
        #else
        self.init(uiImage: nativeImage)
        #endif
    }
    
}
