//
//  CSVReader.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 06/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

private var instanceCSVReader: CSVReader? = nil

class CSVReader: NSObject {
    
    let sheetNames: [String] = ["fielddatamaster","fieldsectionmap","fldMaster","headerfieldsectionmap","sectionmaster","survey","tableFieldDependency"]

    static var sharedInstance: CSVReader {
        
        if(instanceCSVReader == nil) {
            instanceCSVReader = CSVReader()
        }
        return instanceCSVReader!
    }
    
    func csvReader(completionHandler: @escaping(Bool?) -> ()) {
        
        var sheets : [String: AnyObject] = [:]
        
        for (sheetIndex,sheetName) in sheetNames.enumerated() {
            
            
            print("sheetName -> \(sheetName)")
            _ = sheetIndex
            let path : String = Bundle.main.path(forResource: sheetName, ofType: "csv")!
            
            do {
                let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                
                let rows = string.components(separatedBy: "\n")
                
                var result : [[String]] = []
                
                for row in rows {
                    let columns = row.components(separatedBy: ",")
                    result.append(columns)
                }
                
                var fieldNames = result[0]
                var excelRows: [AnyObject] = []
                
                for (index,item) in result.enumerated() {
                    
                    if (index > 0) {
                        
                        var cell: [String: AnyObject] = [:]
                        
                        for (cellIndex,cellItem) in item.enumerated() {
                                                        
                            cell[fieldNames[cellIndex]] = cellItem as AnyObject
                        }
                        excelRows.append(cell as AnyObject)
                    }
                }
                sheets[sheetName] = excelRows as AnyObject
                
                
            }catch let error as NSError {
                print(error)
            }
            
        }
        
        if DataModel.share.insertCSVWithData(data: sheets) {
            completionHandler(true)
        }
        completionHandler(false)
    }

}
