//
//  MediaUpload.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 17/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol MediaUploadProtocol {
    func mediaUploadWithStatus(status : Bool)
}

private var  mediaUploadInstance : MediaUpload? = nil

class MediaUpload: NSObject {
    
    var delegate : MediaUploadProtocol? = nil
    var uploadCompletionHandler: (Bool,[String:Bool]) -> Void = {_,_  in }
    var completionHandler: (Bool) -> Void = {_ in }
    var webRefNumber : String? = nil
    var imagePath : String? = nil
    var caseIDNumber : String? = nil
    var isMediaCount : Int = 0
    var uploadStatusLabel:UILabel?
    var progressView:UIProgressView?
    var compressionLevel: CGFloat = 0.0
    var mediUpload : [String] = [DirectoryName.kAudio,DirectoryName.kImage,DirectoryName.kVideo]
    var isMediaExists : [String:Bool] = [DirectoryName.kAudio : false,DirectoryName.kImage : false,DirectoryName.kVideo : false]
    var directories: [String] = [DirectoryName.kAudio,DirectoryName.kOriginalImages,DirectoryName.kVideo]
    var uploadingData = Data()
    
    static var  shareMediaUpload : MediaUpload
    {
        if mediaUploadInstance == nil
        {
            mediaUploadInstance = MediaUpload()
        }
        return mediaUploadInstance!
    }
        
    func uploadMediaWithWebRefNumberAndCaseID(caseID: String, webRefNumber : String, uploadStatusLabel : UILabel,progressView : UIProgressView, delegate : MediaUploadProtocol,completionHandler : @escaping  (Bool,[String:Bool])-> Void)
    {
        self.delegate = delegate
        self.uploadCompletionHandler = completionHandler
        self.webRefNumber = webRefNumber
        self.uploadStatusLabel = uploadStatusLabel
        self.progressView = progressView
        self.caseIDNumber = caseID
        
        // update compression level here
        if UserManager.sharedManager.isHighLevelCompression {
            compressionLevel = 0.050
        }else if UserManager.sharedManager.isMediumLevelCompression {
            compressionLevel = 0.030
        }else {
            compressionLevel = 0.015
        }
        
        let compressStatus = DocumentDirectory.shareDocumentDirectory.compressImagesWithWebRefNumberAndCompressionLevel(webRefNumber: webRefNumber,compressionLevel: compressionLevel)
        if compressStatus
        {
            let zipStatus = DocumentDirectory.shareDocumentDirectory.zipWithCaseIDAndWebRefNumber(caseNumber: caseID, webRefNumber: webRefNumber)
            
            if zipStatus
            {
                let mediaUpload = DocumentDirectory.shareDocumentDirectory.getUploadingFolderForCaseNumber(caseNumber: caseID,webRefNumber:webRefNumber)
                
                if mediaUpload.count > 0 {
                    //FTP Integration
                    createFTPDirectoryWithWebRefNumber(webRefNumber: caseID, status: {(sucess) -> Void in
                        
                        if sucess
                        {
                            let pathStatus = DocumentDirectory.shareDocumentDirectory.returnZipPathWithCaseIDNumber(caseNumber: caseID,webRefNumber: webRefNumber)
                            
                            if pathStatus.count > 0 {
                                self.isMediaExists[caseID] = true
                                DispatchQueue.main.async {
                                    self.uploadStatusLabel?.text = "Uploading \(caseID) (40)%)"
                                    self.progressView?.progress = 0.4
                                }
                                
                                let queueDetails = ["investigatorCode":UserManager.sharedManager.investigatorCode! as AnyObject as AnyObject,"webReferenceNumber":webRefNumber as AnyObject,"isMediaUploading":true,"uploadLabelValue":"Uploading \(caseID) (40)%)","progressValue":40] as [String : AnyObject]
                                
                                if DataModel.share.updateUploadQueueDetails(queueDetails) {
                                    print("updated queue")
                                }
//                                DispatchQueue.global(qos: .userInitiated).async {
                                    self.uploadMediaWithPath(path: pathStatus)
//                                }
                            }
                            
                        }
                    })
                }else {
//                    self.uploadCompletionHandler(true,isMediaExists)  // vivek
                    
                    self.delegate?.mediaUploadWithStatus(status: true)

                }
            }
        }else {
            self.delegate?.mediaUploadWithStatus(status: true)

        }
        //Compressing Images
    }
    
