//
//  TeamSelectionViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 02/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import XMPPFramework
import SWXMLHash


class TeamSelectionViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, ChatDelegate {
    
    @IBOutlet weak var companyListPickerViewController: UIPickerView!
    var companysArray = [Company]()
    var selectedTeamId = Int()
    var userChatId = String()
    var userChatPassword = String()
    var loginPassword = String()
    var loginUsername = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.delegate = self
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companysArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
    
        return  "\(companysArray[row].company_name)"
    
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedTeamId = companysArray[row].company_id
        
    }

    @IBAction func DoneButtonTapped(_ sender: UIBarButtonItem) {
        loginCall(email: loginUsername, password: loginPassword, company_id: selectedTeamId)
        let ChatSelectionNavigationScreen = UIStoryboard.ChatSelectionScreen()
        present(ChatSelectionNavigationScreen, animated: true, completion: nil)
        
    }
    

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func loginCall(email:String, password: String, company_id: Int){
        let params: [String:Any] = ["username": email as! String,"password": password as! String, "company": company_id as! Int]
        
        LoginService().loginCall(self.view, params: params, onSuccess: {(data: JSON) in
            self.userChatId = (data["cid"].stringValue).fromBase64()
            self.userChatPassword = (data["cip"].stringValue).fromBase64()
            
            self.setValue(value: self.userChatId + "@chat.eazespot.com", forKey: "chatUserID")
            self.setValue(value: self.userChatId + "@chat.eazespot.com", forKey: "chatUserID")
            if self.appDelegate.connect() {
                self.view.makeToast(message: "You are connected")
                self.getUserFromXMPPCoreDataObject(jidStr: self.userChatId + "@chat.eazehub.com")
            }
            else{
              self.view.makeToast(message: "Unable to connect")
            }
            ActivityIndicator.shared.hideProgressView()
            },failed: {(errorCode: Int) in debugPrint("TeamLoginError")})
        
        }
    
    
    
     
    // Mark: Private function
    
    private func setValue(value: String, forKey key: String) {
        if value.characters.count > 0 {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    func getUserFromXMPPCoreDataObject(jidStr: String) {
        let moc = managedObjectContext_roster() as NSManagedObjectContext?
        let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        fetchRequest.entity = entity
        
        var predicate: NSPredicate
        
        if self.appDelegate.xmppStream == nil {
            predicate = NSPredicate(format: "jidStr == %@", jidStr)
        } else {
            predicate = NSPredicate(format: "jidStr == %@ AND streamBareJidStr == %@", jidStr, UserDefaults.standard.string(forKey: "chatUserID")!)
        }
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        do {
           let result =  try moc?.fetch(fetchRequest)
            
            let a = result as! [NSManagedObject]
            
            for aaaa in result! {
                print("\(aaaa)")
            }
            
            var element: DDXMLElement!
            /*do {
                element = //try DDXMLElement(xmlString: String(describing: result))
            } catch _ {
                element = nil
            }*/
            print("HOOO00 \(result)")
            
        
        }
        catch {
        
        
        }

    }
   /* func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        let moc = managedObjectContext_roster() as NSManagedObjectContext?
        var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
        if fetchedResultsControllerVar == nil {
            
            let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
            let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
            let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
            let sortDescriptors = [sd1, sd2]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            fetchRequest.entity = entity
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 20
            
            fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
            fetchedResultsControllerVar?.delegate = self
            
            do {
                try fetchedResultsControllerVar!.performFetch()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
            
        }
        
        return fetchedResultsControllerVar!
        
    }
   
    
*/
    // MARK: - ChatDelegate Methods
    
    func buddyWentOnline() {
        //        if !onlineBuddies.contains(name) {
        //            onlineBuddies.add(name)
        //
        //            }
    }
    
    func buddyWentOffline() {
        //            onlineBuddies.remove(name)
        
    }
    
    func didDisconnect() {
//        onlineBuddies.removeAllObjects()
        
    }

    
    // MARK: - Core Data stack
    func managedObjectContext_roster() -> NSManagedObjectContext {
        return self.appDelegate.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    func userFromRosterForJID(jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID(string: jid)
        
        if let user = self.appDelegate.xmppRosterStorage.user(for: userJID, xmppStream: self.appDelegate.xmppStream, managedObjectContext:managedObjectContext_roster()) {
            return user
        } else {
            return nil
        }
    }
    
}
