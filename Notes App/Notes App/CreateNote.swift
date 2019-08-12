import UIKit
import SQLite3

class CreateNote: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    var isKeyboardOpen = false
    var isTextBold = false
    var isTextItalic = false
    var db: OpaquePointer?
    var noteToEdit: Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        
        var dbURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.sqlite")
        
        if sqlite3_open(dbURL.path, &db) == SQLITE_OK {
            
            sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY AUTOINCREMENT, note TEXT, isBold TEXT, isItalic TEXT, date TEXT, imagePath TEXT)", nil, nil, nil)
            
        }
        
        if noteToEdit != nil {
            
            initializeNote()
            
        }
        
    }
    
    func initializeNote () {
        
        addBtn.setTitle("Edit", for: .normal)
        
        textView.text = noteToEdit!["note"]
        textView.alpha = 1
        
        if noteToEdit!["isBold"] == "true" {
            
            textView.font = UIFont(name: "Georgia-Bold", size: 24)
            isTextBold = true
            
            if noteToEdit!["isItalic"] == "true" {
                
                textView.font = UIFont(name: "Georgia-BoldItalic", size: 24)
                isTextItalic = true
                
            }
            
        }

        if noteToEdit!["isItalic"] == "true" {
            
            textView.font = UIFont(name: "Georgia-Italic", size: 24)
            isTextItalic = true
            
            if noteToEdit!["isBold"] == "true" {
                
                textView.font = UIFont(name: "Georgia-BoldItalic", size: 24)
                isTextBold = true
                
            }
            
        }
        
        if noteToEdit!["imagePath"] != "" {
            
            let imageURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(noteToEdit!["imagePath"]!)
            
            imageView.image = UIImage(contentsOfFile: imageURL.path)
            
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Write your note here..." {
            
            textView.text = ""
            textView.alpha = 1
            
        }
        
        isKeyboardOpen = true
        
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        
        isKeyboardOpen = false
        
        if textView.text == "" {
            
            textView.text = "Write your note here..."
            textView.alpha = 0.5
            
        }
        
    }
    
    
    @IBAction func addClicked(_ sender: Any) {
        
        let note = textView.text
        
        if note == "Write your note here..." || note == "" {
            return
        }
        
        let italic = String (isTextItalic)
        let bold = String (isTextBold)
        let date = Date ().string(format: "dd/MM/yyyy")
        let image = imageView.image
        var imagePath = ""
        
        if image != nil {
            
            if noteToEdit != nil && noteToEdit!["imagePath"] != "" {
                imagePath = noteToEdit!["imagePath"]!
            } else {
                imagePath = UUID().uuidString + ".jpg"
            }
            
            let jpegData = image?.jpegData(compressionQuality: 1)
            
            let imageURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(imagePath)
            
            try! jpegData?.write(to: imageURL)
            
        }
        
        var query = "INSERT INTO notes (note, isBold, isItalic, date, imagePath) VALUES ('\(note!)', '\(bold)', '\(italic)', '\(date)', '\(imagePath)')"
        
        if noteToEdit != nil {
            query = "UPDATE notes SET note='\(note!)', isBold='\(bold)', isItalic='\(italic)', date='\(date)', imagePath='\(imagePath)' WHERE id='\(noteToEdit!["id"]!)'"
        }
        
        if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let firstScreen = storyboard.instantiateViewController(withIdentifier: "firstScreen")
            
            present(firstScreen, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func backClicked(_ sender: Any) {
        
        if isKeyboardOpen {
            textView.endEditing(true)
        } else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let firstScreen = storyboard.instantiateViewController(withIdentifier: "firstScreen")
            
            present(firstScreen, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func cameraClicked(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        imageView.image = info[.originalImage] as? UIImage
        
    }
    
    @IBAction func galleryClicked(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func boldClicked(_ sender: Any) {
        
        isTextBold = !isTextBold
        
        if isTextBold {
            
            textView.font = UIFont(name: "Georgia-Bold", size: 24)
            
            if isTextItalic {
                
                textView.font = UIFont(name: "Georgia-BoldItalic", size: 24)
                
            }
            
        } else {
            
            textView.font = UIFont(name: "Georgia", size: 24)
            
            if isTextItalic {
                
                textView.font = UIFont(name: "Georgia-Italic", size: 24)
                
            }
            
        }
        
    }
    
    @IBAction func italicCliked(_ sender: Any) {
        
        isTextItalic = !isTextItalic
        
        if isTextItalic {
            
            textView.font = UIFont(name: "Georgia-Italic", size: 24)
            
            if isTextBold {
                
                textView.font = UIFont(name: "Georgia-BoldItalic", size: 24)
                
            }
            
        } else {
            
            textView.font = UIFont(name: "Georgia", size: 24)
            
            if isTextBold {
                
                textView.font = UIFont(name: "Georgia-Bold", size: 24)
                
            }
            
        }
        
    }
    
}

extension Date {
    
    func string (format: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
        
    }
    
}
