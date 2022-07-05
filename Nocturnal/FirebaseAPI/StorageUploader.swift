//
//  ImageUploader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import FirebaseStorage
import Foundation

struct StorageUploader {
    
    static let shared = StorageUploader()
    
    func uploadEventVideo(videoUrl: URL, completion: @escaping (String) -> Void) {
        let fileName = UUID().uuidString
        
        let ref = Storage.storage().reference(withPath: "event_videos/\(fileName)")
        
        do {
            let videoData = try Data(contentsOf: videoUrl)
            
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            ref.putData(videoData, metadata: metadata) { _, error in
                guard error == nil else {
                    print("Fail to upload video \(error!)")
                    return
                }
                
                ref.downloadURL { downloadedUrl, error in
                    guard error == nil else {
                        print("error downloading images \(String(describing: error))")
                        return
                    }
                    
                    guard let downloadedUrlString = downloadedUrl?.absoluteString else { return }
                    completion(downloadedUrlString)
                }
            }
        } catch {
            print("Fail to convert video url to data \(error)")
        }

    }
    
    func uploadMessageImage(with image: UIImage, completion: @escaping (String) -> Void) {
        
        // make the file a little smaller
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let fileName = UUID().uuidString
        
        let ref = Storage.storage().reference(withPath: "message_images/\(fileName)")
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("fail to upload image: \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                guard error == nil else {
                    print("error downloading images \(String(describing: error))")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                
                completion(imageUrl)
            }
        }
    }
    
    func uploadEventImage(with image: UIImage, completion: @escaping (String) -> Void) {
        
        // make the file a little smaller
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let fileName = UUID().uuidString
        
        let ref = Storage.storage().reference(withPath: "event_images/\(fileName)")
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("fail to upload image: \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                guard error == nil else {
                    print("error downloading images \(String(describing: error))")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                
                completion(imageUrl)
            }
        }
    }
    
    func uploadEventMusic(with musicData: Data, completion: @escaping (String) -> Void) {
        
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "event_music/\(fileName)")
        let metadata = StorageMetadata()
        metadata.contentType = "audio/mpeg"
        
        ref.putData(musicData, metadata: metadata) { _, error in
            guard error == nil else {
                print("Fail to upload music \(String(describing: error))")
                return
            }
            
            ref.downloadURL { url, error in
                guard error == nil else {
                    print("error downloading images")
                    return
                }
                
                guard let musicUrl = url?.absoluteString else { return }
                
                completion(musicUrl)
            }
        }
    }
    
    func uploadProfileImage(with image: UIImage, completion: @escaping (String) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        let fileName = UUID().uuidString
        
        let ref = Storage.storage().reference(withPath: "profile_images/\(fileName)")
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("fail to upload image: \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                guard error == nil else {
                    print("error downloading images")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                
                completion(imageUrl)
            }
        }
    }
}
