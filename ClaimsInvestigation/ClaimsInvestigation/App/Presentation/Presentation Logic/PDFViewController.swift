//
//  PDFViewController.swift
//  ClaimsInvestigation
//
//  Created by Ishan Sunilkumar on 20/10/20.
//  Copyright © 2020 iNube Software Solutions. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class PDFViewController: UIViewController,MFMailComposeViewControllerDelegate {

    var webView: WKWebView!
    var pdfPath : String!
    var claimsNo : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: self.view.frame)
        self.title = "View Report"
        self.navigationController?.navigationBar.backgroundColor  = ColorConstant.kThemeColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_arrow_backward_white.png"), style: .plain, target: self, action:  #selector(popVCTR))
        //self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "ic_email_black_24dp.png"), style: .plain, target: self, action:  #selector(mail))
        self.setPDFData()
        // Do any additional setup after loading the view.
    }
    
    func setPDFData(){
        
        if DocumentDirectory.shareDocumentDirectory.isPDFExistWith(claimNo: "\(self.claimsNo!)/\( self.claimsNo!).pdf") {
            self.loadPDF()
        }else{
            HITPAAPI.sharedAPI.getAPIWith(path: self.pdfPath, completionHandler: {(data,error)-> Void in
               if (error == nil){
                   DispatchQueue.main.async {
                       if DocumentDirectory.shareDocumentDirectory.writePDFIntoDirectory(data: data!, referenceNumber: self.claimsNo){
                            self.loadPDF()
                       }
                   }
               }
           })
        }
        
    }
    
    func loadPDF() {
        let pdfPath = DocumentDirectory.shareDocumentDirectory.directoryPath().appendingPathComponent("\(self.claimsNo!)/\( self.claimsNo!).pdf")
        do {
              let data = try Data(contentsOf: pdfPath!)
            if #available(iOS 9.0, *) {
                self.webView.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: pdfPath!.deletingLastPathComponent())
            } else {
                // Fallback on earlier versions
                let request = URLRequest.init(url: pdfPath!, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:60)
                self.webView.load(request)
                
            }
                 print("pdf file loading...")
           }
        catch {
                 print("failed to open pdf")
           }
    }
    
    //MARK:- IBAction
    @objc func popVCTR(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func mail(){
        let mailComposeViewController = configureMailComposer()
           if MFMailComposeViewController.canSendMail(){
               self.present(mailComposeViewController, animated: true, completion: nil)
           }else{
               print("Can't send email")
           }
    }

    func configureMailComposer() -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([""])
        mailComposeVC.setSubject("")
        mailComposeVC.setMessageBody("", isHTML: true)
        let pdfPath = DocumentDirectory.shareDocumentDirectory.directoryPath().appendingPathComponent("\(self.claimsNo!)/\( self.claimsNo!).pdf")
        do {
                 let data = try Data(contentsOf: pdfPath!)
                 mailComposeVC.addAttachmentData(data, mimeType: "application/pdf", fileName: "")
           }
        catch {}
        return mailComposeVC
    }
    
    
    //MARK: - MFMail compose method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
