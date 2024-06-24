//
//  UnsplashPhotoPicker_ViewModel.swift
//  
//
//  Created by Michał Śmiałko on 15/10/2021.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
internal class UnsplashPhotoPicker_ViewModel: NSObject, ObservableObject, PagedDataSourceDelegate {
    
    @Published var searchPhrase = ""
    @Published var isLoading = false
    
    @Published private(set) var items: [UnsplashPhoto] = []
    
    private(set) var dataSource: PagedDataSource = PhotosDataSourceFactory.collection(identifier: Configuration.shared.editorialCollectionId).dataSource {
        didSet {
            oldValue.cancelFetch()
            items = []
            dataSource.delegate = self
        }
    }
    
    private var sinks: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        
        let editorialDataSource = PhotosDataSourceFactory.collection(identifier: Configuration.shared.editorialCollectionId).dataSource
        $searchPhrase
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { text -> PagedDataSource in
                text.isEmpty ? editorialDataSource : PhotosDataSourceFactory.search(query: text).dataSource
            }
            .sink { [weak self] in
                self?.dataSource = $0
                self?.dataSource.fetchNextPage()
            }
            .store(in: &sinks)
    }
    
    // MARK: - PagedDataSourceDelegate
    
    func dataSourceWillStartFetching(_ dataSource: PagedDataSource) {
        isLoading = true
    }
    
    func dataSource(_ dataSource: PagedDataSource, didFetch items: [UnsplashPhoto]) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.items.append(contentsOf: items)
        }
    }
    
    func dataSource(_ dataSource: PagedDataSource, fetchDidFailWithError error: Error) {
        
    }
}
