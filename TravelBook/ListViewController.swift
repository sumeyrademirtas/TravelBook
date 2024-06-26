//
//  ListViewController.swift
//  TravelBook
//
//  Created by Sümeyra Demirtaş on 6.06.2024.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    
    var selectedPlace = ""
    var selectedPlaceId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
         navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
        
         
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    
    @objc func getData() {
        
        
        self.titleArray.removeAll(keepingCapacity: false) // to prevent duplication
        self.idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        
        //fetch
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title")  as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let id = result.value(forKey: "id")  as? UUID {
                        self.idArray.append(id)
                    }
                }
            }
            
            self.tableView.reloadData() //yeni veri geldiginde kendisini guncellemesi icin

        } catch {
            print("error")
        }
    }
    
        
    
    
    @objc func addButtonClicked(){
            selectedPlace = ""
            performSegue(withIdentifier: "toViewController", sender: nil)
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = titleArray[indexPath.row]
        selectedPlaceId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as? ViewController
            destinationVC?.chosenPlace = selectedPlace
            destinationVC?.chosenPlaceId = selectedPlaceId //secilen placein hem ismini hem id sini diger tarafa aktarmis oluyoruz
        }
    }
    

    



}
