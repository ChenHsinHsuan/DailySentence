//
//  WebData.swift
//  ASentenceOfADay
//
//  Created by Chen Hsin Hsuan on 2015/5/9.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import Foundation



func callData(){
    let url:NSURL? = NSURL(string:"http://www.managertoday.com.tw/quotes/")
    
    let htmlString:String? = String(contentsOfURL:url!, encoding: NSUTF8StringEncoding, error: nil)
    
    let htmlData:NSData? = htmlString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    
    let htmlDOM:NSArray = TFHpple(HTMLData: htmlData).searchWithXPathQuery("//div[@class='quote-mainBlock']")
    
    let targetDOM:TFHppleElement = htmlDOM.objectAtIndex(0) as! TFHppleElement
    
    
    id = ((targetDOM.searchWithXPathQuery("//blockquote/a") as NSArray).objectAtIndex(0) as! TFHppleElement).objectForKey("href")
    
//    println("id:\(id)")
    //圖片網址
    imageURL = ((targetDOM.searchWithXPathQuery("//div[@class='quote-imgBorder']/img") as NSArray).objectAtIndex(0) as! TFHppleElement).objectForKey("src")
    
//    println("imageURL:\(imageURL)")
    //作者名稱
    
    let authorArray = targetDOM.searchWithXPathQuery("//ul[@class='caption-list']/li") as NSArray
    for authorDOM in authorArray {
        author += (authorDOM as! TFHppleElement).content+"\n"
    }
//    println("author:\(author)")
    
    //英文句子
    
    let enSentenceDOM = targetDOM.searchWithXPathQuery("//p[@class='sentence-eng']") as NSArray
    
    
    if enSentenceDOM.count > 0 {
        enSentence = enSentenceDOM.objectAtIndex(0).content
//        println("enSentence:\(enSentence)")
    }
    
    
    //中文句子
    let cnSentenceDOM = targetDOM.searchWithXPathQuery("//p[@class='sentence-zh_tw']") as NSArray
    if cnSentenceDOM.count > 0 {
        cnSentence = cnSentenceDOM.objectAtIndex(0).content
//        println("cnSentence:\(cnSentence)")
    }
}


func getDate() -> String{
    var todaysDate:NSDate = NSDate()
    var dateFormatter:NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    return dateFormatter.stringFromDate(todaysDate)
}

