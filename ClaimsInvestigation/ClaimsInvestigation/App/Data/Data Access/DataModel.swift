//
//  DataModel.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 31/07/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import CoreData

private var dataModelInstance: DataModel? = nil

class DataModel: NSObject {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    static var share: DataModel {
        
        if dataModelInstance == nil {
            dataModelInstance = DataModel()
        }
        return dataModelInstance!
    }
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        }
        return value
    }
    
    override init() {
        
        guard let managedObject = Bundle.main.url(forResource: "HITPA", withExtension: "momd") else {
            fatalError("Unable to access the mod file.")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: managedObject) else {
            fatalError("Unable to access the object model.")
        }
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let storeURL = url?.appendingPathComponent("HITPA.sqlite")
        
        print(storeURL!)
        
        let persistantStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: model)
        
        do {
            try persistantStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption: true,NSInferMappingModelAutomaticallyOption:true])
        } catch let error as NSError {
            print(error)
        }
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = persistantStoreCoordinator
    }
    
    func insertCSVWithData(data: [String:AnyObject]) -> Bool {
        
        print("SectionMaster")
        
        var sectionMaster = data["sectionmaster"] as? [[String:Any]]
        sectionMaster?.removeLast()
        
        for (_,item) in (sectionMaster?.enumerated())! {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "SectionMaster", into: self.managedObjectContext!)
            
            insertData.setValue((self.nullToNil(value: item["secId"] as AnyObject)) != nil ? (Int(item["secId"] as! String)) : 0, forKey: "secId")
            
            insertData.setValue((self.nullToNil(value: item["secissub"] as AnyObject)) != nil ? (Int(item["secissub"] as! String)) : 0, forKey: "secissub")

            insertData.setValue((self.nullToNil(value: item["secFormid"] as AnyObject)) != nil ? (Int(item["secFormid"] as! String)) : 0, forKey: "secFormid")
            
            insertData.setValue((self.nullToNil(value: item["secdecl"] as AnyObject)) != nil ? (Int(item["secdecl"] as! String)) : 0, forKey: "secdecl")
            
            insertData.setValue((self.nullToNil(value: item["secCaseType"] as AnyObject)) != nil ? (Int(item["secCaseType"] as! String)) : 0, forKey: "secCaseType")

            insertData.setValue((self.nullToNil(value: item["secsort"] as AnyObject)) != nil ? (Int(item["secsort"] as! String)) : 0, forKey: "secsort")

            insertData.setValue((self.nullToNil(value: item["sechead"] as AnyObject)) != nil ? (item["sechead"] as! String) : "", forKey: "sechead")

            insertData.setValue((self.nullToNil(value: item["secLastUpdatedBy"] as AnyObject)) != nil ? (item["secLastUpdatedBy"] as! String) : "", forKey: "secLastUpdatedBy")

            insertData.setValue((self.nullToNil(value: item["secLastUpdatedOn"] as AnyObject)) != nil ? (item["secLastUpdatedOn"] as! String) : "", forKey: "secLastUpdatedOn")

            insertData.setValue((self.nullToNil(value: item["secType"] as AnyObject)) != nil ? (item["secType"] as! String) : "", forKey: "secType")

            insertData.setValue((self.nullToNil(value: item["isHeader"] as AnyObject)) != nil ? ((item["isHeader"] as! String) == "true" ? true : false) : false, forKey: "isHeader")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        print("FieldMaster")
        
        var fieldMaster = data["fldMaster"] as? [[String : Any]]
        fieldMaster?.removeLast()
        
        for (_,item) in (fieldMaster?.enumerated())! {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "FieldMaster", into: self.managedObjectContext!)
            
            insertData.setValue((self.nullToNil(value: item["master_fldId"] as AnyObject)) != nil ? (Int(item["master_fldId"] as! String)) : 0, forKey: "master_fldId")
            
            insertData.setValue((self.nullToNil(value: item["fldFormID"] as AnyObject)) != nil ? (Int(item["fldFormID"] as! String)) : 0, forKey: "fldFormID")
            
            insertData.setValue((self.nullToNil(value: item["sortOrder"] as AnyObject)) != nil ? (Int(item["sortOrder"] as! String)) : 0, forKey: "sortOrder")
            
            insertData.setValue((self.nullToNil(value: item["fldHint"] as AnyObject)) != nil ? ((item["fldHint"] as! String)) : "", forKey: "fldHint")
            
            insertData.setValue((self.nullToNil(value: item["fldLabel"] as AnyObject)) != nil ? ((item["fldLabel"] as! String)) : "", forKey: "fldLabel")
            
            insertData.setValue((self.nullToNil(value: item["fldLastUpdatedBy"] as AnyObject)) != nil ? ((item["fldLastUpdatedBy"] as! String)) : "", forKey: "fldLastUpdatedBy")
            
            insertData.setValue((self.nullToNil(value: item["fldLastUpdatedOn"] as AnyObject)) != nil ? (item["fldLastUpdatedOn"] as! String) : "", forKey: "fldLastUpdatedOn")
            
            insertData.setValue((self.nullToNil(value: item["fldType"] as AnyObject)) != nil ? (item["fldType"] as! String) : "", forKey: "fldType")
            
            insertData.setValue((self.nullToNil(value: item["fldValidationMsg"] as AnyObject)) != nil ? (item["fldValidationMsg"] as! String) : "", forKey: "fldValidationMsg")
            
            insertData.setValue((self.nullToNil(value: item["mappingLabel"] as AnyObject)) != nil ? (item["mappingLabel"] as! String) : "", forKey: "mappingLabel")
            
            insertData.setValue((self.nullToNil(value: item["fldHasRemarks"] as AnyObject)) != nil ? ((item["fldHasRemarks"] as! String) == "true" ? true : false) : false, forKey: "fldHasRemarks")
            
            insertData.setValue((self.nullToNil(value: item["fldIsActive"] as AnyObject)) != nil ? ((item["fldIsActive"] as! String) == "true" ? true : false) : false, forKey: "fldIsActive")
            
            insertData.setValue((self.nullToNil(value: item["fldIsDependent"] as AnyObject)) != nil ? ((item["fldIsDependent"] as! String) == "true" ? true : false) : false, forKey: "fldIsDependent")
            
            insertData.setValue((self.nullToNil(value: item["fldIsMandatory"] as AnyObject)) != nil ? ((item["fldIsMandatory"] as! String) == "true" ? true : false) : false, forKey: "fldIsMandatory")
            
            insertData.setValue((self.nullToNil(value: item["hasValidation"] as AnyObject)) != nil ? ((item["hasValidation"] as! String) == "true" ? true : false) : false, forKey: "hasValidation")
            
            insertData.setValue((self.nullToNil(value: item["isHeader"] as AnyObject)) != nil ? ((item["isHeader"] as! String) == "true" ? true : false) : false, forKey: "isHeader")
            
            insertData.setValue((self.nullToNil(value: item["isReadOnly"] as AnyObject)) != nil ? ((item["isReadOnly"] as! String) == "true" ? true : false) : false, forKey: "isReadOnly")
            
            insertData.setValue((self.nullToNil(value: item["showHeader"] as AnyObject)) != nil ? ((item["showHeader"] as! String) == "true" ? true : false) : false, forKey: "showHeader")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        print("FieldDataMaster")
        
        var fieldDataMaster = data["fielddatamaster"] as? [[String:Any]]
        fieldDataMaster?.removeLast()
        
        for (_,item) in (fieldDataMaster?.enumerated())! {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "FieldDataMaster", into: self.managedObjectContext!)
            
            insertData.setValue((self.nullToNil(value: item["id"] as AnyObject)) != nil ? (Int(item["id"] as! String)) : 0, forKey: "id")
            
            insertData.setValue((self.nullToNil(value: item["fielddata_codes"] as AnyObject)) != nil ? (Int(item["fielddata_codes"] as! String)) : 0, forKey: "fielddata_codes")
            
            insertData.setValue((self.nullToNil(value: item["fieldata_fieldid"] as AnyObject)) != nil ? (Int(item["fieldata_fieldid"] as! String)) : 0, forKey: "fieldata_fieldid")
            
            insertData.setValue((self.nullToNil(value: item["actiontaken"] as AnyObject)) != nil ? (Int(item["actiontaken"] as! String)) : 0, forKey: "actiontaken")

            insertData.setValue((self.nullToNil(value: item["fieldata_optionvalues"] as AnyObject)) != nil ? ((item["fieldata_optionvalues"] as! String)) : "", forKey: "fieldata_optionvalues")
            
            insertData.setValue((self.nullToNil(value: item["isActive"] as AnyObject)) != nil ? ((item["isActive"] as! String) == "true" ? true : false) : false, forKey: "isActive")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        print("FieldSectionMap")
        
        var fieldSectionMap = data["fieldsectionmap"] as? [[String:Any]]
        fieldSectionMap?.removeLast()
        
        for (_,item) in (fieldSectionMap?.enumerated())! {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "FieldSectionMap", into: self.managedObjectContext!)
            
            insertData.setValue((self.nullToNil(value: item["id"] as AnyObject)) != nil ? Int(item["id"] as! String) : 0, forKey: "id")
            
            insertData.setValue((self.nullToNil(value: item["fieldsecsort"] as AnyObject)) != nil ? Int(item["fieldsecsort"] as! String) : 0, forKey: "fieldsecsort")
            
            insertData.setValue((self.nullToNil(value: item["fieldsec_secid"] as AnyObject)) != nil ? Int(item["fieldsec_secid"] as! String) : 0, forKey: "fieldsec_secid")

            insertData.setValue((self.nullToNil(value: item["fieldsec_fieldid"] as AnyObject)) != nil ? Int(item["fieldsec_fieldid"] as! String) : 0, forKey: "fieldsec_fieldid")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        print("HeaderFieldSectionMap")
        
        var headerFieldSectionMap = data["headerfieldsectionmap"] as? [[String:Any]]
        headerFieldSectionMap?.removeLast()
        
        for (_,item) in (headerFieldSectionMap?.enumerated())! {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "HeaderFieldSectionMap", into: self.managedObjectContext!)
            
            insertData.setValue((self.nullToNil(value: item["id"] as AnyObject)) != nil ? Int(item["id"] as! String) : 0, forKey: "id")
            
            insertData.setValue((self.nullToNil(value: item["header_fieldsecsort"] as AnyObject)) != nil ? Int(item["header_fieldsecsort"] as! String) : 0, forKey: "header_fieldsecsort")
            
            insertData.setValue((self.nullToNil(value: item["header_fieldsec_secid"] as AnyObject)) != nil ? Int(item["header_fieldsec_secid"] as! String) : 0, forKey: "header_fieldsec_secid")
            
            insertData.setValue((self.nullToNil(value: item["header_fieldsec_fieldid"] as AnyObject)) != nil ? Int(item["header_fieldsec_fieldid"] as! String) : 0, forKey: "header_fieldsec_fieldid")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        print("Survey")
        
        var survey = data["survey"] as? [[String:Any]]
        survey?.removeLast()
        
        for (_,item) in (survey?.enumerated())! {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "Survey", into: self.managedObjectContext!)
            
            insertData.setValue((self.nullToNil(value: item["id"] as AnyObject)) != nil ? Int(item["id"] as! String) : 0, forKey: "id")
            
            insertData.setValue((self.nullToNil(value: item["code"] as AnyObject)) != nil ? Int(item["code"] as! String) : 0, forKey: "code")
            
            insertData.setValue((self.nullToNil(value: item["isSelected"] as AnyObject)) != nil ? Int(item["isSelected"] as! String) : 0, forKey: "isSelected")
            
            insertData.setValue((self.nullToNil(value: item["localVersion"] as AnyObject)) != nil ? Int(item["localVersion"] as! String) : 0, forKey: "localVersion")
            
            insertData.setValue((self.nullToNil(value: item["serviceVersion"] as AnyObject)) != nil ? Int(item["serviceVersion"] as! String) : 0, forKey: "serviceVersion")
            
            insertData.setValue((self.nullToNil(value: item["lastPublishedOn"] as AnyObject)) != nil ? ((item["lastPublishedOn"] as! String)) : "", forKey: "lastPublishedOn")
            
            insertData.setValue((self.nullToNil(value: item["lastUpdatedBy"] as AnyObject)) != nil ? ((item["lastUpdatedBy"] as! String)) : "", forKey: "lastUpdatedBy")

            insertData.setValue((self.nullToNil(value: item["name"] as AnyObject)) != nil ? ((item["name"] as! String)) : "", forKey: "name")
            
            insertData.setValue((self.nullToNil(value: item["lastUpdatedOn"] as AnyObject)) != nil ? ((item["lastUpdatedOn"] as! String)) : "", forKey: "lastUpdatedOn")
            
            insertData.setValue((self.nullToNil(value: item["isDownloaded"] as AnyObject)) != nil ? ((item["isDownloaded"] as! String) == "true" ? true : false) : false, forKey: "isDownloaded")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        print("TableFieldDependency")
        
        var tableFieldDependency = data["tableFieldDependency"] as? [[String:Any]]
        tableFieldDependency?.removeLast()
        
        for (_,item) in (tableFieldDependency?.enumerated())! {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "TableFieldDependency", into: self.managedObjectContext!)
            
            insertData.setValue((self.nullToNil(value: item["fielddependencydependentfieldid"] as AnyObject)) != nil ? Int(item["fielddependencydependentfieldid"] as! String) : 0, forKey: "fielddependencydependentfieldid")
            
            insertData.setValue((self.nullToNil(value: item["fielddependencyfieldid"] as AnyObject)) != nil ? Int(item["fielddependencyfieldid"] as! String) : 0, forKey: "fielddependencyfieldid")
            
            insertData.setValue((self.nullToNil(value: item["fielddependencyid"] as AnyObject)) != nil ? Int(item["fielddependencyid"] as! String) : 0, forKey: "fielddependencyid")
            
            insertData.setValue((self.nullToNil(value: item["fielddependencyvaluesid"] as AnyObject)) != nil ? Int(item["fielddependencyvaluesid"] as! String) : 0, forKey: "fielddependencyvaluesid")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        return true
    }
    
    func getMandatoryFieldsWithFieldId(fieldId : Int) -> [AnyObject]
    {
        let fetchRequest: NSFetchRequest<FieldMaster> = FieldMaster.fetchRequest()
        let predicate = NSPredicate(format: "fieldID = %ld", fieldId)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        }catch{
            return []
        }
    }
    
    func getFieldMasterWithSectionHeader(value: Int = 1) -> [AnyObject] {
        
        let fetchRequest: NSFetchRequest<FieldMaster> = FieldMaster.fetchRequest()
        let predicate = NSPredicate(format: "showHeader == %ld",value)
        fetchRequest.predicate = predicate
        
        let sortOrder = NSSortDescriptor.init(key: "sortOrder", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        } catch let error as NSError {
            print(error)
            return []
        }
    }
    
    func getSectionMasterWithFormID(secFormID: Int = 40219) -> [AnyObject] {
        
        let fetchRequest: NSFetchRequest<SectionMaster> = SectionMaster.fetchRequest()
        let predicate = NSPredicate(format: "secFormid == %ld", secFormID)
        fetchRequest.predicate = predicate
        
        let sortOrder = NSSortDescriptor.init(key: "secissub", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        } catch let error as NSError {
            print(error)
            return []
        }
    }
    
    func getSectionMasterWithCaseType(caseType: Int16) -> [AnyObject] {
        
        let fetchRequest: NSFetchRequest<SectionMaster> = SectionMaster.fetchRequest()
        let predicate = NSPredicate(format: "secCaseType == %ld", caseType)
        fetchRequest.predicate = predicate
        
        let sortOrder = NSSortDescriptor.init(key: "secissub", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        } catch let error as NSError {
            print(error)
            return []
        }
    }
    
    //Field Dependent on Radio Button
    func getFieldDependentWithFieldID(fieldID: Int) -> [AnyObject]
    {
        let fetchRequest: NSFetchRequest<TableFieldDependency> = TableFieldDependency.fetchRequest()
        let predicate = NSPredicate(format: "fielddependencydependentfieldid == %ld", fieldID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        }catch{
            return []
        }
    }
    
    func getFieldDataDependentWithFieldDataId(fieldDataId : Int)-> [AnyObject]
    {
        let fetchRequest: NSFetchRequest<TableFieldDependency> = TableFieldDependency.fetchRequest()
        let predicate = NSPredicate(format: "fielddependencydependentfieldid == %ld", fieldDataId)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        }catch{
            return []
        }
    }
    
    func getSectionNameWithId(sectionid : Int)-> [AnyObject]
    {
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<SectionMaster> = SectionMaster.fetchRequest()
        let predicate = NSPredicate(format: "secId == %ld", sectionid)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let sectionMasterDetails = try context?.fetch(fetchRequest)
            return sectionMasterDetails!
        }catch {
            return []
        }
    }

    
    func getFieldsFromFieldSectionMap(sectionID: Int) -> [AnyObject] {

        let fetchRequest: NSFetchRequest<FieldSectionMap> = FieldSectionMap.fetchRequest()
        let predicate = NSPredicate(format: "fieldsec_secid == %ld", sectionID)
        fetchRequest.predicate = predicate

        let sortOrder = NSSortDescriptor.init(key: "fieldsecsort", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        } catch let error as NSError {
            print(error)
            return []
        }
    }
    
    func getFieldMasterFromMappingLabel(mappingLabel: String) -> [AnyObject] {
        
        let fetchRequest: NSFetchRequest<FieldMaster> = FieldMaster.fetchRequest()
        let predicate = NSPredicate(format: "mappingLabel == %@", mappingLabel)
        fetchRequest.predicate = predicate
        
//        let sortOrder = NSSortDescriptor.init(key: "sortOrder", ascending: true)
//        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let fetchData = try self.managedObjectContext?.fetch(fetchRequest)
            return fetchData!
        } catch let error as NSError {
            print(error)
            return []
        }
    }

    
    func getFieldMasterWithFieldID(fieldID: Int) -> [AnyObject] {
        
        let fetchRequest: NSFetchRequest<FieldMaster> = FieldMaster.fetchRequest()
        let predicate = NSPredicate(format: "master_fldId == %ld", fieldID)
        fetchRequest.predicate = predicate
        
        let sortOrder = NSSortDescriptor.init(key: "sortOrder", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let fetchData = try self.managedObjectContext?.fetch(fetchRequest)
            return fetchData!
        } catch let error as NSError {
            print(error)
            return []
        }
    }
    
    func getFieldDataMaster(fieldID : Int) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<FieldDataMaster> = FieldDataMaster.fetchRequest()
        let predicate = NSPredicate(format: "fieldata_fieldid == %ld", fieldID)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "fielddata_codes", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fldMasterDetails = try context?.fetch(fetchRequest)
            return fldMasterDetails!
        }catch {
            return []
        }
    }
    
    func getFieldDataValueWithFieldID(fieldID: Int) -> String
    {
        let fetchRequest: NSFetchRequest<FieldDataMaster> = FieldDataMaster.fetchRequest()
        let predicate = NSPredicate(format: "fieldata_fieldid == %ld", fieldID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            if (fieldData?.count)! > 0
            {
                return (fieldData![0] as FieldDataMaster).fieldata_optionvalues!
            }else
            {
                return ""
            }
            
        }catch{
            return ""
        }
    }
    
    
    func getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: Int) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<TableFieldDependency> = TableFieldDependency.fetchRequest()
        let predicate = NSPredicate(format: "fielddependencyvaluesid == %ld", fieldID)
        fetchRequest.predicate = predicate
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fldDependents = try context?.fetch(fetchRequest)
            return fldDependents!
        }catch {
            return []
        }
    }
    
    func getDependentFieldsFromTableFieldDependency() -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<TableFieldDependency> = TableFieldDependency.fetchRequest()
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
        
    func insertSubmittedCaseDetails(_ response: [[String:AnyObject]], status : Int) -> Bool {
        let context = self.managedObjectContext
        for item in response {
            
            let caseData = NSEntityDescription.insertNewObject(forEntityName: "SubmittedCaseDetails", into: context!)
            
            caseData.setValue((self.nullToNil(value: item["fieldID"] as AnyObject?)) != nil ? Int(item["fieldID"] as! String)! : 0, forKey: "fieldID")
            
            caseData.setValue((self.nullToNil(value: item["status"] as AnyObject?)) != nil ? Int(item["status"] as! String)! : 0, forKey: "status")
            
            caseData.setValue((self.nullToNil(value: item["fieldValue"] as AnyObject?)) != nil ? item["fieldValue"] : "", forKey: "fieldValue")
            
            caseData.setValue((self.nullToNil(value: item["caseID"] as AnyObject?)) != nil ? Int(item["caseID"] as! String)! : 0 as AnyObject, forKey: "caseID")
            
            caseData.setValue((self.nullToNil(value: item["comments"] as AnyObject?)) != nil ? item["comments"] : "", forKey: "documentComments")
            
            caseData.setValue((self.nullToNil(value: item["authToken"] as AnyObject?)) != nil ? item["authToken"] : "", forKey: "authToken")
            
            caseData.setValue((self.nullToNil(value: item["documentID"] as AnyObject?)) != nil ? item["documentID"] : "", forKey: "documentID")

            caseData.setValue((self.nullToNil(value: item["documentPath"] as AnyObject?)) != nil ? item["documentPath"] : "", forKey: "documentPath")

            caseData.setValue((self.nullToNil(value: item["investigatorCode"] as AnyObject?)) != nil ? (item["investigatorCode"] as! String) : "", forKey: "investigatorID")
            
            caseData.setValue((self.nullToNil(value: item["investigationDateTime"] as AnyObject?)) != nil ? item["investigationDateTime"] : "", forKey: "investigationDateTime")
            
            caseData.setValue((self.nullToNil(value: item["isDocument"] as AnyObject?)) != nil ? ((item["isDocument"] as! String) == "true" ? true : false) : false, forKey: "isDocument")
            
            caseData.setValue((self.nullToNil(value: item["placeOfInspection"] as AnyObject?)) != nil ? (item["placeOfInspection"] as! String) : "" as AnyObject, forKey: "placeOfInspection")
            
            caseData.setValue((self.nullToNil(value: item["tabReferenceNumber"] as AnyObject?)) != nil ? (item["tabReferenceNumber"] as! String) : "" as AnyObject, forKey: "tabReferenceNumber")

            caseData.setValue((self.nullToNil(value: item["userName"] as AnyObject?)) != nil ? (item["userName"] as! String) : "" as AnyObject, forKey: "userName")
            
            caseData.setValue((self.nullToNil(value: item["webRefNumber"] as AnyObject?)) != nil ? (item["webRefNumber"] as! String) : "" as AnyObject, forKey: "webRefNumber")
            
            do {
                try context?.save()
            }
            catch {
                print("error")
                return false
            }
        }
        
        return true
    }
    
    
    func insertDetailsForSubmittedCase(response: [String:AnyObject]) -> Bool {
        
        let context = self.managedObjectContext
        
        let caseData = NSEntityDescription.insertNewObject(forEntityName: "SubmittedCaseDetails", into: context!) as! SubmittedCaseDetails
        
        caseData.setValue((self.nullToNil(value: response["CaseID"] as AnyObject?)) != nil ? (response["CaseID"])! : 0 , forKey: "caseID")
        
        caseData.setValue((self.nullToNil(value: response["AuthToken"] as AnyObject?)) != nil ? (response["AuthToken"])! : "", forKey: "authToken")
        
        caseData.setValue((self.nullToNil(value: response["InvestigatorID"] as AnyObject?)) != nil ? (response["InvestigatorID"])! : "", forKey: "investigatorID")
        
        caseData.setValue((self.nullToNil(value: response["InvestigationDateTime"] as AnyObject?)) != nil ? (response["InvestigationDateTime"])! : "", forKey: "investigationDateTime")
        
        caseData.setValue((self.nullToNil(value: response["PlaceOfInspection"] as AnyObject?)) != nil ? (response["PlaceOfInspection"])! : "" , forKey: "placeOfInspection")
        
        caseData.setValue((self.nullToNil(value: response["TabReferenceNumber"] as AnyObject?)) != nil ? (response["TabReferenceNumber"])! : "" , forKey: "tabReferenceNumber")
        
        caseData.setValue((self.nullToNil(value: response["UserName"] as AnyObject?)) != nil ? (response["UserName"])! : "" , forKey: "userName")
        
        caseData.setValue(((response["ResponseDetails"] as! [AnyObject]).count > 0) ? (response["ResponseDetails"] as! [AnyObject]) : "" , forKey: "responseDetails")
                
        do {
            try context?.save()
        }
        catch {
            print("error")
            return false
        }
        
        return true
    }
    
    func getSubmittedCaseDetails() -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<SubmittedCaseDetails> = SubmittedCaseDetails.fetchRequest()
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
    
    func deleteSubmittedCaseDetails()
    {
        let context = self.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SubmittedCaseDetails")
        request.returnsObjectsAsFaults = false
        
        do {
            let incidents = try context?.fetch(request)
            
            if (incidents?.count)! > 0 {
                
                for result: Any in incidents!{
                    context?.delete(result as! NSManagedObject)
                }
                try context?.save()
                
            }
            
        } catch {
            
        }
    }
    
    func getSubmittedCaseDetails(investigatorID : String, status : Int) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<SubmittedCaseDetails> = SubmittedCaseDetails.fetchRequest()
        let predicate = NSPredicate(format: "investigatorID == %@ && status == %ld",investigatorID,status)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let submittedDetails = try context?.fetch(fetchRequest)
            return submittedDetails!
        }catch {
            return []
        }
    }

}

