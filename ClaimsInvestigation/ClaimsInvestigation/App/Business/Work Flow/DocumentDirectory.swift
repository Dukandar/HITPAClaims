//
//  DocumentDirectory.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 13/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

struct DirectoryName {
    static let kOriginalImages     : String  = "OriginalImages"
    static let kImage              : String  = "images"
    static let kVideo              : String  = "Videos"
    static let kAudio              : String  = "Audio"
}

private var instanceDocumentDirectory : DocumentDirectory? = nil

class DocumentDirectory: NSObject {
    
    static var shareDocumentDirectory: DocumentDirectory {
        
        if instanceDocumentDirectory == nil {
            instanceDocumentDirectory = DocumentDirectory()
        }
        return instanceDocumentDirectory!
    }
    
    func directoryPath() -> NSURL {
        return NSURL.init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
    }
    
    func createDirectoryWithRefNumber(refNumber: String) {
        let fileManager = FileManager()
        let directoryName = "\(refNumber)"
        let directoryPath = self.directoryPath().appendingPathComponent(directoryName)
        let stringPath = directoryPath?.absoluteString
        let url = URL(string: stringPath!)
        do {
            
            if fileManager.fileExists(atPath: (url?.path)!)
            {
            } else{
                try FileManager.default.createDirectory(atPath: directoryPath!.path, withIntermediateDirectories: true, attributes: nil)
            }
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    func createDirectoryWithWebRefNumber(webRefNumber : String)
    {
        let fileManager = FileManager()
        let directoryNames : [String] = [DirectoryName.kOriginalImages,DirectoryName.kVideo,DirectoryName.kAudio]
        for item in 0..<directoryNames.count
        {
            let directoryName = "\(webRefNumber)/\(directoryNames[item])"
            let directoryPath = self.directoryPath().appendingPathComponent(directoryName)
            let stringPath = directoryPath?.absoluteString
            let url = URL(string: stringPath!)
            do {
                
                if fileManager.fileExists(atPath: (url?.path)!)
                {
                }else
                {
                    try FileManager.default.createDirectory(atPath: directoryPath!.path, withIntermediateDirectories: true, attributes: nil)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
  
    
    func deleteDirectoryWithWebReferenceNumber(webRefNumber: String) {
        let fileManager = FileManager()
        let directoryPath = self.directoryPath().appendingPathComponent("\(webRefNumber)")
        let stringPath = directoryPath?.absoluteString
        let url = URL.init(string: stringPath!)
        print((url?.path)!)

        if fileManager.fileExists(atPath: (url?.path)!) {

            do {
                if (fileManager.isDeletableFile(atPath: (url?.path)!)){
                    try fileManager.removeItem(atPath: (url?.path)!)
                }
                else{
                    print("its not deletable")
                }
            }catch let error {
                print("file-delete-error:\n\(error) for path \((url?.path)!)")
            }
        }
        
    }
    
    func writePotraitImageIntoDirectory(name: String,image: UIImage,webRefNumber: String) -> Bool {
        
        let portraitImage = UIImage.init(cgImage: image.cgImage! , scale: 1.0,orientation: UIImageOrientation.right)
        let imageName = "\(webRefNumber)/\(DirectoryName.kOriginalImages)/\(name).jpg"
        let fileURL = directoryPath().appendingPathComponent(imageName)
        do {
            try UIImagePNGRepresentation(portraitImage)!.write(to: fileURL!)
            return true
        } catch {
            return false
        }
    }
    
    //MARK: -
    func writeImageIntoDirectory(imageTag : String,image : UIImage,webRefNumber : String) -> Bool
    {
        if createOriginalImageDirectoryWithWebRefNumber(webRefNumber: webRefNumber) {
            
            let imageName = "\(webRefNumber)/\(DirectoryName.kOriginalImages)/\(imageTag).jpg"

            let fileURL = directoryPath().appendingPathComponent(imageName)
            
            do {
                try UIImageJPEGRepresentation(image, 0.015)!.write(to: fileURL!)
//                print("Image Added Successfully at -> \(fileURL!)")
                return true
            } catch {
                print(error)
                return false
            }
        }else {
            return false
        }

    }
    
    func getImageWithImageTag(imageTag : String,webRefNumber : String)-> UIImage?
    {
        let imageName = "\(webRefNumber)/\(DirectoryName.kOriginalImages)/\(imageTag).jpg"
        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            let image = UIImage(contentsOfFile: (fileURL?.path)!)
            //let potraitImage = UIImage(cgImage: (image?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.right)
            return image!
        }
        return nil
    }
    
    func getOriginalImageWithName(name : String,webRefNumber : String)-> UIImage
    {
        let imageName = "\(webRefNumber)/\(DirectoryName.kOriginalImages)/\(name)"
        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            let image = UIImage(contentsOfFile: (fileURL?.path)!)
            return image!
        }
        return UIImage()
    }
    
    func deleteImageFromDirectory(name : String,webRefNumber : String)-> Bool
    {
        let imageName = "\(webRefNumber)/\(DirectoryName.kOriginalImages)/\(name)"
        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            do
            {
                try fileManager.removeItem(atPath: (fileURL?.path)!)
//                print("image removed at -> \((fileURL?.path)!)")
                return true
            }catch
            {
                print("error")
                return false
            }
        }
        return false
    }
    
    
    //MARK: -
    func writePDFIntoDirectory(data : Data,referenceNumber : String) -> Bool
    {
        createDirectoryWithRefNumber(refNumber: referenceNumber)
        let fileName = "\(referenceNumber)/\(referenceNumber).pdf"
        let fileURL = directoryPath().appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL!)
            
            return true
        } catch {
            return false
        }
    }
    
    
    func getPdfWithReferenceNumber(referenceNumber : String)-> Data
    {
        let data = Data()
        let fileName = "\(referenceNumber)/\(referenceNumber).pdf"
        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            return try! Data(contentsOf: fileURL!)
        }
        return data
    }
    
