//
//  ViewController.swift
//  FireStoreDemo
//
//  Created by Randhir Kumar on 07/05/19.
//  Copyright © 2019 Randhir Kumar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import Firebase

let kProjectName = "projectName"
let kProjectId = "projectId"
let kProjectDuraiton = "projectDuratiion"

let db = Firestore.firestore()

class ViewController: UIViewController {

    @IBOutlet weak var aTableView: UITableView!
    @IBOutlet weak private var aProjectNameField: UITextField!
    @IBOutlet weak private var aProjectIdField: UITextField!
    @IBOutlet weak private var aProjectDurationField: UITextField!

    private var listener: ListenerRegistration?
    private let updateHandler: ([DocumentChange]) -> () = { _ in }

//    var dataSource = [[String: Any]]() {
//        didSet {
//            aTableView.reloadData()
//        }
//    }
    var projectDataSource = [ProjectDataModel]() {
        didSet {
            DispatchQueue.main.async {
                self.aTableView.reloadData()
            }
        }
    }
    
    private var documents: [DocumentSnapshot] = []
    var ref: DocumentReference? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDocument()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    @IBAction func addAction(_ sender: UIButton) {
        guard aProjectIdField.text != "" || aProjectNameField.text != "" || aProjectDurationField.text != "" else {
            return
        }
        addDocument(pname: aProjectNameField.text ?? "", pId: aProjectIdField.text ?? "", pDuration: aProjectDurationField.text ?? "")
    }
    @IBAction func orderByIdAction(_ sender: UIButton) {
//        orderBy(isID: true)
    }
    @IBAction func orderByNameAction(_ sender: UIButton) {
//        orderBy(isID: false)
    }
    fileprivate func clearTextFieldText() {
        self.aProjectIdField.text = ""
        self.aProjectNameField.text = ""
        self.aProjectDurationField.text = ""
    }
    
    private func addDocument(pname: String,pId: String,pDuration: String) {
        ref = db.collection("Projects").addDocument(data: [
            kProjectName: pname,
            kProjectId: pId,
            kProjectDuraiton: pDuration
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
                self.projectDataSource.removeAll()
//                self.getDocument()
                self.clearTextFieldText()
            }
        }
        
    }
    
    fileprivate func getDocument() {
//        db.collection("Projects").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
////                    self.dataSource.append(document.data())
//                    self.projectDataSource.append(ProjectDataModel(documentId: document.documentID, data: document.data()))
//                }
//            }
//        }
        listener = db.collection("Projects").addSnapshotListener({ (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                var tempProj = [ProjectDataModel]()

                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    //                    self.dataSource.append(document.data())
                    tempProj.append(ProjectDataModel(documentId: document.documentID, data: document.data()))
                }
                self.projectDataSource = tempProj
            }
        })
        
    }
    
    fileprivate func orderBy(isID: Bool) {
        let projectRef = db.collection("Projects")
        if isID {
            projectRef.order(by: kProjectId)
        } else {
            projectRef.order(by: kProjectName)
        }
        projectDataSource.removeAll()
//        getDocument()
    }
    fileprivate func deleteDocument(atIndex index: Int) {
        let data = projectDataSource[index]
        let id = data.documentId ?? ""
        db.collection("Projects").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.projectDataSource.remove(at: index)
            }
        }
    }
    fileprivate func showAlertBox(pname: String, pId: String, pDuration: String, docId: String,index: Int) {
        let alertVc = UIAlertController(title: "Update", message: "Enter your updated deltails", preferredStyle: .alert)
        alertVc.addTextField { (textfield) in
            textfield.placeholder = "Project Name"
            textfield.text = pname
        }
        alertVc.addTextField { (textfield) in
            textfield.placeholder = "Project Id"
            textfield.text = pId

        }
        alertVc.addTextField { (textfield) in
            textfield.placeholder = "Project Duration"
            textfield.text = pDuration
        }
        alertVc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertVc.addAction(UIAlertAction(title: "Update", style: .default, handler: { (alertAction) in
            // Do here
            let nameTextField = alertVc.textFields?[0]
            let idTextField = alertVc.textFields?[1]
            let durationTextField = alertVc.textFields?[2]

            if let name = nameTextField?.text, let duration = durationTextField?.text, let id = idTextField?.text {
                self.updateDocument(pName: name, pId: id, pDuration: duration, docId: docId, atIndex: index)
            }
        }))
        self.present(alertVc, animated: true, completion: nil)

    }
    
    fileprivate func updateDocument(pName: String, pId: String, pDuration: String, docId: String, atIndex: Int) {
        let ProjectsRef = db.collection("Projects").document(docId)
        
        ProjectsRef.updateData([
            kProjectName: pName,
            kProjectId: pId,
            kProjectDuraiton: pDuration

        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                let updatedField = ProjectDataModel(documentId: docId, data: [
                    kProjectName: pName,
                    kProjectId: pId,
                    kProjectDuraiton: pDuration
                    
                    ])
                self.projectDataSource[atIndex] = updatedField
                print("Document successfully updated")
                

            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.configCell(with: projectDataSource[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(atIndex: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = projectDataSource[indexPath.row]
        showAlertBox(pname: data.projectName ?? "", pId: data.projectID ?? "", pDuration: data.projectDuration ?? "", docId: data.documentId ?? "", index: indexPath.row)
    }
}


// MARK: Data Model
struct ProjectDataModel {
    let projectName: String?
    let projectID: String?
    let projectDuration: String?
    let documentId: String?
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.projectName = data[kProjectName] as? String
        self.projectID = data[kProjectId] as? String
        self.projectDuration = data[kProjectDuraiton] as? String
    }

}
