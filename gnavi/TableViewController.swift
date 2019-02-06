//
//  TableViewController.swift
//  gnavi
//
//  Created by Taro Kimura on 2019/02/01.
//  Copyright © 2019 Taro Kimura. All rights reserved.
//


import UIKit
import Alamofire

class TableViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate

    var cellIndex:Int!
    
    //API KEY https://api.gnavi.co.jp/api/
    var apiKey="edaee2d5bb66a0392892d6a1e7afc44e"
    
    var url = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url.append("?keyid="+apiKey)
        requestAPI()
    }
    
    func requestAPI(){
        delegate.apiResult=[]
        delegate.totalHitCount=0
        
        //テキストフィールドの値を取得
        if delegate.searchKeyword != "" {
            url.append("&name="+delegate.searchKeyword)
        }
        
        //位置情報の取得
        if delegate.latitude != 0 && delegate.longitude != 0{
            url.append("&latitude="+String(delegate.latitude))
            url.append("&longitude="+String(delegate.longitude))
            url.append("&range="+String(delegate.searchRange))
        }
        //一度のリクエストで得るレスポンスの最大件数
        url.append("&hit_per_page=50")
        
        print(url)
        
        //URLをエンコード
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        //APIにアクセス
        Alamofire.request(encodedUrl).response { response in
            guard let data = response.data else {
                print("error")
                return
            }
            //Codabledでデコード
            let json = try? JSONDecoder().decode(result.self, from: data)
            
            //検索結果が0の場合
            if let error_result = json?.error {
                for i in  0..<error_result.count {
                    
                    self.delegate.totalHitCount = 0
                    self.delegate.apiResult=[]
                    
                    let alertController = UIAlertController(title: "指定された条件の店舗が見つかりませんでした", message: nil, preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                        
                        //0.5秒後に遷移
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.performSegue(withIdentifier: "backVC", sender: nil)
                        }
                    })
                    
                    alertController.addAction(okAction)
                    
                    //アラートを表示する
                    self.present(alertController, animated: true, completion: nil)
                    
                    print("error:\(error_result[i].code!) \(error_result[i].message!)")
                }
            }else{
                self.delegate.totalHitCount = json!.rest!.count
                self.delegate.apiResult=json!.rest!
                print("totalhitcount \(self.delegate.totalHitCount)")
                print(self.delegate.apiResult)
            }
            //テーブルをリロード
            self.tableView.reloadData()
        }
    }
    
    //cellのセクション数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.totalHitCount
    }
    //cellにデータを格納
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell
        //店舗名
        cell.nameLabel.text=delegate.apiResult[indexPath.row].name
        
        var stationAccess:String=""
        //アクセス
        if let access = delegate.apiResult[indexPath.row].access{
        
            if let line = access.line{
                stationAccess.append(line)
            }
            if let station = access.station{
                stationAccess.append(station)
                
                if let station_exit = access.station_exit, station_exit != "" {
                    stationAccess.append(" " + station_exit)
                }
                if let walk = access.walk, walk != "" {
                    stationAccess.append(" " + walk + "分")
                }
            }
            cell.accessLabel.text=stationAccess
        }
        //イメージ
        if let images = delegate.apiResult[indexPath.row].image_url, images.shop_image1 != "" {
            let image_url = URL(string: images.shop_image1!)!
            do{
                let imageData = try Data(contentsOf: image_url)
                let image = UIImage(data:imageData)
                cell.mainImage.image=image
            } catch {
                print(error)
            }
        }else{
            cell.mainImage.image=UIImage(named:"noimg")
        }
        return cell
    }
  
    //詳細画面に遷移
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        cellIndex = indexPath.row
        performSegue(withIdentifier: "toDetailTableView",sender: nil)
    }
    //遷移先にデータを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toDetailTableView") {
            let dc = segue.destination as! DetailTableViewController
            dc.cellIndex = cellIndex
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

struct result:Codable{
    let total_hit_count: Int?
    let hit_per_page: Int?
    let page_offset:Int?
    let rest:[rest]?
    let error:[error]?
}

struct rest:Codable {
    let name:String?
    let name_kana: String?
    let latitude:String?
    let longitude:String?
    let url: String?
    let url_mobile: String?
    let image_url:imageUrl?
    let address: String?
    let tel: String?
    let opentime : String?
    let access:access?
}

struct imageUrl:Codable{
    let shop_image1 : String?
    let shop_image2 : String?
    let qrcode :String?
}
struct access:Codable{
    let line: String?
    let station: String?
    let station_exit : String?
    let walk : String?
    let mote : String?
}

struct error:Codable{
    let code:Int?
    let message: String?
}
