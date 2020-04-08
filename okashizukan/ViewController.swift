//
//  ViewController.swift
//  okashizukan
//
//  Created by 金澤武士 on 2020/04/07.
//  Copyright © 2020 tk. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        //serach barのデリゲート通知先を設定
        searchText.delegate = self
        //プレースホルダ
        searchText.placeholder = "お菓子の名前を入力して下さい"
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボード閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            //デバッグエリアに出力
            print(searchWord)
            //入力されていたら、お菓子を検索
            searchOkashi(keyword: searchWord)
        }
    }
    //JSONのItem内のデータ構造
    struct ItemJson: Codable {
    //お菓子名
        let name:String?
        //メーカー
        let maker:String?
        //掲載URL
        let url:URL?
        //画像URL
        let image: URL?
    }
    //JSONのデータ構造
    struct ResulsJson: Codable {
        //複数要素
        let item:[ItemJson]
    }
    
    override class func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {
        
    }
    
    //第一引数：Keyword 検索したいワード
    func searchOkashi(keyword:String) {
        //お菓子の検索ワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else {
                return
        }
        //リクエストURL
        guard  let req_url = URL(string: "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r")else {
            return
        }
        print(req_url)
        
        //リクエストURLいに必要な情報を生成
        let req = URLRequest (url: req_url)
        //だデータ転送のためのセッション
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        //リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data,response,error) in
        //セッション終了
            session.finishTasksAndInvalidate()
            do {
                //JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                //受け取ったJSONデータをパースして格納
                let json = try decoder.decode(ResulsJson.self, from: data!)
                print(json)
                
            } catch {
                print("error")
            }
        })
        //ダウンロード開始
        task.resume()
    }
}

