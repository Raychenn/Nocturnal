//
//  CacheManager.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/5.
//

import Foundation

class CacheManager {

    static let shared = CacheManager()
    private let fileManager = FileManager.default
    private lazy var mainDirectoryUrl: URL = {

    let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()

    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL, Error>) -> Void ) {

        let file = directoryFor(stringUrl: stringUrl)

        guard !fileManager.fileExists(atPath: file.path) else {
            completionHandler(.success(file))
            return
        }

        DispatchQueue.global().async {

            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)
                DispatchQueue.main.async {
                    completionHandler(.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "SomeErrorDomain", code: -2001 /* some error code */, userInfo: ["description": "Can't download video"])

                    completionHandler(.failure(error))
                }
            }
        }
    }

    private func directoryFor(stringUrl: String) -> URL {

        let fileURL = URL(string: stringUrl)!.lastPathComponent
        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL).appendingPathExtension("mp4")
        return file
    }
}
