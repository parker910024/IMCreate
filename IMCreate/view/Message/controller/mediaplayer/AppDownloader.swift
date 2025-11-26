//
//  CacheManager.swift
//  AI Papa
//
//  Created by AI Papa on 2024/11/23.
//

import Foundation
import UIKit
import AVFoundation
import CryptoKit

extension UIImage {
    
    /// 矫正方向：将图像渲染为 `.up` 方向
    var fixedOrientation:UIImage {
        guard imageOrientation != .up else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}

extension String {
    var sha256: String {
        let data = Data(self.utf8)
        let digest = SHA512.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

class AppDownloader:NSObject, URLSessionDownloadDelegate {
    
    private var downloadInfo:[Int:NSKeyValueObservation] = [:];
    
    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        NSLog("didCreateTask: \(task.taskIdentifier)");
        
        guard let url = task.originalRequest?.url else { return ; }
        
        guard let method = task.originalRequest?.httpMethod else { return ; }
        if method == "GET" {
            let observer = task.progress.observe(\.fractionCompleted) { progress, value in
                DispatchQueue.main.async {
                    var userInfo:[String:Any] = [:];
                    userInfo[Self.kApplicationVideoProgressKey] = progress.fractionCompleted;
                    userInfo[Self.kApplicationVideoURLKey] = url;
                    NotificationCenter.default.post(name: NSNotification.Name(Self.kApplicationDidVideoProgressNotifition), object: nil, userInfo: userInfo);
                }
            }
            downloadInfo[task.taskIdentifier] = observer;
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        downloadInfo.removeValue(forKey: task.taskIdentifier)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        NSLog("didFinishDownloadingTo: \(location)")
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        NSLog("totalBytesExpectedToWrite:\(totalBytesExpectedToWrite), totalBytesWritten:\(totalBytesWritten)")
    }
    
    private static let _engine: AppDownloader = AppDownloader();
    static let shared: AppDownloader = {
        return _engine;
    }();
    
    private var _cachePath:String = "";
    
    static var kApplicationDidCacheVideoNotifition = "kApplicationDidCacheVideoNotifition";

    func createACacheURL() -> URL {
        let path = "\(_cachePath)/\(UUID().uuidString).mp4";
        return URL(fileURLWithPath: path);
    }
    
    func save(image:UIImage, jpeg:Bool = false, compressionQuality:CGFloat = 1.0) -> String? {
        let v = image.fixedOrientation;
        let png:Data;
        if jpeg {
            guard let binary = v.jpegData(compressionQuality: 1.0) else { return nil }
            png = binary;
        }
        else {
            guard let binary = v.pngData() else { return nil; }
            png = binary
        }
        return save(binary: png);
    }
    
    func save(binary:Data) -> String? {
        let imagePath = "\(UUID().uuidString).png";
        let png:Data = binary;
        let path = URL(fileURLWithPath: "\(_cachePath)/\(imagePath)");
        do {
            try png.write(to: path)
        }
        catch(_) {
            return nil;
        }
        return imagePath;
    }
    
    func absolutePath(relative:String) -> String {
        if FileManager.default.fileExists(atPath: relative) {
            return relative;
        }
        return "\(_cachePath)/\(relative)";
    }    

    func cacheVideo(video:String) async {
        guard let url = URL(string: video) else { return ; }
        let request = URLRequest(url: url)
        do {
            let (location, response) = try await URLSession.shared.download(for: request);
            guard let response = response as? HTTPURLResponse else { return ; }
            if response.statusCode != 200 {
                return;
            }
            if let _ = cache(forURL: video) {
                return;
            }
            let path = "\(_cachePath)/\(url.absoluteString.sha256).mp4";
            let toPath = URL(fileURLWithPath: path);
            
            try FileManager.default.moveItem(atPath: location.path, toPath: toPath.path);
            await MainActor.run {
                NotificationCenter.default.post(name: .init(AppDownloader.kApplicationDidCacheVideoNotifition), object: url.absoluteString);
            }
        }
        catch (let exception) {
            NSLog("Download Video Exception:\(exception)")
        }
    }
    
    static var kApplicationDidDownloadVideoNotifition = "kApplicationDidDownloadVideoNotifition";
    static var kApplicationDidVideoProgressNotifition = "kApplicationDidVideoProgressNotifition";
    
    static var kApplicationVideoProgressKey = "kApplicationVideoProgressKey";
    static var kApplicationVideoURLKey = "kApplicationVideoURLKey";
    
    var cachePath:String {
        return _cachePath;
    }
    
    
    func setup(){
        _cachePath = NSHomeDirectory() + "/Documents/cache/video";
        do {
            try FileManager.default.createDirectory(atPath: _cachePath, withIntermediateDirectories: true);
        }
        catch (let exception){
            NSLog("Cache create failure:\(exception)");
        }
    }
    
    func cache(forURL:String) -> URL? {
        if !forURL.hasPrefix("http") {
            return URL(string: forURL);
        }
        let u = forURL.sha256;
        let path = "\(_cachePath)/\(u).mp4";
        let exist = FileManager.default.fileExists(atPath: path);
        if exist {
            return URL(fileURLWithPath: path);
        }
        return nil;
    }
    
    private func createCache(forURL:URL) -> URL {
        return URL(fileURLWithPath: "\(_cachePath)/\(forURL.absoluteString.sha256).mp4");
    }
   
    
    func download(video:String, withProgress:Bool = false) async -> (Bool, URL?) {
        if let p = cache(forURL: video) {
            return (true, p);
        }
        guard let url = URL(string: video) else { return (false, nil); }
        let request = URLRequest(url: url)
        do {
            let location:URL;
            let response:URLResponse;
            if withProgress {
                (location, response) = try await URLSession.shared.download(for: request, delegate: self);
            }
            else {
                (location, response) = try await URLSession.shared.download(for: request);
            }
            guard let response = response as? HTTPURLResponse else { return (false, nil); }
            if response.statusCode != 200 {
                return (false, nil);
            }
            if let p = cache(forURL: video) {
                return (true, p);
            }
            try FileManager.default.moveItem(atPath: location.path, toPath: createCache(forURL: url).path);
            await MainActor.run {
                NotificationCenter.default.post(name: .init(Self.kApplicationDidDownloadVideoNotifition), object: url.absoluteString);
            }
            if let p = cache(forURL: video) {
                return (true, p);
            }
            return (false, nil);
        }
        catch (let exception) {
            NSLog("download video Exception:\(exception)")
            return (false, nil);
        }
    }
    
    func put(_ image:String, url:String) async -> Bool {
        do {
            var request = URLRequest(url: URL(string: url)!);
            request.httpMethod = "PUT";
            let (_, response) = try await URLSession.shared.upload(for: request, fromFile: URL(fileURLWithPath: image));
            guard let response = response as? HTTPURLResponse else { return false }
            return response.statusCode == 200;
        }
        catch(let exception) {
            NSLog("put method exception:\(exception)");
        }
        return false;
    }

}