    func uploadMediaWithPath(path : String)
    {
        print(path)
        FTPHelper.sharedInstance().delegate = self
        FTPHelper.sharedInstance().uname = Configuration.sharedConfiguration.getFTPUname()
        FTPHelper.sharedInstance().pword = Configuration.sharedConfiguration.getFTPPword()
        print(URL(fileURLWithPath: path))
        uploadingData = try! Data(contentsOf: URL(fileURLWithPath: path))
        print("total bytes to upload -----> \(uploadingData)")
        
        FTPHelper.sharedInstance().urlString = "\(Configuration.sharedConfiguration.getFTPUrlString())/"
        
//        FTPHelper.upload(path)
        FTPHelper.upload(path, uploadBytes: Int64(uploadingData.count))
    }
    
    func createFTPDirPathsWithWebRefNumber(webRefNumber : String)-> [String]
    {
//        let version = DataModel.share.getVersionForWebRefNumber(phoneRefNumber!)
        let version = 1.0

        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "dd_MM_yyyy"
        let dateString = formater.string(from: date)
        let content : [String] = version > 0 ? [dateString,"\(webRefNumber)_\(version)"] : [dateString,webRefNumber]
        return content
    }
 
    func createFTPDirectoryWithWebRefNumber(webRefNumber : String , status : @escaping(Bool)-> ())
    {
        let path = "\(Configuration.sharedConfiguration.getFTPDirPath())\(webRefNumber)"
        print("ftp dir path --------------------> \(path)")
        createDirectory(path: path, completionHandler: { (isStatus)-> Void in
                status(true)
        })
    }
 
    func createDirectory(path : String, completionHandler : @escaping(Bool)-> Void)
    {
        if path.count <= 0
        {
            return
        }
        let createDir = CreateDirController.sharedCreateDirController() as!
        CreateDirController
        createDir.createDirectory(path, completionHandler: { (status) -> Void in
            completionHandler(status)
        })
    }
    
    func downloadMediWithWebRefNumber(phoneRefNumber: String, webRefNumber : String, imagePath : String,delegate :  MediaUploadProtocol,completionHandler : @escaping (Bool)-> Void )
    {
        DocumentDirectory.shareDocumentDirectory.createDirectoryWithWebRefNumber(webRefNumber: phoneRefNumber)
        self.delegate = delegate
        self.completionHandler = completionHandler
        self.webRefNumber = webRefNumber
        self.imagePath = imagePath
        mediUpload = [DirectoryName.kAudio,DirectoryName.kImage,DirectoryName.kVideo]
        //let paths = createFTPDownloadDirPathsWithWebRefNumber(webRefNumber: self.webRefNumber!)
//        let pathStatus = "\(imagePath)/hitpa_investigator_\(self.mediUpload[0]).zip"
        let pathStatus = "\(imagePath)/investigator_\(self.mediUpload[0]).zip"
        downloadMediaWithPath(path: pathStatus)
    }
    
    func downloadMediaWithPath(path : String)
    {
        FTPHelper.sharedInstance().delegate = self
        FTPHelper.sharedInstance().uname = Configuration.sharedConfiguration.getFTPUname()
        FTPHelper.sharedInstance().pword = Configuration.sharedConfiguration.getFTPPword()
        //let paths = createFTPDownloadDirPathsWithWebRefNumber(webRefNumber: self.webRefNumber!)
        FTPHelper.sharedInstance().urlString = "\(Configuration.sharedConfiguration.getFTPUrlString())"
        FTPHelper.download(path, destinationPath: getDestinationPath())
    }
 
    func getDestinationPath() -> String {
        let path = "\(webRefNumber!)/\(self.directories[self.isMediaCount])"
        
        let destinationPath = DocumentDirectory.shareDocumentDirectory.directoryPath().appendingPathComponent(path)?.path
        return destinationPath!
    }

}

