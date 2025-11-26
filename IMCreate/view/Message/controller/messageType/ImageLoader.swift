//
//  ImageLoader.swift
//  IMCreate
//
//  Created by admin on 2025/11/26.
//

import UIKit

final class ImageLoader: NSObject, URLSessionDataDelegate {
    static let shared = ImageLoader()

    private struct TaskInfo {
        var data = Data()
        var expectedLength: Int64 = NSURLSessionTransferSizeUnknown
        var progress: ((Double) -> Void)?
        var completion: ((UIImage?) -> Void)?
    }

    private var tasks: [Int: TaskInfo] = [:]
    private lazy var session: URLSession = {
        let cfg = URLSessionConfiguration.default
        return URLSession(configuration: cfg, delegate: self, delegateQueue: OperationQueue.main)
    }()

    // start loading, returns taskIdentifier
    @discardableResult
    func load(url: URL, progress: ((Double) -> Void)? = nil, completion: ((UIImage?) -> Void)? = nil) -> Int {
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req)
        tasks[task.taskIdentifier] = TaskInfo(data: Data(), expectedLength: NSURLSessionTransferSizeUnknown, progress: progress, completion: completion)
        task.resume()
        return task.taskIdentifier
    }

    func cancel(taskId: Int) {
        session.getAllTasks { all in
            all.first(where: { $0.taskIdentifier == taskId })?.cancel()
            DispatchQueue.main.async {
                self.tasks[taskId] = nil
            }
        }
    }

    // MARK: URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        var info = tasks[dataTask.taskIdentifier] ?? TaskInfo()
        info.expectedLength = response.expectedContentLength
        tasks[dataTask.taskIdentifier] = info
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard var info = tasks[dataTask.taskIdentifier] else { return }
        info.data.append(data)
        if info.expectedLength > 0 {
            let p = Double(info.data.count) / Double(info.expectedLength)
            DispatchQueue.main.async {
                info.progress?(p)
            }
        } else {
            DispatchQueue.main.async {
                info.progress?(0)
            }
        }
        tasks[dataTask.taskIdentifier] = info
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let info = tasks[task.taskIdentifier] else { return }
        defer { tasks[task.taskIdentifier] = nil }
        if let _ = error {
            DispatchQueue.main.async { info.completion?(nil) }
            return
        }
        let img = UIImage(data: info.data)
        DispatchQueue.main.async { info.completion?(img) }
    }
}