extension DataModel {
    
    // User Details
    func getUserDetails(investigatorCode : String)-> [AnyObject]
    {
        let fetchRequest: NSFetchRequest<Login> = Login.fetchRequest()
        let predicate = NSPredicate(format: "investigatorCode == %@",investigatorCode)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let response = try self.managedObjectContext?.fetch(fetchRequest)
            return (response != nil && (response?.count)! > 0) ? response! : []
        }catch{
            return []
        }
    }

    
    // Login Response
    func insertIntoLogin(data: [String : AnyObject]) -> Bool {
        
        let insertData = NSEntityDescription.insertNewObject(forEntityName: "Login", into: self.managedObjectContext!)
        
        if data[Params.kInvestigatorName] != nil && !(data[Params.kInvestigatorName] is NSNull) && ((data[Params.kInvestigatorName] as! String).count) > 0
        {
            insertData.setValue((self.nullToNil(value: data[Params.kInvestigatorName] as AnyObject)) != nil ? (data[Params.kInvestigatorName] as! String) : "", forKey: "investigatorName")
        }
        
        if data[Params.kInvestigatorCode] != nil && !(data[Params.kInvestigatorCode] is NSNull) && ((data[Params.kInvestigatorCode] as! String).count) > 0
        {
            insertData.setValue((self.nullToNil(value: data[Params.kInvestigatorCode] as AnyObject)) != nil ? (data[Params.kInvestigatorCode] as! String) : "", forKey: "investigatorCode")
        }
        
        if data["AuthToken"] != nil && !(data["AuthToken"] is NSNull) && ((data["AuthToken"] as! String).count) > 0
        {
            insertData.setValue((self.nullToNil(value: data["AuthToken"] as AnyObject)) != nil ? (data["AuthToken"] as! String) : "", forKey: "authToken")
        }
        
        if  (data["NoOfCasesAssignable"] is NSNumber)
        {
            insertData.setValue((self.nullToNil(value: data["NoOfCasesAssignable"] as AnyObject)) != nil ? Int(truncating: (data["NoOfCasesAssignable"] as AnyObject) as! NSNumber) : 0, forKey: "noOfCasesAssignable")
        }
        
        if data["FromTime"] != nil && !(data["FromTime"] is NSNull) && ((data["FromTime"] as! String).count) > 0
        {
            insertData.setValue((self.nullToNil(value: data["FromTime"] as AnyObject)) != nil ? (data["FromTime"] as! String) : "", forKey: "fromTime")
        }
        
        if data["ToTime"] != nil && !(data["ToTime"] is NSNull) && ((data["ToTime"] as! String).count) > 0
        {
            insertData.setValue((self.nullToNil(value: data["ToTime"] as AnyObject)) != nil ? (data["ToTime"] as! String) : "", forKey: "toTime")
        }
        
        if data["TurnAroundTime"] != nil && !(data["TurnAroundTime"] is NSNull) && ((data["TurnAroundTime"] as! String).count) > 0
        {
            insertData.setValue((self.nullToNil(value: data["TurnAroundTime"] as AnyObject)) != nil ? (data["TurnAroundTime"] as! String) : "", forKey: "turnAroundTime")
        }
        
        do {
            try self.managedObjectContext?.save()
            return true
        }catch {
            return false
        }
    }
    
    func deleteLoginResponse()
    {
        let fetchRequest: NSFetchRequest<Login> = Login.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false

        do{
            let responseList = try self.managedObjectContext?.fetch(fetchRequest)

            if (responseList?.count)! > 0 {

                for result: Any in responseList! {
                    self.managedObjectContext?.delete(result as! NSManagedObject)
                }
                try self.managedObjectContext?.save()
            }
        }catch{

        }
    }
    
    // Assigned Case Response
    func insertIntoAssignedCases(assignedCaseArray: [AnyObject]) -> Bool {
        
        for index in 0..<assignedCaseArray.count {
            
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "AssignedCases", into: self.managedObjectContext!) as? AssignedCases
            
            insertData?.setValue((self.nullToNil(value: assignedCaseArray[index] as AnyObject)) != nil ? Int(assignedCaseArray[index] as! String) : 0, forKey: "caseID")
            
            insertData?.status = 1
            
            insertData?.priorityStatus = 4
            
            insertData?.investigatorID = (UserManager.sharedManager.investigatorCode != nil ? (UserManager.sharedManager.investigatorCode!) : "" )
            
            insertData?.caseAllotmentDate = Date()
            
            let date = Date()
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ssZ"
            let updatedDateString = dateformatter.string(from: date)
            
            let tabRefNumber = UserManager.sharedManager.investigatorCode! + updatedDateString + "000\(index)"
            
            insertData?.tabReferenceNumber = tabRefNumber
            
        }
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        
        return true
    }
    
    func updateAssignedCaseWithPriority(caseID: Int64,priorityStatus:Int16,investigatorID:String) -> Bool {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<AssignedCases> = AssignedCases.fetchRequest()
        let predicate = NSPredicate(format: "caseID == %ld && investigatorID == %@",caseID,investigatorID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            
            if (caseDetails?.count)! > 0 {
                
                let updateDetails = caseDetails![0]
                updateDetails.priorityStatus = priorityStatus
            }
            
            do {
                try context?.save()
                return true
            }
            catch {
                return false
            }
        }catch {
            return false
        }
        
    }
    
    func updateAssignedCaseStatus(caseID: Int64,status:Int16,investigatorID:String) -> Bool {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<AssignedCases> = AssignedCases.fetchRequest()
        let predicate = NSPredicate(format: "caseID == %ld AND investigatorID == %@",caseID,investigatorID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            if (caseDetails?.count)! > 0 {
                let updateDetails = caseDetails![0]
                updateDetails.status = status
            }
            do {
                try context?.save()
                return true
            }
            catch {
                return false
            }
        }catch {
            return false
        }
        
    }
    
    func deleteAssignedCase(caseID: Int64,investigatorID:String) -> Bool {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<AssignedCases> = AssignedCases.fetchRequest()
        let predicate = NSPredicate(format: "caseID == %ld && investigatorID == %@",caseID,investigatorID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        var isDeleted: Bool = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            
            if (caseDetails?.count)! > 0 {
                
                for result: Any in caseDetails!{
                    context?.delete(result as! NSManagedObject)
                }
                do {
                    try context?.save()
                    isDeleted = true
                }
                catch {
                    isDeleted = false
                }
            }
        }catch {
            isDeleted = false
        }
        return isDeleted
    }
    
    func insertCaseDetails(_ response: [[String:AnyObject]], status : Int) -> Bool {
        let context = self.managedObjectContext
        for item in response {
            
            let caseData = NSEntityDescription.insertNewObject(forEntityName: "CaseDetail", into: context!) as! CaseDetail
            caseData.setValue((self.nullToNil(value: item["fieldID"] as AnyObject?)) != nil ? item["fieldID"] : 0, forKey: "fieldID")
            caseData.setValue((self.nullToNil(value: item["fieldValue"] as AnyObject?)) != nil ? item["fieldValue"] : "NA", forKey: "fieldValue")
            caseData.setValue(UserManager.sharedManager.investigatorCode!, forKey: "investigatorCode")
            caseData.setValue((self.nullToNil(value: item["status"] as AnyObject?)) != nil ? ((status != 2) ? item["status"] : status as AnyObject) : 0, forKey: "status")
            caseData.setValue((self.nullToNil(value: item["fieldName"] as AnyObject?)) != nil ? item["fieldName"] : "NA", forKey: "fieldName")
            caseData.setValue((self.nullToNil(value: item["fieldType"] as AnyObject?)) != nil ? item["fieldType"] : "NA", forKey: "fieldType")
            caseData.setValue((self.nullToNil(value: item["webRefNumber"] as AnyObject?)) != nil ? item["webRefNumber"] : "NA", forKey: "webRefNumber")
            caseData.setValue((self.nullToNil(value: item["sectionID"] as AnyObject?)) != nil ? item["sectionID"] : 0, forKey: "sectionID")
            caseData.setValue((self.nullToNil(value: item["caseType"] as AnyObject?)) != nil ? item["caseType"] : 0, forKey: "caseType")
            caseData.setValue((self.nullToNil(value: item["isHeaderShown"] as AnyObject?)) != nil ? item["isHeaderShown"] : false, forKey: "isHeaderShown")
            caseData.setValue((self.nullToNil(value: item["surveyID"] as AnyObject?)) != nil ? Int(item["surveyID"] as! String)! : 0, forKey: "surveyID")
            
            //////
            
            caseData.setValue((self.nullToNil(value: item["lastUpdatedBy"] as AnyObject?)) != nil ? item["lastUpdatedBy"] : "", forKey: "lastUpdatedBy")
            
            caseData.setValue((self.nullToNil(value: item["lastUpdatedOn"] as AnyObject?)) != nil ? item["lastUpdatedOn"] : "", forKey: "lastUpdatedOn")
            
            caseData.setValue((self.nullToNil(value: item["caseID"] as AnyObject?)) != nil ? (item["caseID"]) : 0, forKey: "caseID")
            
            let date = Date()
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd/MM/yyyy'T'HH:mm:ssZ"
            let updatedDateString = dateformatter.string(from: date)
           
            /////
            
            caseData.setValue(updatedDateString, forKey: "submittedDate")
            
            caseData.setValue((self.nullToNil(value: item["mappingLabel"] as AnyObject?)) != nil ? (item["mappingLabel"] as! String) : "", forKey: "mappingLabel")
            
            
            do {
                try context?.save()
            }
            catch {
                print("error")
                return false
            }
        }
        return true
        
    }
    
    func insertIntoCaseDetail(response: [NSDictionary]) -> Bool {
        
        let sectionMaster : [AnyObject] = self.getSectionMasterWithFormID()
        
        var caseType: Int = 0
        
//        var count = 0
//
//        let date = Date()
//        let dateformatter = DateFormatter()
//        dateformatter.dateFormat = "dd/MM/yyyy'T'HH:mm:ssZ"
//        let updatedDateString = dateformatter.string(from: date)
        
        
        for (index,_) in response.enumerated() {
            
//            count = count + 1
//
//            let tabRefNumber = UserManager.sharedManager.investigatorCode! + updatedDateString + "000\(count)"
            
            let dictFromResponse = ((response as NSArray).object(at: index) as? NSDictionary)
            
            if ((dictFromResponse!["ResponseDetails"] as! NSArray).count > 0) {
                
                for position in 0..<(dictFromResponse!["ResponseDetails"] as! NSArray).count {
                    
                    let dictTemp = ((dictFromResponse!["ResponseDetails"] as! NSArray).object(at: position) as! NSDictionary)
                    
                    if (self.nullToNil(value: dictFromResponse!["CaseType"] as AnyObject)) != nil {
                        
                        switch (dictFromResponse!["CaseType"] as! String) {
                        case CaseType.kCashlessLessThan1Lakh :
                            caseType = 1
                            break
                        case CaseType.kCashlessMoreThan1Lakh :
                            caseType = 2
                            break
                        case CaseType.kReimbursementLessThan1Lakh :
                            caseType = 3
                            break
                        case CaseType.kReimbursementMoreThan1Lakh :
                            caseType = 4
                            break
                            
                        default:
                            break
                        }
                    }
                    
                    // save for header fields
                    
                    let fieldMasterHeader = self.getFieldMasterWithSectionHeader()
                    
                    if (fieldMasterHeader.count > 0)
                    {
                        for (index,fldHeaderItem) in fieldMasterHeader.enumerated() {
                            
                            _ = index
                            
                            let fldMasterHeader = fldHeaderItem as! FieldMaster
                            
                            if (fldMasterHeader.mappingLabel == (dictTemp.value(forKey: "FieldID") as! String)) {
                                
                                let insertCaseData = NSEntityDescription.insertNewObject(forEntityName: "CaseDetail", into: self.managedObjectContext!) as! CaseDetail
                                
                                insertCaseData.caseID = (Int64((self.nullToNil(value: dictFromResponse!["CaseID"] as AnyObject)) != nil ? Int(dictFromResponse!["CaseID"] as! String)! : 0))
                                
                                if (self.nullToNil(value: dictFromResponse!["CaseType"] as AnyObject)) != nil {
                                    
                                    switch (dictFromResponse!["CaseType"] as! String) {
                                    case CaseType.kCashlessLessThan1Lakh :
                                        insertCaseData.caseType = 1
                                        break
                                    case CaseType.kCashlessMoreThan1Lakh :
                                        insertCaseData.caseType = 2
                                        break
                                    case CaseType.kReimbursementLessThan1Lakh :
                                        insertCaseData.caseType = 3
                                        break
                                    case CaseType.kReimbursementMoreThan1Lakh :
                                        insertCaseData.caseType = 4
                                        break
                                        
                                    default:
                                        break
                                    }
                                }
                                
                                insertCaseData.tATStatus = ((self.nullToNil(value: dictFromResponse!["TATStatus"] as AnyObject)) != nil ? (dictFromResponse!["TATStatus"] as! String) : "")
                                
                                switch (insertCaseData.tATStatus!) {
                                case "Red" :
                                    insertCaseData.status = 1
                                    break
                                case "Orange" :
                                    insertCaseData.status = 2
                                    break
                                case "Green" :
                                    insertCaseData.status = 3
                                    break
                                default:
                                    insertCaseData.status = 4
                                    break
                                }
                                
                                
                                insertCaseData.fieldID = fldMasterHeader.master_fldId
                                insertCaseData.fieldName = fldMasterHeader.fldLabel
                                
                                insertCaseData.fieldValue = ((self.nullToNil(value: ((dictTemp.value(forKey: "FieldValue") as! NSArray).object(at: 0) as AnyObject))) != nil ? ((dictTemp.value(forKey: "FieldValue") as! NSArray).object(at: 0) as! String) : "")
                                
                                insertCaseData.investigatorCode = (UserManager.sharedManager.investigatorCode!)
                                
                                insertCaseData.isMandatory = fldMasterHeader.fldIsMandatory
                                insertCaseData.isHeaderShown = fldMasterHeader.isHeader
                                insertCaseData.sectionID = 0
                                insertCaseData.surveyID = fldMasterHeader.fldFormID
                                insertCaseData.webRefNumber = UserManager.sharedManager.investigatorCode
                                insertCaseData.lastUpdatedBy = fldMasterHeader.fldLastUpdatedBy
//                                insertCaseData.tabReferenceNumber = tabRefNumber
                                insertCaseData.fieldType = fldMasterHeader.fldType
                                
                                insertCaseData.lastUpdatedOn = fldMasterHeader.fldLastUpdatedOn
                                
                                insertCaseData.mappingLabel = fldMasterHeader.mappingLabel
                                
                                let assignedCase = DataModel.share.getAssignedCaseDataForCaseID(investigatorID: UserManager.sharedManager.investigatorCode!, caseID: insertCaseData.caseID) as! [AssignedCases]
                                
                                insertCaseData.tabReferenceNumber = assignedCase[0].tabReferenceNumber
                                
                            }
                        }
                    }
                    
                    // for non-header values
                    
                    if sectionMaster.count > 0 {
                        
                        for item in sectionMaster {
                            
                            let sectionID = (item as! SectionMaster).secId
                            
                            let secCaseType = (item as! SectionMaster).secCaseType
                            
                            // if caseType is matched then only to save rest values in the DB.
                            
                            if (secCaseType == caseType) {
                                
                                let fieldsFromFieldSectionMap = self.getFieldsFromFieldSectionMap(sectionID: Int(sectionID))
                                
                                if(fieldsFromFieldSectionMap.count > 0) {
                                    
                                    for field in fieldsFromFieldSectionMap {
                                        
                                        let fieldID = (field as! FieldSectionMap).fieldsec_fieldid
                                        
                                        let fieldMasterDetails = self.getFieldMasterWithFieldID(fieldID: Int(fieldID))
                                        
                                        for (index,fldItem) in fieldMasterDetails.enumerated() {
                                            
                                            _ = index
                                            
                                            let fldMasterData = fldItem as! FieldMaster
                                            
                                            if (fldMasterData.mappingLabel == (dictTemp.value(forKey: "FieldID") as! String)) {
                                                
                                                let insertCaseData = NSEntityDescription.insertNewObject(forEntityName: "CaseDetail", into: self.managedObjectContext!) as! CaseDetail
                                                
                                                insertCaseData.caseID = (Int64((self.nullToNil(value: dictFromResponse!["CaseID"] as AnyObject)) != nil ? Int(dictFromResponse!["CaseID"] as! String)! : 0))
                                                
                                                if (self.nullToNil(value: dictFromResponse!["CaseType"] as AnyObject)) != nil {
                                                    
                                                    switch (dictFromResponse!["CaseType"] as! String) {
                                                    case CaseType.kCashlessLessThan1Lakh :
                                                        insertCaseData.caseType = 1
                                                        break
                                                    case CaseType.kCashlessMoreThan1Lakh :
                                                        insertCaseData.caseType = 2
                                                        break
                                                    case CaseType.kReimbursementLessThan1Lakh :
                                                        insertCaseData.caseType = 3
                                                        break
                                                    case CaseType.kReimbursementMoreThan1Lakh :
                                                        insertCaseData.caseType = 4
                                                        break
                                                        
                                                    default:
                                                        break
                                                    }
                                                }
                                                
                                                insertCaseData.tATStatus = ((self.nullToNil(value: dictFromResponse!["TATStatus"] as AnyObject)) != nil ? (dictFromResponse!["TATStatus"] as! String) : "")
                                                
                                                switch (insertCaseData.tATStatus!) {
                                                case "Red" :
                                                    insertCaseData.status = 1
                                                    break
                                                case "Orange" :
                                                    insertCaseData.status = 2
                                                    break
                                                case "Green" :
                                                    insertCaseData.status = 3
                                                    break
                                                default:
                                                    insertCaseData.status = 4
                                                    break
                                                }
                                                
                                                insertCaseData.fieldID = fldMasterData.master_fldId
                                                insertCaseData.fieldName = fldMasterData.fldLabel
                                                
                                                insertCaseData.fieldValue = ((self.nullToNil(value: ((dictTemp.value(forKey: "FieldValue") as! NSArray).object(at: 0) as AnyObject))) != nil ? ((dictTemp.value(forKey: "FieldValue") as! NSArray).object(at: 0) as! String) : "")
                                                
                                                insertCaseData.investigatorCode = (UserManager.sharedManager.investigatorCode!)
                                                
                                                insertCaseData.isMandatory = fldMasterData.fldIsMandatory
                                                insertCaseData.isHeaderShown = fldMasterData.isHeader
                                                insertCaseData.sectionID = (item as! SectionMaster).secId
                                                insertCaseData.surveyID = (item as! SectionMaster).secFormid
                                                insertCaseData.webRefNumber = UserManager.sharedManager.investigatorCode
                                                insertCaseData.lastUpdatedBy = fldMasterData.fldLastUpdatedBy
//                                                insertCaseData.tabReferenceNumber = tabRefNumber
                                                insertCaseData.fieldType = fldMasterData.fldType
                                                
                                                insertCaseData.lastUpdatedOn = fldMasterData.fldLastUpdatedOn
                                                
                                                insertCaseData.mappingLabel = fldMasterData.mappingLabel
                                                
                                                let assignedCase = DataModel.share.getAssignedCaseDataForCaseID(investigatorID: UserManager.sharedManager.investigatorCode!, caseID: insertCaseData.caseID) as! [AssignedCases]
                                                
                                                insertCaseData.tabReferenceNumber = assignedCase[0].tabReferenceNumber
                                                
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    
                }
            }
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print(error)
            return false
        }
        return true
    }
    
    func deleteAssignedCaseDetails(caseID: Int64) -> Bool {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "caseID == %ld",caseID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        var isDeleted: Bool = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            
            if (caseDetails?.count)! > 0 {
                
                for result: Any in caseDetails!{
                    context?.delete(result as! NSManagedObject)
                }
                do {
                    try context?.save()
                    isDeleted = true
                }
                catch {
                    isDeleted = false
                }
            }
        }catch {
            isDeleted = false
        }
        return isDeleted
    }
    
    func insertIntoUploadQueue(_ response: [String:AnyObject]) -> Bool {
        
        let context = self.managedObjectContext
        
        let caseData = NSEntityDescription.insertNewObject(forEntityName: "UploadQueue", into: context!) as! UploadQueue
        caseData.setValue((self.nullToNil(value: response["isAutoSync"] as AnyObject?)) != nil ? response["isAutoSync"] : false, forKey: "isAutoSync")
        caseData.setValue((self.nullToNil(value: response["progressValue"] as AnyObject?)) != nil ? response["progressValue"] : 20, forKey: "progressValue")
        caseData.setValue((self.nullToNil(value: response["uploadLabelValue"] as AnyObject?)) != nil ? response["uploadLabelValue"] : "", forKey: "uploadLabelValue")
        caseData.setValue(false, forKey: "isMediaUploading")
        
        caseData.setValue((self.nullToNil(value: response["webReferenceNumber"] as AnyObject?)) != nil ? response["webReferenceNumber"] : "", forKey: "webReferenceNumber")

        caseData.setValue(UserManager.sharedManager.investigatorCode!, forKey: "investigatorCode")
        
        caseData.caseId = ((self.nullToNil(value: response["caseID"] as AnyObject?)) != nil ? response["caseID"] as! Int64 : 0)
        
        do {
            try context?.save()
            
        }
        catch {
            print("error")
            return false
        }
        return true
        
    }
    
    func getUploadQueueDetails(webReferenceNumber:String) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<UploadQueue> = UploadQueue.fetchRequest()
        let predicate = NSPredicate(format: "webReferenceNumber == %@",webReferenceNumber)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let submittedDetails = try context?.fetch(fetchRequest)
            return submittedDetails!
        }catch {
            return []
        }
    }
    
    func getUploadQueueDetailsForInvestigatorCode(investigatorCode : String) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<UploadQueue> = UploadQueue.fetchRequest()
        let predicate = NSPredicate(format: "investigatorCode == %@",investigatorCode)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let submittedDetails = try context?.fetch(fetchRequest)
            return submittedDetails!
        }catch {
            return []
        }
    }
    
    func updateUploadQueueDetails(_ queueDetails : [String:AnyObject]) -> Bool {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<UploadQueue> = UploadQueue.fetchRequest()
        let predicate = NSPredicate(format: "webReferenceNumber == %@",queueDetails["webReferenceNumber"] as! String)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            
            if (caseDetails?.count)! > 0 {
                
                let uploadDetails = caseDetails![0]
                uploadDetails.setValue(queueDetails["isMediaUploading"] as! Bool, forKey: "isMediaUploading")
                uploadDetails.setValue(queueDetails["progressValue"] as! Int, forKey: "progressValue")
                uploadDetails.setValue(queueDetails["uploadLabelValue"] as! String, forKey: "uploadLabelValue")
                
                do {
                    try context?.save()
                    return true
                }
                catch {
                    print("error")
                    return false
                }
            }else {
                return false
            }
            
        }catch {
            return false
        }
        
    }
    
    func deleteUploadQueueDetails(caseID: Int64, webReferenceNumber:String)
    {
        let context = self.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadQueue")
        let predicate = NSPredicate(format: "caseId == %ld AND webReferenceNumber == %@",caseID,webReferenceNumber)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        
        do {
            let incidents = try context?.fetch(request)
            
            if (incidents?.count)! > 0 {
                
                for result: Any in incidents!{
                    context?.delete(result as! NSManagedObject)
                }
                try context?.save()
                
            }
            
        } catch {
            
        }
        
        
    }
    
    func deleteUploadQueue()
    {
        let context = self.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadQueue")
        request.returnsObjectsAsFaults = false
        
        do {
            let incidents = try context?.fetch(request)
            
            if (incidents?.count)! > 0 {
                
                for result: Any in incidents!{
                    context?.delete(result as! NSManagedObject)
                }
                try context?.save() } } catch {}
        
    }
    
   
    func updateCaseDetails(_ response: [[String:AnyObject]], status : Int)
    {
        let context = self.managedObjectContext
        for item in response {
            let predicate = NSPredicate(format: "sectionID == %ld && fieldID == %ld && webRefNumber = %@",item["sectionID"] as! Int,item["fieldID"] as! Int,item["webRefNumber"] as! String)
            let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let caseDetails = try context?.fetch(fetchRequest)
                
                if((caseDetails?.count)! > 0) {
                    
                    let details = caseDetails![0]
                    
                    details.setValue((self.nullToNil(value: item["status"] as AnyObject?)) != nil ? (item["status"] as AnyObject) : 0, forKey: "status")
                    details.setValue((self.nullToNil(value: item["fieldValue"] as AnyObject?)) != nil ? String(describing: item["fieldValue"]!) : "NA", forKey: "fieldValue")
                    try context?.save()
                }
                
            }catch {
                
            }
        }
        
    }
    
    
    func updateCaseDetailsForCaseID(_ response: [[String:AnyObject]], status : Int)
    {
        let context = self.managedObjectContext
        for item in response {
            let predicate = NSPredicate(format: "sectionID == %ld && fieldID == %ld && webRefNumber = %@ && caseID == %ld",item["sectionID"] as! Int,item["fieldID"] as! Int,item["webRefNumber"] as! String,item["caseID"] as! Int64)
            let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let caseDetails = try context?.fetch(fetchRequest)
                
                if((caseDetails?.count)! > 0) {
                    
                    let details = caseDetails![0]
                    
                    details.setValue( status , forKey: "status")
                    details.setValue((self.nullToNil(value: item["fieldValue"] as AnyObject?)) != nil ? String(describing: item["fieldValue"]!) : "NA", forKey: "fieldValue")
                    try context?.save()
                }else {
                    
                    // make fresh entry for that field and case
                    
                    let insertCaseData = NSEntityDescription.insertNewObject(forEntityName: "CaseDetail", into: self.managedObjectContext!) as! CaseDetail
                    
                    insertCaseData.sectionID = (Int64((self.nullToNil(value: item["sectionID"] as AnyObject)) != nil ? (item["sectionID"] as! Int) : 0))
                    
                    insertCaseData.caseID = (Int64((self.nullToNil(value: item["caseID"] as AnyObject)) != nil ? (item["caseID"] as! Int) : 0))
                    
                    insertCaseData.caseType = (Int16((self.nullToNil(value: item["caseType"] as AnyObject)) != nil ? (item["caseType"] as! Int) : 0))
                    
                    insertCaseData.status = (Int64((self.nullToNil(value: item["status"] as AnyObject)) != nil ? (item["status"] as! Int) : 0))
                    
                    insertCaseData.fieldID = (Int64((self.nullToNil(value: item["fieldID"] as AnyObject)) != nil ? (item["fieldID"] as! Int) : 0))
                    
                    insertCaseData.fieldName = ((self.nullToNil(value: item["fieldName"] as AnyObject)) != nil ? (item["fieldName"] as! String) : "")
                    
                    insertCaseData.fieldValue = ((self.nullToNil(value: item["fieldValue"] as AnyObject)) != nil ? (item["fieldValue"] as! String) : "")
                    
                    insertCaseData.fieldType = ((self.nullToNil(value: item["fieldType"] as AnyObject)) != nil ? (item["fieldType"] as! String) : "")
                    
                    insertCaseData.investigatorCode = (UserManager.sharedManager.investigatorCode!)
                    
                    insertCaseData.webRefNumber = UserManager.sharedManager.investigatorCode
                    
                    insertCaseData.isMandatory = ((self.nullToNil(value: item["isMandatory"] as AnyObject)) != nil ? (item["isMandatory"] as! Bool) : false)
                    
                    insertCaseData.isHeaderShown = ((self.nullToNil(value: item["isHeaderShown"] as AnyObject)) != nil ? (item["isHeaderShown"] as! Bool) : false)
                    
                    insertCaseData.surveyID = (Int64((self.nullToNil(value: item["surveyID"] as AnyObject)) != nil ? Int(item["surveyID"] as! String)! : 0))
                    
                    insertCaseData.lastUpdatedBy = ((self.nullToNil(value: item["lastUpdatedBy"] as AnyObject)) != nil ? (item["lastUpdatedBy"] as! String) : "")
                    
                    insertCaseData.tabReferenceNumber = ((self.nullToNil(value: item["tabReferenceNumber"] as AnyObject)) != nil ? (item["tabReferenceNumber"] as! String) : "")
                    
                    insertCaseData.lastUpdatedOn = ((self.nullToNil(value: item["lastUpdatedOn"] as AnyObject)) != nil ? (item["lastUpdatedOn"] as! String) : "")
                    
                    insertCaseData.validationMsg = ((self.nullToNil(value: item["validationMsg"] as AnyObject)) != nil ? (item["validationMsg"] as! String) : "")
                    
                    insertCaseData.mappingLabel = ((self.nullToNil(value: item["mappingLabel"] as AnyObject)) != nil ? (item["mappingLabel"] as! String) : "")
                    
//                    let assignedCase = DataModel.share.getAssignedCaseDataForCaseID(investigatorID: UserManager.sharedManager.investigatorCode!, caseID: insertCaseData.caseID) as! [AssignedCases]
//                    insertCaseData.tabReferenceNumber = assignedCase[0].tabReferenceNumber
                    
                    
                    do {
                        try context?.save()
                    } catch let error as NSError {
                        print(error)
                    }
                }
                
            }catch {
                
            }
        }        
        
    }

    func getAssignedCases(status: Int,investigatorID:String) -> [AnyObject]{
        
        let fetchRequest: NSFetchRequest<AssignedCases> = AssignedCases.fetchRequest()
        let predicate = NSPredicate(format: "status == %ld && investigatorID == %@",status,investigatorID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let response = try self.managedObjectContext?.fetch(fetchRequest)
            return (response != nil && (response?.count)! > 0) ? response! : []
        }catch{
            return []
        }
    }
    
    func getAssignedCaseDataForCaseID(investigatorID:String,caseID:Int64) -> [AnyObject] {
        
        let fetchRequest: NSFetchRequest<AssignedCases> = AssignedCases.fetchRequest()
        let predicate = NSPredicate(format: "caseID == %ld && investigatorID == %@",caseID,investigatorID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let response = try self.managedObjectContext?.fetch(fetchRequest)
            return (response != nil && (response?.count)! > 0) ? response! : []
        }catch{
            return []
        }
    }
    
    func getAssignedCases(investigatorID:String) -> [AnyObject]{
        
        let fetchRequest: NSFetchRequest<AssignedCases> = AssignedCases.fetchRequest()
        let predicate = NSPredicate(format: "investigatorID == %@",investigatorID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let response = try self.managedObjectContext?.fetch(fetchRequest)
            return (response != nil && (response?.count)! > 0) ? response! : []
        }catch{
            return []
        }
    }
    
    func getAssignedCasesWithPriorityStatus(priorityStatus: Int = 1,status: Int = 1,investigatorID:String) -> [AnyObject]{
        
        let fetchRequest: NSFetchRequest<AssignedCases> = AssignedCases.fetchRequest()
        let predicate = NSPredicate(format: "priorityStatus == %ld AND status == %ld AND investigatorID == %@",priorityStatus,status,investigatorID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let response = try self.managedObjectContext?.fetch(fetchRequest)
            return (response != nil && (response?.count)! > 0) ? response! : []
        }catch{
            return []
        }
    }
    
    func getAssignedCaseDetail()-> [AnyObject]{
        
        let fetchRequest: NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let response = try self.managedObjectContext?.fetch(fetchRequest)
            return (response != nil && (response?.count)! > 0) ? response! : []
        }catch{
            return []
        }
    }
    
    func getAssignedCaseDetailsForFieldID(_ fieldID: Int, webRefNumber : String) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "fieldID == %ld && webRefNumber = %@",fieldID, webRefNumber)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
    
    func getAssignedCaseDetailsForFieldIDAndCaseID(_ fieldID: Int, webRefNumber : String,caseID: Int64) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "fieldID == %ld && webRefNumber = %@ && caseID == %ld",fieldID, webRefNumber,caseID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
    
    func getCaseDetailsForSectionID(sectionID: Int, webRefNumber : String) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "sectionID == %ld && webRefNumber = %@",sectionID, webRefNumber)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
    
    func getCaseDetailsForSectionIDAndCaseID(sectionID: Int, webRefNumber : String,caseID: Int64) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "sectionID == %ld && webRefNumber = %@ && caseID == %ld",sectionID, webRefNumber,caseID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
    
    
    func getCaseDetailsForCaseID(webRefNumber : String,caseID: Int64) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "webRefNumber = %@ && caseID == %ld", webRefNumber,caseID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
    
    func getAssignedCaseDetailForHeader(value: Int = 1,caseID: Int64) -> [AnyObject] {
        
        let fetchRequest: NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "isHeaderShown == %ld AND caseID == %ld",value,caseID)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let fieldData = try self.managedObjectContext?.fetch(fetchRequest)
            return fieldData!
        } catch let error as NSError {
            print(error)
            return []
        }
    }
    
    
    func getCaseDetailsForWebRefNumber(_ webRefNumber : String) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<CaseDetail> = CaseDetail.fetchRequest()
        let predicate = NSPredicate(format: "webRefNumber = %@", webRefNumber)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            return caseDetails!
        }catch {
            return []
        }
    }
    

    //Deleting data
    func deleteData()
    {
        let entities:NSArray = ["CaseDetail","AssignedCases","UploadQueue","FieldDataMaster","FieldSectionMap","FieldMaster","HeaderFieldSectionMap","SectionMaster","Survey","TableFieldDependency","Login","SubmittedCaseDetails","MediaInfo"]
        
        for i in 0..<entities.count {
            let context = self.managedObjectContext
            let str = entities[i] as! String
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: str)
            request.returnsObjectsAsFaults = false
            
            do {
                let incidents = try context?.fetch(request)
                
                if (incidents?.count)! > 0 {
                    
                    for result: Any in incidents!{
                        context?.delete(result as! NSManagedObject)
                    }
                    try context?.save()
                    
                }
                
            } catch {}
        }
    }
    
    //Deleting data
    func deleteCaseDataBeforeRefresh()
    {
        let entities:NSArray = ["CaseDetail","AssignedCases"]
        
        for i in 0..<entities.count {
            let context = self.managedObjectContext
            let str = entities[i] as! String
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: str)
            request.returnsObjectsAsFaults = false
            
            do {
                let incidents = try context?.fetch(request)
                
                if (incidents?.count)! > 0 {
                    
                    for result: Any in incidents!{
                        context?.delete(result as! NSManagedObject)
                    }
                    try context?.save()
                }
            } catch {}
        }
    }
    
    //get Image Details
    func getMediaDetailsForFieldID(fieldID : Int,webRefNumber : String) -> [AnyObject] {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<MediaInfo> = MediaInfo.fetchRequest()
        let predicate = NSPredicate(format: "fieldID == \(fieldID) && webRefNumber == %@",webRefNumber)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let imageDetails = try context?.fetch(fetchRequest)
            return imageDetails!
            
        }catch {
            print("error")
        }
        return []
        
    }
    
    
    func insertMediaDetailsForFieldID(fieldID: Int, webRefNumber: String,response: [[String:AnyObject]]) -> Bool {
        
        let context = self.managedObjectContext
        for item in response {
            
            let mediaData = NSEntityDescription.insertNewObject(forEntityName: "MediaInfo", into: context!)
            
            mediaData.setValue((self.nullToNil(value: item["fieldID"] as AnyObject?)) != nil ? item["fieldID"]! : 0, forKey: "fieldID")
            
            mediaData.setValue((self.nullToNil(value: item["latitude"] as AnyObject?)) != nil ? item["latitude"]! : 0, forKey: "latitude")
            
            mediaData.setValue((self.nullToNil(value: item["longitude"] as AnyObject?)) != nil ? item["longitude"]! : 0, forKey: "longitude")
            
            mediaData.setValue((self.nullToNil(value: item["mediaName"] as AnyObject?)) != nil ? item["mediaName"]! : "", forKey: "mediaName")
            
            mediaData.setValue((self.nullToNil(value: item["size"] as AnyObject?)) != nil ? item["size"]! : "", forKey: "size")
            
            mediaData.setValue((self.nullToNil(value: item["mediaType"] as AnyObject?)) != nil ? item["mediaType"]! : "", forKey: "mediaType")
            
            mediaData.setValue((self.nullToNil(value: item["lastModifiedDate"] as AnyObject?)) != nil ? item["lastModifiedDate"]! : "", forKey: "lastModifiedDate")
            
            mediaData.setValue((self.nullToNil(value: item["lastModifiedTime"] as AnyObject?)) != nil ? item["lastModifiedTime"]! : "", forKey: "lastModifiedTime")
            
            mediaData.setValue((self.nullToNil(value: item["webRefNumber"] as AnyObject?)) != nil ? item["webRefNumber"]! : "", forKey: "webRefNumber")
            
            mediaData.setValue((self.nullToNil(value: item["tag"] as AnyObject?)) != nil ? item["tag"]! : "", forKey: "tag")
            
            do {
                try context?.save()
                return true
            }
            catch {
                print("error")
                return false
            }
        }
        return true
    }
    
    func deleteMediaDetails(fieldID: Int64,webRefNumber:String,itemTag:String) -> Bool {
        
        let context = self.managedObjectContext
        let fetchRequest : NSFetchRequest<MediaInfo> = MediaInfo.fetchRequest()
        let predicate = NSPredicate(format: "fieldID == %ld && webRefNumber == %@ && tag == %@",fieldID,webRefNumber,itemTag)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        var isDeleted: Bool = false
        
        do {
            let caseDetails = try context?.fetch(fetchRequest)
            
            if (caseDetails?.count)! > 0 {
                
                for result: Any in caseDetails!{
                    context?.delete(result as! NSManagedObject)
                }
                do {
                    try context?.save()
                    isDeleted = true
                }
                catch {
                    isDeleted = false
                }
            }
        }catch {
            isDeleted = false
        }
        return isDeleted
    }
    
    
//    //get version Number
//    func getVersionForWebRefNumber(_ webRefNumber : String) -> Int {
//        
//        let context = self.managedObjectContext
//        let fetchRequest : NSFetchRequest<RejectedCaseDetails> = RejectedCaseDetails.fetchRequest()
//        let predicate = NSPredicate(format: "webReferenceNumber = %@", webRefNumber)
//        fetchRequest.predicate = predicate
//        fetchRequest.returnsObjectsAsFaults = false
//        
//        do {
//            let caseDetails = try context?.fetch(fetchRequest)
//            return  caseDetails!.count > 0 ? (caseDetails![0]).versionNo as! Int :  0
//        }catch {
//            return 0
//        }
//    }
    
    
     
}

