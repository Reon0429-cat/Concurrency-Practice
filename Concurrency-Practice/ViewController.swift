//
//  ViewController.swift
//  Concurrency-Practice
//
//  Created by 大西玲音 on 2022/04/08.
//

import UIKit

struct Item: Decodable {
    let name: String
}

typealias ResultHandler<T> = (Result<T, Error>) -> Void

enum APIError: Error {
    case a
    case b
    case c
    case d
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task.detached {
            await self.a()
        }
        
        Task.detached {
            let result = await self.b()
            print("DEBUG_PRINT: ", result)
        }
        
        // 今までのコード実行
        fetchData { result in
            switch result {
            case .success(let item):
                print("DEBUG_PRINT: ", "通信成功\(item)")
            case .failure(let error):
                print("DEBUG_PRINT: ", "通信失敗\(error)")
            }
        }
        
        
        
        // async/awaitのコード実行
        Task.detached {
            let (item, error) = await self.fetchData()
            if let error = error {
                print("DEBUG_PRINT: ", "通信失敗\(error)")
            } else {
                print("DEBUG_PRINT: ", "通信成功\(item!)")
            }
        }
        
    }
    
    // 今までのコード
    func fetchData(completion: @escaping ResultHandler<Item>) {
        guard let urlString = URL(string: "https://...") else {
            completion(.failure(APIError.a))
            return
        }
        let request = URLRequest(url: urlString)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(APIError.a))
                return
            }
            guard response != nil else {
                completion(.failure(APIError.b))
                return
            }
            if let data = data {
                guard let item = try? JSONDecoder().decode(Item.self, from: data) else {
                    completion(.failure(APIError.c))
                    return
                }
                completion(.success(item))
            } else {
                completion(.failure(APIError.d))
                return
            }
        }
        task.resume()
    }
    
    // async/awaitをつかったコード
    func fetchData() async -> (Item?, Error?) {
        guard let urlString = URL(string: "https://...") else {
            return (nil, APIError.a)
        }
        let request = URLRequest(url: urlString)
        guard let (data, response) = try? await URLSession.shared.data(for: request) else {
            return (nil, APIError.c)
        }
        guard let _ = response as? HTTPURLResponse else {
            return (nil, APIError.c)
        }
        guard let item = try? JSONDecoder().decode(Item.self, from: data) else {
            return (nil, APIError.b)
        }
        return (item, nil)
    }
    
    

    func a() async {
        print("DEBUG_PRINT: ", #function)
    }
    
    let isLoading = false
    
    func b() async -> String {
        if isLoading {
            return "ロード中"
        }
        return "ロード完了"
    }
    
    func waitOneSecond() async {
        print("DEBUG_PRINT: ", "１秒まつ")
    }
    
    // 直列処理
    func runAsSequence() async {
        await waitOneSecond()
        await waitOneSecond()
        await waitOneSecond()
    }
    
    // 並列処理
    func runAsSequence2() async {
        // async letでプログラムの終了を待たずに次の行に行く
        async let first: Void = waitOneSecond()
        async let second: Void = waitOneSecond()
        async let third: Void = waitOneSecond()
        await first
        await second
        await third
    }
    
    func aa() async throws -> String {
        return ""
    }
    
    func bb() async throws -> String? {
        let aa = try? await aa()
        return aa
    }
    
}

