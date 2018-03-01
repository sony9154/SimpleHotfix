//
//  ViewController.swift
//  SimpleHotfix
//
//  Created by Peter Yo on 2月/23/18.
//  Copyright © 2018年 Peter Yo. All rights reserved.
//

import UIKit
import Alamofire
import SSZipArchive


/*
 https://dl.dropboxusercontent.com/s/sv78i6arbvwp0oj/FunctionZFJ1.framework.zip
 https://dl.dropboxusercontent.com/s/9lhxtghuyxetqek/FunctionZFJ1.framework.zip
 https://dl.dropboxusercontent.com/s/9njkurkne82xrt9/ZF.framework.zip?dl=0
 https://dl.dropboxusercontent.com/s/nbcaifzax6aebv0/02260531.framework.zip
 https://dl.dropboxusercontent.com/s/rlrzq30woxl9dg1/ThreeRingControl.framework.zip
 https://dl.dropboxusercontent.com/s/dnd45g16wgro6k0/ThreeRingControl.framework.zip
 https://dl.dropboxusercontent.com/s/95uf89unozx11ly/ThreeRingControl.framework%202.zip
 https://dl.dropboxusercontent.com/s/17905y1mluhjon7/ThreeRingControl.framework.zip
 https://dl.dropboxusercontent.com/s/ka091l8s1ixqfhk/ThreeRingControl.framework.zip
 https://dl.dropboxusercontent.com/s/ybasp6rnb1pg2s1/ThreeRingControl.framework.zip
 */

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let myUrl = URL(string: "https://dl.dropboxusercontent.com/s/ybasp6rnb1pg2s1/ThreeRingControl.framework.zip")
    //myUrl should be of type URL
    let myFileName = String((myUrl?.lastPathComponent)!) as NSString
    
    //path extension will consist of the type of file it is, m4a or mp4
    let pathExtension = myFileName.pathExtension
    
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
      var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      
      // the name of the file here I kept is yourFileName with appended extension
      documentsURL.appendPathComponent("peter."+pathExtension)
      return (documentsURL.absoluteURL, [.removePreviousFile])
    }
    
    var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDir = paths[0]
    let unZipPath =  documentsDir.appending("/UnZipFiles") // My folder name in document directory
    
    Alamofire.download("https://dl.dropboxusercontent.com/s/ybasp6rnb1pg2s1/ThreeRingControl.framework.zip", to: destination).response { response in
      if response.destinationURL != nil {
        print(response.destinationURL!)
        let savepath = response.destinationURL?.path
        SSZipArchive.unzipFile(atPath: savepath!, toDestination: unZipPath)
      }
    }
    
    
  }
  @IBAction func toFrameworkButton(_ sender: Any) {
    var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDir = paths[0]
    let unZipPath =  documentsDir.appending("/UnZipFiles")
    let bundlePath = unZipPath.appending("/ThreeRingControl.framework")
//    let bundle = Bundle(path: bundlePath)
//    let loadClass: AnyClass? = bundle?.classNamed("ZFJViewController")
    // 因為framework裡面的東西是OC寫的,所以物件設為NSObject, .Type是使用其類別
    let bundle = Bundle(path: bundlePath)
    let loadClass = bundle?.classNamed("_TtC16ThreeRingControl19PeterViewController") as? NSObject.Type
    if let vc = loadClass?.init() as? UIViewController {
        navigationController?.pushViewController(vc, animated: true)
    }
  }
  

}

