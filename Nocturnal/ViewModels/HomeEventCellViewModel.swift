//
//  HomeEventCellViewModel.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/18.
//

import Foundation

class HomeEventCellViewModel {
    private let event: Event
    private var host: User?
    
    var shouldShowVideo: ObservableObject<Bool> = ObservableObject(value: false)
        
    var eventImageViewURL: URL? { URL(string: event.eventImageURL) }
    
    var eventVideoURLString: String? {
        if let videoURL = event.eventVideoURL {
            shouldShowVideo.value = true
            return videoURL
        } else {
            shouldShowVideo.value = false
            return nil
        }
    }

    var eventDate: String {
        return Date.dateFormatter.string(from: event.startingDate.dateValue())
    }
    
    var eventName: String { event.title }
    
    var eventFee: String { "$\(event.fee)" }
    
    var hostName: String {
        if let host = host {
            return host.name
        } else {
            return "Unkown User"
        }
    }
    
    var hostProfileURL: URL? {
        return host == nil ? nil: URL(string: host!.profileImageURL)!
    }
    
    init(event: Event, host: User?) {
        self.event = event
        self.host = host
    }
    
    // MARK: - Helpers

}