    func isPDFExistWith(claimNo : String)-> Bool{
        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(claimNo)
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            return true
        }
        return false
    }
    
    //MARK: -
    func deleteVideoFromDirectory(name : String,webRefNumber : String)-> Bool
    {
        let videoName = "\(name)"

        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(videoName)
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            do
            {
                try fileManager.removeItem(atPath: (fileURL?.path)!)
                return true
            }catch
            {
                return false
            }
        }
        return false
    }
    
    func getVideoThumbImageWithName(name : String, webRefNumber: String)-> UIImage
    {
        let videoName = "\(name).m4v"

        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(videoName)
        if fileManager.fileExists(atPath: (fileURL!.path))
        {
            let image = Utility.sharedUtility.getThumbImageFromVideoWithURL(url: fileURL!)
            return image
        }
        return UIImage()
    }
    
    //MARK:-
    
    func writeDataBaseInDirectory()
    {
        let fileManager = FileManager()
        
        let path: String = Bundle.main.path(forResource: "HITPA", ofType: "sqlite")!
        let fileURL = URL(fileURLWithPath: (directoryPath().appendingPathComponent("HITPA.sqlite")?.path)!)
        do
        {
            try fileManager.copyItem(at:URL(fileURLWithPath: path), to: fileURL)
            
        }catch let error as NSError{
            print(error)
        }
        
    }
    
    func isCheckDataBase()-> Bool
    {
        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent("HITPA.sqlite")
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            return true
        }
        return false
    }
    
    func compressImage(inputImage : UIImage) -> UIImage
    {
        let imageData = UIImageJPEGRepresentation(inputImage, 0.4)!
        let image = UIImage(data: imageData)
        return image!
    }
    
    func fileExistWithWebRefNumber(refNumber : String,fileName : String)-> Bool
    {
        let fileManager = FileManager()
        let directoryName = "\(refNumber)/\(fileName)"
        let directoryPath = self.directoryPath().appendingPathComponent(directoryName)
        let stringPath = directoryPath?.absoluteString
        let url = URL(string: stringPath!)
        if fileManager.fileExists(atPath: (url?.path)!)
        {
            return true
        }else
        {
            return false
        }
    }
    
    
    func createImageDirectoryWithWebRefNumber(webRefNumber : String)-> Bool
    {
        let fileManager = FileManager()
        let directoryName = "\(webRefNumber)/\(DirectoryName.kImage)"
        let directoryPath = self.directoryPath().appendingPathComponent(directoryName)
        let stringPath = directoryPath?.absoluteString
        let url = URL(string: stringPath!)
        do {
            if fileManager.fileExists(atPath: (url?.path)!)
            {
            }else
            {
                try FileManager.default.createDirectory(atPath: directoryPath!.path, withIntermediateDirectories: true, attributes: nil)
                return true
            }
        } catch let error as NSError {
            print(error)
            return false
        }
        return true
    }
    
    func createOriginalImageDirectoryWithWebRefNumber(webRefNumber : String)-> Bool
    {
        let fileManager = FileManager()
        let directoryName = "\(webRefNumber)/\(DirectoryName.kOriginalImages)"
        let directoryPath = self.directoryPath().appendingPathComponent(directoryName)
        let stringPath = directoryPath?.absoluteString
        let url = URL(string: stringPath!)
        do {
            if fileManager.fileExists(atPath: (url?.path)!)
            {
            }else
            {
                try FileManager.default.createDirectory(atPath: directoryPath!.path, withIntermediateDirectories: true, attributes: nil)
                return true
            }
        } catch let error as NSError {
            print(error)
            return false
        }
        return true
    }
    
    func deleteAudioFromDirectory(name : String,webRefNumber : String)-> Bool
    {
        let audioName = "\(name)"
        let fileManager = FileManager()
        let fileURL = directoryPath().appendingPathComponent(audioName)
        if fileManager.fileExists(atPath: (fileURL?.path)!)
        {
            do
            {
                try fileManager.removeItem(atPath: (fileURL?.path)!)
                return true
            }catch
            {
                return false
            }
        }
        return false
    }
    
    
    func compressImagesWithWebRefNumberAndCompressionLevel(webRefNumber: String,compressionLevel: CGFloat = 0.015)-> Bool
    {
        let sucess = createImageDirectoryWithWebRefNumber(webRefNumber: webRefNumber)
        if sucess
        {
            let fileManager = FileManager()
            let fileURL = directoryPath().appendingPathComponent("\(webRefNumber)/\(DirectoryName.kOriginalImages)")
            
            if fileManager.fileExists(atPath: (fileURL?.path)!)
            {
                let subPaths = fileManager.subpaths(atPath: (fileURL?.path)!)
                for path in subPaths!
                {
                    do
                    {
                        let imageUrl = directoryPath().appendingPathComponent("\(webRefNumber)/\(DirectoryName.kOriginalImages)/\(path)")
                        let urlPath = directoryPath().appendingPathComponent("\(webRefNumber)/\(DirectoryName.kImage)/\(path)")
                        let image = UIImage.init(contentsOfFile: (imageUrl?.path)!)
                        if image != nil {
                            _ = self.compressImage(inputImage: image!)
//                            try UIImageJPEGRepresentation(image!,0.015)?.write(to: urlPath!)
                            try UIImageJPEGRepresentation(image!, compressionLevel)?.write(to: urlPath!)
                            
                        }
                        
                    }catch let error as NSError
                    {
                        print(error)
                        return false
                    }
                }
                return true
            }
        }
        return false
    }
    

    func createRefernceFolder()-> Int64
    {
        //Convert Current DateAndTime With Millisecound
        let dateString = Utility.sharedUtility.getDateTimeStringFromDate(Date())
        let milliSecound = Utility.sharedUtility.getMilliSecondWithDateString(dateString: dateString)
        if createImageDirectoryWithWebRefNumber(webRefNumber: String(milliSecound))
        {
            return Int64(milliSecound)
        }
        return 0
    }
    
    
    func removeZipFileWithPath( path : String)-> Bool
    {
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: path)
        {
            do
            {
                try fileManager.removeItem(atPath: path)
                return true
            }catch
            {
                return false
            }
        }
        return true
    }
    
    func zipWithWebRefNumber(webRefNumber : String) -> Bool
    {
        let fileManager = FileManager()
        let zipContent : [String] = [DirectoryName.kImage,DirectoryName.kAudio,DirectoryName.kVideo]
        
        for item in zipContent
        {
            let fileURL = directoryPath().appendingPathComponent("\(webRefNumber)/\(item)")
            //let zipPath = directoryPath().appendingPathComponent("\(webRefNumber)/hitpa_investigator_\(item).zip")
            let zipPath = directoryPath().appendingPathComponent("\(webRefNumber)/investigator_\(item).zip")
            let sucess = removeZipFileWithPath(path: (zipPath?.path)!)
            if sucess
            {
                if fileManager.fileExists(atPath: fileURL!.path)
                {
                    
                    let subPaths = fileManager.subpaths(atPath: fileURL!.path)
                    let zipArchive = ZipArchive()
                    zipArchive.createZipFile2(zipPath!.path)
                    for path in subPaths!
                    {
                        let imageUrl = directoryPath().appendingPathComponent("\(webRefNumber)/\(item)/\(path)")
                        zipArchive.addFile(toZip: imageUrl?.path, newname: path)
                    }
                    let successCompressing = zipArchive.closeZipFile2()
                    if successCompressing
                    {

                    }else
                    {
                        return false
                    }
                    
                }
            }
            
        }
        return true
    }
    
    func returnZipPathWithPhoneRefNumber(phoneRefNumber : String,folderName : String)-> String
    {
        let fileManager = FileManager()
//        let directoryName = "\(phoneRefNumber)/hitpa_investigator_\(folderName).zip"
        let directoryName = "\(phoneRefNumber)/investigator_\(folderName).zip"
        let directoryPath = self.directoryPath().appendingPathComponent(directoryName)
        let stringPath = directoryPath?.absoluteString
        let url = URL(string: stringPath!)
        do {
            
            if fileManager.fileExists(atPath: (url?.path)!)
            {
                return  (url?.path)!
                
            }else
            {
                return ""
            }
        }
    }
    
    func getUploadingFolders(phoneRefNumber : String) -> [String] {
        
        var mediaUpload : [String] = []
        let media : [String] = [DirectoryName.kAudio,DirectoryName.kImage,DirectoryName.kVideo]
        for obj in media {
            let pathStatus = DocumentDirectory.shareDocumentDirectory.returnZipPathWithPhoneRefNumber(phoneRefNumber: phoneRefNumber, folderName:obj)
            if pathStatus.count > 0 {
                do {
                    let dataLength = try Data.init(contentsOf: URL.init(fileURLWithPath: pathStatus)).count
                    if dataLength > 22 {
                        mediaUpload.append(obj)
                    }
                }catch {
                    
                }
            }
        }
        return mediaUpload
    }
    
    
    func zipWithCaseIDAndWebRefNumber(caseNumber: String,webRefNumber:String) -> Bool
    {
        let fileManager = FileManager()
        
        var mediaArray: [AnyObject]?
        
        let caseData = DataModel.share.getCaseDetailsForCaseID(webRefNumber: UserManager.sharedManager.investigatorCode!, caseID: Int64(caseNumber)!)
        
        if caseData.count > 0 {
            
            //let zipPathCase = directoryPath().appendingPathComponent("\(webRefNumber)/hitpa_\(caseNumber).zip")
            let zipPathCase = directoryPath().appendingPathComponent("\(webRefNumber)/\(caseNumber).zip")

            let successCase = removeZipFileWithPath(path: (zipPathCase?.path)!)

            let zipArchiveCase = ZipArchive()
            zipArchiveCase.createZipFile2(zipPathCase!.path)
            
            for (_,item) in (caseData as! [CaseDetail]).enumerated() {
                
                let fieldID = item.fieldID as AnyObject
                
                if item.fieldType == DataType.kMediaControl {
                    
                    mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID as! Int, webRefNumber: webRefNumber)
                    
                    // collect all media files here
                    
                    if (mediaArray?.count)! > 0  && (item.mappingLabel != nil) {
                        
                        // create mapping label named zip folder and add media files in that folder.
                        
//                        let zipPath = directoryPath().appendingPathComponent("\(webRefNumber)/hitpa_\(item.mappingLabel!).zip")
                        let zipPath = directoryPath().appendingPathComponent("\(webRefNumber)/\(item.mappingLabel!).zip")
                        
                        let success = removeZipFileWithPath(path: (zipPath?.path)!)
                        
                        let zipArchive = ZipArchive()
                        zipArchive.createZipFile2(zipPath!.path)
                        
                        for (_,mediaItem) in (mediaArray as! [MediaInfo]).enumerated() {
                            
                            switch (mediaItem.mediaType)  {
                            case MediaControlType.kAudioControl :
                                
                                let fileURL = directoryPath()
                                
                                if success
                                {
                                    if fileManager.fileExists(atPath: fileURL.path!)
                                    {
                                        let subPaths = fileManager.subpaths(atPath: fileURL.path!)
                                        
                                        // get files here from DD based on tag
                                        
                                        if (subPaths?.contains("\(mediaItem.tag!)"))! {
                                            
                                            let audioUrl = directoryPath().appendingPathComponent("\(mediaItem.tag!)")
                                            
                                            zipArchive.addFile(toZip: audioUrl?.path, newname: "\(item.mappingLabel!)/\(mediaItem.mediaName!)_\(mediaItem.mediaType!).caf")
                                        }
                                    }
                                }
                                break
                                
                            case MediaControlType.kImageControl :
                                
                                let fileURL = directoryPath().appendingPathComponent("\(webRefNumber)/\(DirectoryName.kImage)")
                                
                                if success
                                {
                                    if fileManager.fileExists(atPath: fileURL!.path)
                                    {
                                        let subPaths = fileManager.subpaths(atPath: fileURL!.path)
                                        
                                        // get files here from DD based on tag
                                        
                                        if (subPaths?.contains("\(mediaItem.tag!).jpg"))! {
                                            
                                            let imageUrl = directoryPath().appendingPathComponent("\(webRefNumber)/\(DirectoryName.kImage)/\(mediaItem.tag!).jpg")
                                            
                                            zipArchive.addFile(toZip: imageUrl?.path, newname: "\(item.mappingLabel!)/\(mediaItem.mediaName!)_\(mediaItem.mediaType!).jpg")
                                        }
                                    }
                                }
                                
                                break
                                
                            case MediaControlType.kVideoControl :
                                
                                let fileURL = directoryPath()
                                
                                if success
                                {
                                    if fileManager.fileExists(atPath: fileURL.path!)
                                    {
                                        let subPaths = fileManager.subpaths(atPath: fileURL.path!)
                                        
                                        // get files here from DD based on tag
                                        
                                        if (subPaths?.contains("\(mediaItem.tag!).m4v"))! {
                                            
                                            let videoUrl = directoryPath().appendingPathComponent("\(mediaItem.tag!).m4v")
                                            
                                            zipArchive.addFile(toZip: videoUrl?.path, newname: "\(item.mappingLabel!)/\(mediaItem.mediaName!)_\(mediaItem.mediaType!).m4v")
                                        }
                                    }
                                }
                                
                                break
                                
                            default :
                                break
                            }
                        }
                        
                        // after adding media, zip that folder before procedding to next item.

                        _ = zipArchive.closeZipFile2()
//                        print(successCompressing)
                        
                        
                        if successCase {
                            zipArchiveCase.addFile(toZip: zipPath!.path, newname: "\(caseNumber)/\(item.mappingLabel!).zip")
                        }
                        
                    }else {
                        
                    }
                }
            }
            
            let successCompressingCase = zipArchiveCase.closeZipFile2()
//            print(successCompressingCase)
            if successCompressingCase {
                return true
            }
            return false
        }else {
            return false
        }
    }
    
    func returnZipPathWithCaseIDNumber(caseNumber : String,webRefNumber:String)-> String
    {
        let fileManager = FileManager()
        
        //let directoryName = "\(webRefNumber)/hitpa_\(caseNumber).zip"
        let directoryName = "\(webRefNumber)/\(caseNumber).zip"
        
        let directoryPath = self.directoryPath().appendingPathComponent(directoryName)
        let stringPath = directoryPath?.absoluteString
        let url = URL(string: stringPath!)
        do {
            
            if fileManager.fileExists(atPath: (url?.path)!)
            {
                return  (url?.path)!
            }else
            {
                return ""
            }
        }
    }
    
    func getUploadingFolderForCaseNumber(caseNumber : String,webRefNumber:String) -> String {
        
        var mediaPath = ""
        
        let pathStatus = DocumentDirectory.shareDocumentDirectory.returnZipPathWithCaseIDNumber(caseNumber: caseNumber,webRefNumber:webRefNumber)
        if pathStatus.count > 0 {
            do {
                let dataLength = try Data.init(contentsOf: URL.init(fileURLWithPath: pathStatus)).count
                if dataLength > 22 {
                    mediaPath = pathStatus
                }else {
                    mediaPath = ""
                }
            }catch {
                mediaPath = ""
            }
        }
        return mediaPath
    }
    
    
    // remove uploaded case Media and zipped files/folder
    
    func removeCaseMedia(caseNumber : Int64 ,webRefNumber:String) {
        
        let fileManager = FileManager()
        
        var mediaArray: [AnyObject]?
        
        let caseData = DataModel.share.getCaseDetailsForCaseID(webRefNumber: UserManager.sharedManager.investigatorCode!, caseID: caseNumber)
        
        if caseData.count > 0 {
            
            for (_,item) in (caseData as! [CaseDetail]).enumerated() {
                
                let fieldID = item.fieldID as AnyObject
                
                if item.fieldType == DataType.kMediaControl {
                    
                    mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID as! Int, webRefNumber: webRefNumber)
                    
                    // collect all media files here
                    
                    if (mediaArray?.count)! > 0  && (item.mappingLabel != nil) {
                        
                        for (_,mediaItem) in (mediaArray as! [MediaInfo]).enumerated() {
                            
                            switch (mediaItem.mediaType)  {
                            case MediaControlType.kAudioControl :
                                
                                let fileURL = directoryPath()
                                
                                    if fileManager.fileExists(atPath: fileURL.path!)
                                    {
                                        let subPaths = fileManager.subpaths(atPath: fileURL.path!)
                                        
                                        // get files here from DD based on tag
                                        
                                        if (subPaths?.contains("\(mediaItem.tag!)"))! {
                                            
                                            let audioUrl = directoryPath().appendingPathComponent("\(mediaItem.tag!)")
                                            
                                            try? FileManager.default.removeItem(at: audioUrl!)
                                        }
                                }
                                break
                            
                            case MediaControlType.kVideoControl :
                                
                                let fileURL = directoryPath()
                                
                                    if fileManager.fileExists(atPath: fileURL.path!)
                                    {
                                        let subPaths = fileManager.subpaths(atPath: fileURL.path!)
                                        
                                        // get files here from DD based on tag
                                        
                                        if (subPaths?.contains("\(mediaItem.tag!).m4v"))! {
                                            
                                            let videoUrl = directoryPath().appendingPathComponent("\(mediaItem.tag!).m4v")
                                            
                                            try? FileManager.default.removeItem(at: videoUrl!)
                                        }
                                }
                                
                                break
                                
                            default :
                                break
                            }
                        }
                        
                    }
                }
            }
        }
    }
}
