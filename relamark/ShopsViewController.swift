//
//  ShopsViewController.swift
//  relamark
//
//  Created by mac on 2015/05/26.
//  Copyright (c) 2015年 AtsushiKawasaki. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ShopsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var table: UITableView!
    
    // 緯度経度
    var lat : Double = 0.0
    var lon : Double = 0.0
    
    // shop一覧
    var shopsDataArray = NSArray()
    
    var requestUrl = "http://relamark.link/api/v1/spots.json"
    
    var jsonData : JSON = []
    
    var imageUrl : String?
    
    var shopData : JSON = []
    
    var types : String?
    
    // menuボタンの生成 / サイズ指定
    var menuButton:UIButton! = UIButton(frame: CGRectMake(0, 0, 100, 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テーブルビューdelegateの設定
        table.dataSource = self
        table.delegate = self
        
        var parameters = [
            "lat" : "\(self.lat)",
            "lon" : "\(self.lon)"
        ]
        
        Alamofire.request(.GET, requestUrl, parameters: parameters).responseJSON
            {
                (request, response, json, errors) in
                let jsonDic = json as! NSDictionary
                self.shopsDataArray = jsonDic["results"] as! NSArray
                self.jsonData = JSON(json!)
                self.table.reloadData()
        }
        
        // ボタンの表示
        menuButton.layer.position = CGPoint(x: self.view.frame.width - 40, y: self.view.frame.height - 100)
        menuButton.setImage(UIImage(named: "button.png"), forState: .Normal)
        menuButton.addTarget(self, action: "tappedMenuButton:", forControlEvents:.TouchUpInside)
        self.view.addSubview(menuButton)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //返却セル数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shopsDataArray.count
    }
    
    // セルの内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        var shopDic = shopsDataArray[indexPath.row] as! NSDictionary
        
        var name = cell.viewWithTag(2) as! UILabel
        name.text = self.jsonData["results"][indexPath.row]["name"].string
        
        
        // URLから画像データの生成
        var iconUrl = NSURL(string: self.jsonData["results"][indexPath.row]["icon"].string!)
        var iconData : NSData = NSData(contentsOfURL: iconUrl!)!
        
        var photo = cell.viewWithTag(1) as! UIImageView
        photo.image = UIImage(data: iconData)
        photo.layer.cornerRadius = 3
        photo.layer.masksToBounds = true
        
        var typeArray = shopDic["types"] as! NSArray
        var types = cell.viewWithTag(3) as! UILabel
        types.text = typeArray.componentsJoinedByString(",")
        
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor(red: 0.988, green: 0.694, blue: 0, alpha: 1)
        } else {
            cell.backgroundColor = UIColor(red: 1, green: 0.322, blue: 0.204, alpha: 1)
        }
        println("\(indexPath.row)")
        return cell
        
    }
    
    // セルの高さ
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // セルタップ時のアクション
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.shopData = self.jsonData["results"][indexPath.row]
        println("タップ\(indexPath.row)")
        
        var shopDic = shopsDataArray[indexPath.row] as! NSDictionary
        var typeArray = shopDic["types"] as! NSArray
        self.types = typeArray.componentsJoinedByString(",")
        
        // ShopDetailへ遷移
        performSegueWithIdentifier("toShopDetailView", sender: self)
    }
    
    // 遷移時のデータ受け渡し
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 遷移先のインスタンス
        var shopDetail = segue.destinationViewController as! ShopDetailViewController
        // 登録済みのメンバ変数に格納
        shopDetail.shopDetail = shopData
        shopDetail.types = types
    }

    @IBAction func tappedMenuButton(sender: AnyObject) {
        //        var menu : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Menu")
        //        self.presentViewController(menu as! UIViewController, animated: true, completion: nil)
        let menuView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Menu") as! UIViewController;()
        menuView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController(menuView, animated: true, completion: nil)
        println("メニュータップ")
    }

    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
