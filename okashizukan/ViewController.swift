//
//  ViewController.swift
//  okashizukan
//
//  Created by 金澤武士 on 2020/04/07.
//  Copyright © 2020 tk. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        //serach barのデリゲート通知先を設定
        searchText.delegate = self
        //プレースホルダ
        searchText.placeholder = "お菓子の名前を入力して下さい"
        //TableViewのdataSourceを設定
        tableview.dataSource = self
        //TableView delegate
        tableview.delegate = self
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableview: UITableView!

    //お菓子のリスト(タプル配列)
    var okashiList: [(maker: String, name: String, link: URL, image: URL)] = []

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
        let name: String?
        //メーカー
        let maker: String?
        //掲載URL
        let url: URL?
        //画像URL
        let image: URL?
    }
    //JSONのデータ構造
    struct ResulsJson: Codable {
        //複数要素
        let item: [ItemJson]
    }

    override class func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {

    }

    //第一引数：Keyword 検索したいワード
    func searchOkashi(keyword: String) {
        //お菓子の検索ワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else {
                return
        }
        //リクエストURL
        guard let req_url = URL(string: "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r")else {
            return
        }
        print(req_url)

        //リクエストURLいに必要な情報を生成
        let req = URLRequest (url: req_url)
        //だデータ転送のためのセッション
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        //リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            //セッション終了
            session.finishTasksAndInvalidate()
            do {
                //JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                //受け取ったJSONデータをパースして格納
                let json = try decoder.decode(ResulsJson.self, from: data!)
                //お菓子の情報が取得できているか確認
                let items = json.item
                //リスト初期化
                self.okashiList.removeAll()
                //取得しているお菓子の数だけ処理
                for item in items {

                    //メーカー名、おお菓子の名称、URL,画像URLをアンラップ
                    if let maker = item.maker, let name = item.name, let link = item.url, let image = item.image {
                        //一つのお菓子をタプルでまとめて管理
                        let okashi = (maker, name, link, image)
                        //お菓子の配列へ追加
                        self.okashiList.append(okashi)
                    }
                }
                //TableView更新
                self.tableview.reloadData()

                if let okashidbg = self.okashiList.first {
                    print("------------------")
                    print("okashiList[0] = \(okashidbg)")
                }
            } catch {
                print("error")
            }
        })
        //ダウンロード開始
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return okashiList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        cell.textLabel?.text = okashiList[indexPath.row].name
        //画像取得
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image) {
            //取得できたら、UIImageで画像オブジェクトを生成して、cellにお菓子画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //safariView
        let safariViewControler = SFSafariViewController(url: okashiList[indexPath.row].link)
        
        //delegate
        safariViewControler.delegate = self
        //safariview開く
        present(safariViewControler,animated: true,completion: nil)
    }
    //safariview閉じた時
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //safariviw閉じる
        dismiss(animated: true, completion: nil)
    }
}

