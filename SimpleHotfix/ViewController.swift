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
import SVProgressHUD

struct FrameworkPatch: Decodable {
  let version: Double
  let file: URL
  let created_datetime: String
  let vc_name: String
}


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
    
  }
  @IBAction func toFrameworkButton(_ sender: Any) {
    
    SVProgressHUD.showInfo(withStatus: "正在檢查更新")
    
    Alamofire.request(URL(string: "http://127.0.0.1:8000/api/framework_patch/latest/")!).responseData { (dataResponse) in
      switch dataResponse.result {
      case .success(let data):
        
        let decoder = JSONDecoder()
        
        guard let frameworkPatch = try? decoder.decode(FrameworkPatch.self, from: data) else {
          SVProgressHUD.showError(withStatus: "解析錯誤")
          return
        }
        
        SVProgressHUD.showInfo(withStatus: "發現版本號:\(frameworkPatch.version)")
        
        SVProgressHUD.dismiss(withDelay: 2, completion: {
          self.patchFramework(frameworkPatch)
        })
        
      case .failure(let err):
        SVProgressHUD.showError(withStatus: err.localizedDescription)
      }
    }
    
  }
  
  func patchFramework(_ patch: FrameworkPatch) {
    
    Alamofire.download(patch.file, to: { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
      
      let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      
      let destinationURL = docUrl.appendingPathComponent(patch.file.pathComponents.last!)
      
      return (destinationURL, [.removePreviousFile])
    }).downloadProgress { (progress) in
        SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "動態庫下載中...")
      
      }.response { (response) in
        
        guard let fileUrl = response.destinationURL, response.error == nil else {
          
          SVProgressHUD.showError(withStatus: response.error?.localizedDescription)
          return
        }
        
        SVProgressHUD.showProgress(1, status: "動態庫下載完成")
        
        SVProgressHUD.dismiss(withDelay: 1, completion: {
          let cs = patch.file.pathComponents
          
          guard let frameworkName = cs.last?.split(separator: ".").first else {return}
          
          self.unzipFramework(fileUrl: fileUrl, name: String.init(frameworkName), vc_name: patch.vc_name)
        })
        
    }
  }
  
  func unzipFramework(fileUrl: URL, name: String, vc_name: String) -> Void {
//    let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//
//    let destinationURL = docUrl.appendingPathComponent("peter.\(url.pathComponents.last ?? "framework")")
    
  
    var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDir = paths[0]
    let unZipPath =  documentsDir.appending("/UnZipFiles")
    
    SSZipArchive.unzipFile(atPath: fileUrl.path, toDestination: unZipPath, progressHandler: { (_, _, c, tc) in
      SVProgressHUD.showProgress(Float(c)/Float(tc), status: "解壓中")
    }) { (_, b, err) in
      
//      guard b, err != nil else {
//        SVProgressHUD.showError(withStatus: err?.localizedDescription)
//        return
//      }
      
      SVProgressHUD.dismiss()
      
      let frameworkPath = unZipPath.appending("/\(name).framework")
      
      print(frameworkPath)
      print(FileManager.default.fileExists(atPath: frameworkPath))
      
      guard let framework = Bundle(path: frameworkPath) else {
        return
      }
      
      self.openFramework(framework, vc_name: vc_name)
    }
    
  }
  
  func openFramework(_ bundle: Bundle, vc_name: String) -> Void {
//    _TtC16ThreeRingControl19PeterViewController
    let loadClass = bundle.classNamed(vc_name) as? NSObject.Type
    if let vc = loadClass?.init() as? UIViewController {
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  

}

