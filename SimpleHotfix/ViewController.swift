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

/* https://dl.dropboxusercontent.com/s/sv78i6arbvwp0oj/FunctionZFJ1.framework.zip */

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let myUrl = URL(string: "https://dl.dropboxusercontent.com/s/sv78i6arbvwp0oj/FunctionZFJ1.framework.zip")
    //myUrl should be of type URL
    let myFileName = String((myUrl?.lastPathComponent)!) as NSString
    
    //path extension will consist of the type of file it is, m4a or mp4
    let pathExtension = myFileName.pathExtension
    
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
      var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      
      // the name of the file here I kept is yourFileName with appended extension
      documentsURL.appendPathComponent("qta."+pathExtension)
      return (documentsURL.absoluteURL, [.removePreviousFile])
    }
    
    var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDir = paths[0]
    let unZipPath =  documentsDir.appending("/UnZipFiles") // My folder name in document directory
    
    Alamofire.download("https://dl.dropboxusercontent.com/s/sv78i6arbvwp0oj/FunctionZFJ1.framework.zip", to: destination).response { response in
      if response.destinationURL != nil {
        print(response.destinationURL!)
        let savepath = response.destinationURL?.path
        SSZipArchive.unzipFile(atPath: savepath!, toDestination: unZipPath)
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

