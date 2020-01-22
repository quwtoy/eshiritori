//
//  ViewController.swift
//  CoreML-samples
//
//  Created by Yuta Akizuki on 2017/06/23.
//  Copyright © 2017年 ytakzk. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var probsLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    var number = 0
    var hint: String = "" {
        didSet{
//            NSLog("now:%@", hint) // set 後の値
//            NSLog("old:%@", oldValue) // set 前の値
            hintLabel.text = "「" + hint + "」" + "から始まる写真を選んでね"
        }
    }
    
    // Deep Residual Learning for Image Recognition
    // https://arxiv.org/abs/1512.03385
    let resnetModel = Resnet50()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 163/255, green: 209/255, blue: 255/255, alpha: 90/100)
        resultLabel.text = ""
        probsLabel.text  = ""
        hint = "ま"
        hintLabel.textAlignment = NSTextAlignment.center
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openPhotoLibrary(_ sender: Any) {
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func predict(_ sender: Any) {
        guard let image = imageView.image, let ref = image.buffer else {
                
                return
        }
        
        resnet(ref: ref)
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        }
    }
    
    private var heightAtIndexPath: Dictionary<IndexPath, CGFloat> = [:]
    
    private var dataSource: Array<(Bool, String)> = []
    
    @IBAction func tapAddButton(_ sender: UIButton) {
        let text = "hogehoge"
        number = number + 1
        let isMe = number % 2 == 0
        dataSource.append((isMe, text))
        tableView.reloadDataAfter {
            self.tableView.scrollToRow(at: IndexPath(row: self.dataSource.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    // MARK: - UITableViewDelegate
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height: CGFloat = heightAtIndexPath[indexPath] {
            return height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightAtIndexPath[indexPath] = cell.frame.height
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell else { return UITableViewCell() }
        cell.talk(isMe: dataSource[indexPath.row].0, text: dataSource[indexPath.row].1)
        return cell
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The input image size should be 224x224 for ResNet
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let resized = image.resize(size: CGSize(width: 224, height: 224)) else {
                
                return
        }
        
        imageView.image  = resized
        resultLabel.text = ""
        probsLabel.text  = ""
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

private extension ViewController {
    
    func resnet(ref: CVPixelBuffer){
        
        do {
            
            // prediction
            let output = try resnetModel.prediction(image: ref)
            
            // sort classes by probability
            let sorted = output.classLabelProbs.sorted(by: { (lhs, rhs) -> Bool in
                
                return lhs.value > rhs.value
            })
            
            resultLabel.text = output.classLabel
            probsLabel.text  = "\(sorted[0].key): \(NSString(format: "%.2f", sorted[0].value))\n\(sorted[1].key): \(NSString(format: "%.2f", sorted[1].value))\n\(sorted[2].key): \(NSString(format: "%.2f", sorted[2].value))\n\(sorted[3].key): \(NSString(format: "%.2f", sorted[3].value))\n\(sorted[4].key): \(NSString(format: "%.2f", sorted[4].value))"
            
            let predict2 = sorted[0].key.components(separatedBy:",")
            let text:String? = predict2[0]
            number = number + 1
            let isMe = number % 2 == 0
            
            var convertedText:String = ""
            let s = text!.replacingOccurrences(of: " ", with: "", options: .regularExpression)
            let url = URL(string: "https://script.google.com/macros/s/AKfycbySgHHBd8r_5EJ6Ik7d6z1CczFL8JXwGAolLl2eQCfLkX5NQLJs/exec?source=en&target=ja&text=\(s)")!
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                do {
                    let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let jsonData = try JSONSerialization.data(withJSONObject: object)
                    let responce = try JSONDecoder().decode(Responce.self, from: jsonData)
                    convertedText = responce.text
                } catch let e {
                    print(e)
                }
            }
            task.resume()
            
            // 非同期のためsleep
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                
                // 最後の一文字(平仮名)を格納
                let convertedHiragana = TextConverter.convert(convertedText, to: .hiragana)
                let atamamoji = String(convertedHiragana.prefix(1))
                let shirimoji = String(convertedHiragana.suffix(1))
                
                // 先頭文字が前回末尾文字と一致している場合
                if (atamamoji == self.hint) {
                    self.hint = shirimoji
                    // TODO しりとりに成功したことをポップアップで通知
                    self.performSegue(withIdentifier: "SuccessSegue", sender: nil)
                // 一致しない場合
                } else {
                    // TODO 文字が一致していないことをポップアップで通知
                    self.performSegue(withIdentifier: "FailedSegue", sender: nil)
                    print("文字が違うよ")
                }
                
                //  文字列追加
                self.dataSource.append((isMe, convertedText))
                self.tableView.reloadDataAfter {
                    self.tableView.scrollToRow(at: IndexPath(row: self.dataSource.count - 1, section: 0), at: .bottom, animated: true)
                }
                
            }
        } catch {
            print(error)
        }
    }
    struct Responce: Codable {
        let code: Int
        let text: String
    }
    
    
    
    
}

final class TextConverter {
    private init() {}
    enum JPCharacter {
        case hiragana
        case katakana
        fileprivate var transform: CFString {
            switch self {
            case .hiragana:
                return kCFStringTransformLatinHiragana
            case .katakana:
                return kCFStringTransformLatinKatakana
            }
        }
    }

    static func convert(_ text: String, to jpCharacter: JPCharacter) -> String {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = ""
        let locale = CFLocaleCreate(kCFAllocatorDefault, CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, "ja" as CFString))
        let range = CFRangeMake(0, input.utf16.count)
        let tokenizer = CFStringTokenizerCreate(
            kCFAllocatorDefault,
            input as CFString,
            range,
            kCFStringTokenizerUnitWordBoundary,
            locale
        )

        var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        while (tokenType.rawValue != 0) {
            if let text = (CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? NSString).map({ $0.mutableCopy() }) {
                CFStringTransform(text as! CFMutableString, nil, jpCharacter.transform, false)
                output.append(text as! String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return output
    }
}
    

extension UITableView {
    func reloadDataAfter(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }) { _ in
            completion()
        }
    }
}

