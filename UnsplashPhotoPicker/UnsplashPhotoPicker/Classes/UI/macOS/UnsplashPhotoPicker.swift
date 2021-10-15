//
//  UnsplashPhotoPicker.swift
//  
//
//  Created by Michał Śmiałko on 15/10/2021.
//

import SwiftUI

public struct UnsplashPhotoPicker: View {
    
    let configuration: UnsplashPhotoPickerConfiguration
    let onSelect: ([UnsplashPhoto]) -> Void
    let onCancel: () -> Void
    
    @StateObject private var viewModel = UnsplashPhotoPicker_ViewModel()
    
    public init(configuration: UnsplashPhotoPickerConfiguration,
                onSelect: @escaping ([UnsplashPhoto]) -> Void,
                onCancel: @escaping () -> Void) {
        self.configuration = configuration
        self.onSelect = onSelect
        self.onCancel = onCancel
        Configuration.shared = configuration
    }
    
    private func itemsAtColumn(_ idx: Int) -> [UnsplashPhoto] {
        // TODO: Make smarter layout
        stride(from: idx, to: viewModel.items.count, by: 2)
            .lazy
            .map { viewModel.items[$0] }
    }
    
    private func columnGrid(idx: Int, colWidth: CGFloat) -> some View {
        let columns = [GridItem(.fixed(colWidth), spacing: 10, alignment: .top)]
        return LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(itemsAtColumn(idx)) { photo in
                let ratio = CGFloat(photo.height) / CGFloat(photo.width)
                PhotoView(photo: photo, onSelect: { onSelect([$0]) })
                    .frame(width: colWidth, height: colWidth * ratio)
            }
        }
        .frame(width: colWidth)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                
                VStack {
                    TextField("Search photos", text: $viewModel.searchPhrase)
                        .font(Font.system(size: 18).weight(.medium))
                        .padding([.top, .horizontal])
                    
                    ScrollView(.vertical) {
                        
                        
                        let colWidth: CGFloat = geometry.size.width / 3 - 10 * 2
                        
                        HStack(alignment: .top) {
                            columnGrid(idx: 0, colWidth: colWidth)
                            columnGrid(idx: 1, colWidth: colWidth)
                            columnGrid(idx: 2, colWidth: colWidth)
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                        } else if viewModel.items.isEmpty {
                            Text("No result")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(30)
                        } else {
                            Button(action: {
                                viewModel.dataSource.fetchNextPage()
                            }) {
                                Text("Load More")
                            }
                            .buttonStyle(LinkButtonStyle())
                            .padding()
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: { onCancel() }) {
                    Text("Cancel")
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .frame(width: 500, height: 500, alignment: .top)
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
