//
//  ViewController.swift
//  DailySentence
//
//  Created by Chen Hsin Hsuan on 2015/5/10.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import UIKit
import CoreData
import Spring
import KDEAudioPlayer
import GoogleMobileAds


let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
let managedContext = appDelegate.managedObjectContext!


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UISearchBarDelegate, UISearchResultsUpdating {


    @IBOutlet weak var favorButton: SpringButton!
    @IBOutlet weak var dailySentencesButton: SpringButton!
    @IBOutlet weak var networkAlertView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var rowsNumberLabel: UILabel!
    
    var resultSearchController = UISearchController()
    let player = AudioPlayer()
    var sentences = [CDSentence]()
    var filterSentences = [CDSentence]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailySentencesButton.selected = true
        
        if(Reachability.isConnectedToNetwork()){
            networkAlertView.hidden = true
        }else{
            networkAlertView.hidden = false
        }
        
        queryData()
        
        
        //廣告設定
        let request = GADRequest()
        request.testDevices = [
        "ffd5b4c17425a518e4f9c99b1738ae16" //AirPhone
        ];
        
        adBannerView.loadRequest(request)
        
        
        
        //SearchBar設定
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            controller.searchBar.placeholder = "作者/內容/日期"
            return controller
        })()
        
        tableView.contentOffset = CGPointMake(0, 44)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK:撈資料
    func queryData(){
        //撈資料
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "CDSentence")
        let sortDescriptor =  NSSortDescriptor(key: "createat", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        if(favorButton.selected){
            fetchRequest.predicate = NSPredicate(format: "favormk == %@", argumentArray: [true])
        }
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [CDSentence]
        
        if fetchResults?.count > 0 {
            sentences = fetchResults!
        }else{
            sentences = [CDSentence]()
        }
        
        tableView.reloadData()
        
    }

    
    
    
    //MAKR:Table 處理
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.resultSearchController.active) {
            rowsNumberLabel.text = "\(filterSentences.count)筆"
            return filterSentences.count
        }
        rowsNumberLabel.text = "\(sentences.count)筆"
        return sentences.count+1
    }
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row == sentences.count){
            return 150
        }
        
        
        let theCDSentence = sentences[indexPath.row]
        let enLabelHeight = (returnStringSize(StringData: theCDSentence.en, MaxSize: CGSizeMake(self.view.frame.width-79, 1000000), TextFont: UIFont.italicSystemFontOfSize(20)) as CGSize).height
        let cnLabelHeight = (returnStringSize(StringData: theCDSentence.cn, MaxSize: CGSizeMake(self.view.frame.width-79, 1000000), TextFont: UIFont.systemFontOfSize(17)) as CGSize).height
        
        return enLabelHeight+cnLabelHeight+18+80+100
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if(indexPath.row == sentences.count){
            let cell = tableView.dequeueReusableCellWithIdentifier("BornCell", forIndexPath: indexPath) as! BornTableViewCell
            cell.bornLabel.text = NSUserDefaults.standardUserDefaults().valueForKey("bornDate") as? String
            return cell
        }
        
    
        let cell = tableView.dequeueReusableCellWithIdentifier("SentenceCell", forIndexPath: indexPath) as! SentenceTableViewCell
        
        
        var theCDSentence:CDSentence

        if (self.resultSearchController.active) {
            theCDSentence = filterSentences[indexPath.row]
        }else{
            theCDSentence = sentences[indexPath.row]
        }
        
        
        
        // Configure the cell...

        cell.authorLabel.text = theCDSentence.author
        cell.cnLabel.text = theCDSentence.cn
        cell.enLabel.text = theCDSentence.en
        cell.createAtLabel.text = theCDSentence.createat
        cell.favorButton.selected = theCDSentence.favormk.boolValue
        if(Reachability.isConnectedToNetwork()){
//            dispatch_async(dispatch_get_main_queue(), {
//                let url = NSURL(string: theCDSentence.url)
//                let data = NSData(contentsOfURL: url!)
//                if(data?.length > 0){
//                    cell.authorImageView.image = UIImage(data: data!)
//                }
//            })
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                // do some task
                let url = NSURL(string: theCDSentence.url)
                let data = NSData(contentsOfURL: url!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    // update some UI
                    if(data?.length > 0){
                        cell.authorImageView.image = UIImage(data: data!)
                    }
                    });
                });
        }else{
            cell.authorImageView.image = UIImage(named: "defaultmanager")
        }
        
        
        return cell
    }


    @IBAction func favorButtonPressed(sender: AnyObject) {

        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonPosition)
        
        if (indexPath?.row != sentences.count)
        {
            var theCDSentence:CDSentence
            
            if (self.resultSearchController.active) {
                theCDSentence = filterSentences[indexPath!.row]
            }else{
                theCDSentence = sentences[indexPath!.row]
            }
            
            theCDSentence.favormk = !theCDSentence.favormk.boolValue
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            if(theCDSentence.favormk.boolValue){
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! SentenceTableViewCell
                doFavorAnimation(cell)
            }
            
            if(favorButton.selected){
                queryData()
            }
        }

    }

    
    //MARK:觸控處理
    
    @IBAction func tapOnce(sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    @IBAction func doubleTap(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Ended){
            let point = sender.locationInView(tableView)
            
            let indexPath = tableView.indexPathForRowAtPoint(point)
        
            
            if (indexPath?.row != sentences.count)
            {
                var theCDSentence:CDSentence
                
                if (self.resultSearchController.active) {
                    theCDSentence = filterSentences[indexPath!.row]
                }else{
                    theCDSentence = sentences[indexPath!.row]
                }
                
                theCDSentence.favormk = true
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! SentenceTableViewCell
                doFavorAnimation(cell)
            }
         
        }
    }
    
    
    //MARK:點選成為最愛的處理
    //MARK:點選成為最愛後的動畫及音效播放
    func doFavorAnimation(cell:SentenceTableViewCell){
        playFavorAudio()
        cell.favorImageView.animateToNext({
            cell.favorImageView.animation = "zoomOut"
            cell.favorImageView.delay = 0.5
            cell.favorImageView.duration = 2
            cell.favorImageView.animateTo()
        })
    }
    
    
    //MARK:點選右上方我的最愛按鈕
    @IBAction func showMyFavorButton(sender: SpringButton) {
        
        if(favorButton.selected == false){
            playChangeAudio()
            dailySentencesButton.selected = false
            //動畫
            sender.selected = true
            sender.animation = "pop"
            sender.scaleX = 1.5
            sender.scaleY = 1.5
            //撈資料
            queryData()
        }else{
            playNoChangeAudio()
            sender.animation = "shake"
        }
        sender.animate()
    }

    //MARK:點選左上方每日佳句按鈕
    @IBAction func showDailySentencesButtonPressed(sender: SpringButton) {
        //動畫
        if(sender.selected == false){
            playChangeAudio()
            favorButton.selected = false
            sender.scaleX = 1.5
            sender.scaleY = 1.5
            sender.animation = "pop"
            sender.selected = true
            queryData()
        }else{
            playNoChangeAudio()
            sender.animation = "shake"
        }

        sender.animate()
    }
    
    
    
    //播放加入我的最愛的音樂
    func playFavorAudio(){
        let path = NSBundle.mainBundle().pathForResource("finger_snap", ofType:"mp3")
        let fileURL = NSURL(fileURLWithPath: path!)
        let item = AudioItem(mediumQualitySoundURL: fileURL!)
        player.playItem(item!)
    }

    func playChangeAudio(){
        let path = NSBundle.mainBundle().pathForResource("select01", ofType:"mp3")
        let fileURL = NSURL(fileURLWithPath: path!)
        let item = AudioItem(mediumQualitySoundURL: fileURL!)
        player.playItem(item!)
    }
    
    func playNoChangeAudio(){
        let path = NSBundle.mainBundle().pathForResource("blip2", ofType:"mp3")
        let fileURL = NSURL(fileURLWithPath: path!)
        let item = AudioItem(mediumQualitySoundURL: fileURL!)
        player.playItem(item!)
    }
    
    
    //MARK:SearchBar即時Filter處理
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filterSentences = [CDSentence]()
        for theSentence in sentences {
            if (theSentence.author.rangeOfString(searchString) != nil ||
                theSentence.en.rangeOfString(searchString) != nil ||
                theSentence.cn.rangeOfString(searchString) != nil ||
                theSentence.createat.rangeOfString(searchString) != nil
                ){
                    filterSentences.append(theSentence)
            }
        }
        
        tableView.reloadData()
    }

    
    
    
    //MARK:計算Cell String高度
    func returnStringSize(StringData str:String? ,MaxSize size:CGSize ,TextFont font:UIFont)->CGSize{
        var fontDic:NSDictionary = NSDictionary(object: font, forKey: NSFontAttributeName)
        return str!.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin , attributes: fontDic as [NSObject : AnyObject], context: nil).size
    }
    
}



