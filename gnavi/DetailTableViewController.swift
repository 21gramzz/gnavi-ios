//
//  DetailTableViewController.swift
//  gnavi
//
//  Created by Taro Kimura on 2019/02/04.
//  Copyright © 2019 Taro Kimura. All rights reserved.
//

import UIKit

class DetailTableViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var cellIndex:Int!
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //Section
    let sectionArray=["店名","住所","アクセス","Tel","営業時間"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    //SectionあたりのCell数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    //Sectionのラベルを設定
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section] as? String
    }
    
    //Cellにデータをセット
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for:indexPath) as! DetailCustomCell
        //イメージ
        if let images = delegate.apiResult[cellIndex].image_url,images.shop_image2 != ""{
            do{
                let image_url = URL(string: images.shop_image2!)!
                let imageData = try Data(contentsOf: image_url)
                let image = UIImage(data:imageData)
                mainImage.image=image
            }catch{
                print("error")
            }
        }else{
           
        }
        //店舗名
        if indexPath.section == 0, let name = delegate.apiResult[cellIndex].name{
            cell.infoText.text = name
        }
        //住所
        else if indexPath.section == 1, let address = delegate.apiResult[cellIndex].address {
            cell.infoText.text = address
            }
        //アクセス
        else if indexPath.section == 2, let access = delegate.apiResult[cellIndex].access{
            var stationAccess:String=""
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
            cell.infoText.text=stationAccess
        }
        //電話番号
        else if indexPath.section == 3, let tel = delegate.apiResult[cellIndex].tel {
            //ラベルをリンク化
            var baseString = tel
            
            let attributedString =  NSMutableAttributedString(string: baseString)
            attributedString.addAttribute(NSAttributedString.Key.link,value: "tel://\(tel)",range: NSString(string: baseString).range(of: tel))
            
            cell.infoText.attributedText = attributedString
            cell.infoText.font = UIFont.systemFont(ofSize: 17)
            cell.infoText.isSelectable = true
        }
        //営業時間
        else if indexPath.section == 4, let openTime = delegate.apiResult[cellIndex].opentime {
            cell.infoText.text = openTime
        }
        return cell
    }
}
