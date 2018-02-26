//
//  APIClient.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 25.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import UIKit.UIImage



class APIClient
{
    public typealias GetJsonCallback = (_ json: [String : Any]?, _ headers: [String : Any], _ error: Error?) -> Void
    public typealias GetIconCallback = (_ image: UIImage?, _ error: Error?) -> Void
    
    
    
    public static func GetPartners(callback: @escaping GetJsonCallback) {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = "https"
        urlComponents.host = HOST_API
        urlComponents.path = PATH_PARTNERS
        urlComponents.queryItems = [ URLQueryItem(name: "accountType", value: "Credit") ]
        
        guard let url = urlComponents.url else {
            callback(nil, [:], NSError())
            return
        }
        
        URLSession.shared
            .jsonTask(with: url, callback: callback)
            .resume()
    }
    
    public static func GetPoints(center: CLLocationCoordinate2D, radius: Int, callback: @escaping GetJsonCallback) {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = "https"
        urlComponents.host = HOST_API
        urlComponents.path = PATH_POINTS
        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(center.latitude)"),
            URLQueryItem(name: "longitude", value: "\(center.longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)")
        ]
        
        guard let url = urlComponents.url else {
            callback(nil, [:], NSError())
            return
        }
        
        URLSession.shared
            .jsonTask(with: url, callback: callback)
            .resume()
    }
    
    public static func GetImageData(name: String) -> NSData? {
        let sizeClass = SizeClass.current.rawValue
        
        guard let url = URL(string: "https://\(HOST_STATIC)/\(PATH_ICONS)/\(sizeClass)/\(name)") else {
            return nil
        }
        
        return try? NSData(contentsOf: url)
    }
}



extension URLSession
{
    func jsonTask(with url: URL, callback: @escaping APIClient.GetJsonCallback) -> URLSessionDataTask {
        return
            self.dataTask(with: url) { (data, response, error) in
                let headers = response?.headers ?? [:]
                
                guard error == nil else {
                    print("Request: \(url)\nError: \(error!.localizedDescription)")
                    callback(nil, headers, error)
                    return
                }
                
                guard data != nil else {
                    print("Request: \(url)\nData: null")
                    callback(nil, headers, NSError())
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] else {
                    print("Request: \(url)\nInvalid data")
                    callback(nil, headers, NSError())
                    return
                }
                
                callback(json, headers, nil)
        }
    }
}


extension URLResponse
{
    var headers: [String : Any] {
        var headers: [String : Any]?
        
        if let httpResponse = self as? HTTPURLResponse {
            headers = httpResponse.allHeaderFields as? [String : Any]
        }
        
        return headers ?? [:]
    }
}
