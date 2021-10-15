//
//  PhotoView.swift
//  
//
//  Created by Michał Śmiałko on 15/10/2021.
//

import SwiftUI

struct PhotoView: View {
    let photo: UnsplashPhoto
    let onSelect: (UnsplashPhoto) -> Void
    
    @State private var imageDownloader = ImageDownloader()
    @State private var image: NativeImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(photo.color ?? NativeColor.lightGray)
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
            
            Text(photo.user.displayName)
                .foregroundColor(.black)
                .font(Font.system(size: 10).weight(.medium))
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(5)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.clear,
                                                               Color.white.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                )
        }
    }
    
    private func sizedImageURL(from geometry: GeometryProxy) -> URL? {
        let screenScale = NSScreen.main?.backingScaleFactor ?? 1.0
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
