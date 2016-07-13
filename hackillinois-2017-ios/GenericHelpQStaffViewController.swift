//
//  GenericHelpQStaffViewController.swift
//  hackillinois-2017-ios
//
//  Created by Shotaro Ikeda on 7/13/16.
//  Copyright © 2016 Shotaro Ikeda. All rights reserved.
//

import UIKit
import CoreData

class GenericHelpQStaffViewController: GenericCardViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    /* User Information */
    var user: User = (Helpers.loadContext(entityName: "User", fetchConfiguration: nil) as! [User])[0]
    
    /* Core Data components */
    var fetchedResultsController: NSFetchedResultsController!
    var fetchPredicate: NSPredicate!
    
    /* Core Data functions */
    func loadSavedData() {
        fatalError("Super classes loadSavedData was called, child class must override loadSavedData.")
    }
    
    func saveAndReload() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            Helpers.saveContextMainThread()
            dispatch_async(dispatch_get_main_queue()) {
                self.loadSavedData()
            }
        }
    }
    
    /* MARK: Population of sample data */
    func populateSampleData() {
        print("Creating Dummy Data")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let createHelpQLambda: (String, String, String, String) -> HelpQ = { (tech, lang, loc, desc) in
            let helpQ = NSEntityDescription.insertNewObjectForEntityForName("HelpQ", inManagedObjectContext: appDelegate.managedObjectContext) as! HelpQ
            helpQ.initialize(tech, language: lang, location: loc, description: desc)
            return helpQ
        }
        
        let h1 = createHelpQLambda("Node JS", "Javascript", "Siebel 2202", "Help with Asynchronous Calls")
        h1.isHelping = NSNumber(bool: true)
        createHelpQLambda("Memory Allocation/Deallocation", "C++", "Siebel 1404","Help with unknown use after free error")
        createHelpQLambda("Threading", "C", "ECEB 2201","Cannot figure out how to multithread my code.")
        createHelpQLambda("Python", "Python", "Siebel", "How to print with python")
        createHelpQLambda("UITableView", "iOS", "Find me around ECEB labs", "Automatic Dimension is creates strange behavior for animations")
        createHelpQLambda("Machine Learning", "Python", "Labs at Siebel", "Which model to use?")
        createHelpQLambda("MySQL", "Python-Flask", "around 2nd floor DCL", "How do I connect Python to my database?")
        
        saveAndReload()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Using fetchedResultsController makes it so we need to fetch modified data everytime user wants to 
        // see the view
        super.viewDidAppear(animated)
        loadSavedData()
    }
    
    // Mark: UIViewController Functions
    override func viewDidLoad() {
        guard collectionView != nil else {
            fatalError("You must set the collection view before calling the super classes' viewDidLoad function")
        }
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchPredicate = nil
        loadSavedData()
        
        // Set delegates
        fetchedResultsController.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        /* Remove for production */
        if fetchedResultsController.fetchedObjects?.count == 0 {
            populateSampleData()
        }
    }
    
    /*
    // Mark: Button Handler
    func cellButtonPressed(sender: ReferencedButton) {
        let helpQItem = sender.referenceObject as! HelpQ
        
        /* Configure button */
        if !helpQItem.isHelping.boolValue {
            helpQItem.assignMentor(mentor: user.name, helpStatus: true)
            sender.setTitle("Stop Helping User", forState: .Normal)
        } else {
            helpQItem.assignMentor(mentor: "", helpStatus: false)
            sender.setTitle("Help User", forState: .Normal)
        }
        
        saveAndReload()
    }
    */
    
    // Mark: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    // Mark: Dummy UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError("Super classes cellForItemAtIndexPath was called, child classes must override this method.")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}