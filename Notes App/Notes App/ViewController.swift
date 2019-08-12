import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let note = notes[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondScreen = storyboard.instantiateViewController(withIdentifier: "secondScreen") as! CreateNote
        
        secondScreen.noteToEdit = note
        
        present(secondScreen, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let note = notes[indexPath.row]
            
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            sqlite3_exec(db, "DELETE FROM notes WHERE id='\(note["id"]!)'", nil, nil, nil)
            
            if note["imagePath"] != "" {
            
                let imageURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(note["imagePath"]!)
            
                try! FileManager.default.removeItem(at: imageURL)
            }
            
            animateLabel()
        }
        
    }

    func animateLabel () {
        
        if notes.count == 0 {
            
            DispatchQueue.global(qos: .background).async {
                
                for c in "Empty!" {
                    
                    DispatchQueue.main.async {
                        self.infoLabel.text = self.infoLabel.text! + String(c)
                    }
                    
                    usleep(50000)
                    
                }
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        let note = notes[indexPath.row]
        
        let isBold = note["isBold"]
        let isItalic = note["isItalic"]
        
        cell.noteLabel.text = note["note"]
        cell.dateLabel.text = note["date"]
        
        if isBold == "true" {
            
            cell.noteLabel.font = UIFont(name: "Georgia-Bold", size: 18)
            
            if isItalic == "true" {
                
                cell.noteLabel.font = UIFont(name: "Georgia-BoldItalic", size: 18)
                
            }
            
        }
        
        if isItalic == "true" {
            
            cell.noteLabel.font = UIFont(name: "Georgia-Italic", size: 18)
            
            if isBold == "true" {
                
                cell.noteLabel.font = UIFont(name: "Georgia-BoldItalic", size: 18)
                
            }
            
        }
        
        return cell
    }
    

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var db: OpaquePointer?
    var notes: [Dictionary<String, String>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let dbURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.sqlite")
        
        if sqlite3_open(dbURL.path, &db) == SQLITE_OK {
            
            let query = "SELECT * FROM notes"
            var queryStatement: OpaquePointer?
            
            if sqlite3_prepare(db, query, -1, &queryStatement, nil) == SQLITE_OK {
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    
                    let id = String (sqlite3_column_int(queryStatement, 0))
                    let note = String (cString: sqlite3_column_text(queryStatement, 1))
                    let isBold = String (cString: sqlite3_column_text(queryStatement, 2))
                    let isItalic = String (cString: sqlite3_column_text(queryStatement, 3))
                    let date = String (cString: sqlite3_column_text(queryStatement, 4))
                    let imagePath = String (cString: sqlite3_column_text(queryStatement, 5))
                    
                    let item = ["id": id, "note": note, "isBold": isBold, "isItalic": isItalic, "date": date, "imagePath": imagePath]
                    
                    notes.append(item)
                }
                
            }
            
        }
        
        animateLabel()
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.tableFooterView = UIView()
        
    }


}