extension MediaUpload : FTPHelperDelegate
{
    @objc func nextMediUpload()
    {
        if self.isMediaCount + 1 < self.mediUpload.count
        {
            self.isMediaCount += 1
            let pathStatus = DocumentDirectory.shareDocumentDirectory.returnZipPathWithPhoneRefNumber(phoneRefNumber: self.webRefNumber!, folderName:self.mediUpload[self.isMediaCount])
            if pathStatus.count > 0
            {
                self.isMediaExists[self.mediUpload[self.isMediaCount]] = true
                DispatchQueue.main.async {
                    self.uploadStatusLabel?.text = "Uploading \(self.mediUpload[self.isMediaCount]) (\((20 * (self.isMediaCount + 1)) + 20)%)"
                    self.progressView?.progress = (self.progressView?.progress)! + 0.2
                }
//                let queueDetails = ["investigatorCode":UserManager.sharedManager.investigatorCode!,"webReferenceNumber":self.phoneRefNumber!,"isMediaUploading":true,"uploadLabelValue":(uploadStatusLabel?.text)!,"progressValue":(20 * (self.isMediaCount + 1)) + 20] as [String : AnyObject]
//                if DataModel.share.updateUploadQueueDetails(queueDetails) {
//                    print("updated queue")
//                }
                uploadingData = try! Data(contentsOf: URL(fileURLWithPath: pathStatus))
                print(uploadingData)
                
//                FTPHelper.upload(pathStatus)
                
                FTPHelper.upload(pathStatus, uploadBytes: Int64(uploadingData.count))

            }else
            {
//                self.uploadCompletionHandler(true,isMediaExists) // vivek
                
                self.delegate?.mediaUploadWithStatus(status: true)
                
            }
            
        }else
        {
            DispatchQueue.main.async {
                self.uploadStatusLabel?.text = "Uploaded Successfully!!"
                self.progressView?.progress = 1.0
            }
//            self.uploadCompletionHandler(true,isMediaExists)  // vivek
            
            self.delegate?.mediaUploadWithStatus(status: true)

            self.isMediaCount  = 0
        }
    }
    
    func dataUploadFinished(_ bytes: NSNumber!) {
        if uploadingData.count == Int(truncating: bytes!) {
            nextMediUpload()
        }else {
            print("data upload failed")
//            self.uploadCompletionHandler(false,isMediaExists)   // vivek
            
            self.delegate?.mediaUploadWithStatus(status: false)
        }
    }
    
    func dataUploadFailed(_ reason: String!) {
        print("data upload failed")
//        self.uploadCompletionHandler(false,isMediaExists)  //vivek
        
        self.delegate?.mediaUploadWithStatus(status: false)

    }
    
    func downloadFinished() {
        
        print("finished")
        unZip(zipFolder: self.mediUpload[self.isMediaCount])
        if self.isMediaCount + 1 < self.mediUpload.count
        {
            self.isMediaCount += 1
            //let pathStatus = "\(imagePath!)/hitpa_investigator_\(self.mediUpload[self.isMediaCount]).zip"
            let pathStatus = "\(imagePath!)/investigator_\(self.mediUpload[self.isMediaCount]).zip"
            if pathStatus.count > 0
            {
                FTPHelper.download(pathStatus, destinationPath: getDestinationPath())
            }else
            {
                self.completionHandler(true)
            }
        }else
        {
            self.completionHandler(true)
            self.isMediaCount  = 0
        }
    }
    func dataDownloadFailed(_ reason: String!) {
        print("failed")
        if self.isMediaCount + 1 < self.mediUpload.count
        {
            self.isMediaCount += 1
            //let pathStatus = "\(imagePath!)/hitpa_investigator_\(self.mediUpload[self.isMediaCount]).zip"
            let pathStatus = "\(imagePath!)/investigator_\(self.mediUpload[self.isMediaCount]).zip"
            if pathStatus.count > 0
            {
                FTPHelper.download(pathStatus, destinationPath: getDestinationPath())
            }else
            {
                self.completionHandler(true)
            }
        }else
        {
            self.completionHandler(true)
            self.isMediaCount  = 0
        }
    }
    
    func unZip(zipFolder:String) {
        //let path = "\(getDestinationPath())/hitpa_investigator_\(zipFolder).zip"
        let path = "\(getDestinationPath())/investigator_\(zipFolder).zip"
        let destinationPath = "\(getDestinationPath())"
        let zipArchive = ZipArchive()
        if zipArchive.unzipOpenFile(path) {
            if zipArchive.unzipFile(to: destinationPath, overWrite: true) {
                print("SUCCESS")
                zipArchive.unzipCloseFile()
            }
        }else {
            print("Failed")
        }
    }

}
 
