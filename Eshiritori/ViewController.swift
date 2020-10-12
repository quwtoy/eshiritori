//
//  ViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020年 quwtoy. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var lifePointLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var imageSelectButton: UIButton!
    @IBOutlet weak var predictButton: UIButton!
    var photoList:[UIImage] = []
    var imageTextList:[String] = []
    @IBOutlet weak var beforeImageView:UIImageView!
    @IBOutlet weak var predictImageView:UIImageView!
    var hint: String = "" {
        didSet{
            hintLabel.text = "「" + hint + "」" + "から始まる写真を選んでね"
        }
    }
    var lifePoint: Int = 0 {
        didSet{
            if(lifePoint > 0){
                lifePointLabel.text = "×" + String(lifePoint)
            }else if(lifePoint == 0){
                self.gameOverMessage = String(self.argLifePoint) + "回間違えたから負けだよ"
                self.performSegue(withIdentifier: "FailedSegue", sender: nil)
            }
        }
    }
    var score: Int = 0 {
        didSet{
            scoreLabel.text = String(score) + "点"
        }
    }
    var answer = ""
    var myTurnFlg: Bool = true {
        didSet{
            if(!myTurnFlg){
                print("computer turn!!!!!!")
            }
        }
    }
    var argLevel = ""
    var argLifePoint = 0
    var argHint = ""
    var argMyTurnFlg = true
    var gameOverMessage = ""
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var offsetX: CGFloat = 0
    var maxX: CGFloat = 0
    
    // Deep Residual Learning for Image Recognition
    // https://arxiv.org/abs/1512.03385
    let resnetModel = Resnet50()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 163/255, green: 209/255, blue: 255/255, alpha: 100/100)
        //角丸の程度を指定
        self.imageSelectButton.layer.cornerRadius = 20.0
        self.predictButton.layer.cornerRadius = 20.0
        // tmpImageを非表示
        self.beforeImageView.isHidden = true
        self.predictImageView.isHidden = true
        self.imageView.isHidden = true
        
        hint = self.argHint
        lifePoint = self.argLifePoint
        myTurnFlg = self.argMyTurnFlg
        
        print("initial setting--------------")
        print("level =" + argLevel)
        print("hint =" + hint)
        print("lifePoint =" + String(lifePoint))
        print("myTurnFlg =" + String(myTurnFlg))
        print("initial setting--------------")
        
        // gifImageを更新
        let battleImage:UIImage?
        if(self.myTurnFlg){
            battleImage = UIImage.gif(name: "myTurn")
        }else{
            battleImage = UIImage.gif(name: "enemyTurn")
        }
        self.gifView.image = battleImage
        self.beforeImageView.image = battleImage
        hintLabel.textAlignment = NSTextAlignment.center
        
        // scrollViewの画面表示サイズを指定
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 300, width: self.view.frame.size.width, height: self.imageView.frame.size.height))
        // scrollViewのサイズを指定（幅は1メニューに表示するViewの幅×ページ数）
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 3, height: self.imageView.frame.size.height)
        // scrollViewのデリゲートになる
        self.scrollView.delegate = self as! UIScrollViewDelegate
        // メニュー単位のスクロールを可能にする
        self.scrollView.isPagingEnabled = true
        // 水平方向のスクロールインジケータを非表示にする
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        // スクロールでの水平移動を不可にする
        self.scrollView.isScrollEnabled = false
        // scrollView上にUIImageViewを配置
        self.setUpImageView()
        // pageControlの表示位置とサイズの設定
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: 470, width: self.view.frame.size.width, height: 30))
        // pageControlのページ数を設定
        self.pageControl.numberOfPages = 3
        // pageControlのドットの色
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        // pageControlの現在のページのドットの色
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(self.pageControl)
        // score初期化
        self.score = 0
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(myTurnFlg){
            self.turnLabel.text = "あなたのターンです"
            self.imageSelectButton.setTitle("写真を選ぶ", for: .normal)
            self.predictButton.setTitle("回答", for: .normal)
        }else{
            self.turnLabel.text = "CPUのターンです"
            self.imageSelectButton.setTitle("写真を選ばせる", for: .normal)
            self.predictButton.setTitle("回答させる", for: .normal)
        }
    }
    
    // UIImageViewを生成
    func createImageView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, image: UIImage) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
        imageView.image = image
        return imageView
    }
    
    // photoListの要素分UIImageViewをscrollViewに並べる
    func setUpImageView() {
        for i in 0 ..< self.photoList.count {
            let photoItem = self.photoList[i]
            let photoImageView = createImageView(x: 0, y: 0, width: self.imageView.frame.size.width, height: self.imageView.frame.size.height, image: photoItem)
            let x = max((self.scrollView.frame.width - self.imageView.frame.width)/2, 0)
            print(self.offsetX)
            photoImageView.frame = CGRect(origin: CGPoint(x: x + self.offsetX, y: 0), size: CGSize(width: self.imageView.frame.size.width, height: self.imageView.frame.size.height))
            photoImageView.layer.cornerRadius = photoImageView.frame.size.width * 0.1
            photoImageView.clipsToBounds = true
            
            let s = self.imageTextList[i]
            let s2 = NSAttributedString(string: s, attributes:
                [.font:UIFont.boldSystemFont(ofSize: 24.0),
                 .foregroundColor: UIColor.black])
            let sz = photoImageView.image!.size
            let r = UIGraphicsImageRenderer(size:sz)
            photoImageView.image = r.image {
                _ in
                photoImageView.image!.draw(at:.zero)
                s2.draw(at: CGPoint(x:10, y:sz.height-30))
            }
            
            self.scrollView.addSubview(photoImageView)
            
            
            self.view.sendSubview(toBack: self.scrollView)
        }
    }

    
    @IBAction func nextImageButtonAction(_ sender: Any) {
        print(self.offsetX)
        print(self.photoList.count)
        if(self.offsetX < self.maxX){
            self.offsetX += self.view.frame.size.width
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset.x = self.offsetX
            }
        }
    }
    
    @IBAction func prevImageButtonAction(_ sender: Any) {
        print(self.offsetX)
        if(self.offsetX > 0){
            self.offsetX -= self.view.frame.size.width
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset.x = self.offsetX
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Segueを利用し画面遷移および値渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // 失敗時メッセージ通知
       if(segue.identifier == "FailedSegue"){
           let nextView = segue.destination as! FailedViewController
           nextView.argImage = predictImageView.image
           nextView.argMessage = "「" + answer + "」は\n「" + hint + "」から始まらないよ"
           if(gameOverMessage != ""){
            nextView.argGameOverMessage = self.gameOverMessage
            self.gameOverMessage = ""
           }
       // 成功時メッセージ通知
       }else if(segue.identifier == "SuccessSegue"){
           let nextView = segue.destination as! SuccessViewController
           // SuccessViewControllerに値渡し
           nextView.argImage = predictImageView.image
           nextView.argMessage = "「" + answer + "」"
       // GAME OVER時メッセージ通知
       }else if(segue.identifier == "GameOverSegue"){
           let nextView = segue.destination as! GameOverViewController
           // GameOverViewControllerに値渡し
        nextView.score = self.score
        
       }
   }
    
    // ターンによって呼び出しを変更
    @IBAction func pushSelectImageButton(_ sender: Any) {
        if(myTurnFlg){
            self.openPhotoLibrary()
        }else{
            self.cpuSelectImage()
        }
    }

    // 写真を選択
    func openPhotoLibrary() {
        self.present(imagePicker, animated: true, completion: nil)
    }

    
    // CPU側写真を選択
    func cpuSelectImage() {
        let yorokobiImage = UIImage.gif(name: "yorokobi")
        gifView.image = yorokobiImage
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.cpuAnswer()
            self.predictImageView.image = self.imageView.image
        }
    }
    
    // ターンによって呼び出しを変更
    @IBAction func pushPredictButton(_ sender: Any) {
        if(self.imageView.image == nil){
            print("not predict!!!!!!")
            return
        }
        if(myTurnFlg){
            self.predict()
        }else{
            self.cpuPredict()
        }
    }
    
    // 画像を解析
    func predict() {
        predictImageView.image = imageView.image
        gifView.image = imageView.image
        guard let image = predictImageView.image, let ref = image.buffer else {
                return
        }
        resnet(ref: ref)
        
        let loadingImage = UIImage.gif(name: "pasokon")
        gifView.image = loadingImage
    }
    // CPU側画像を解析
    func cpuPredict() {
        guard let image = predictImageView.image, let ref = image.buffer else {
                return
        }
        resnet(ref: ref)
        
        let loadingImage = UIImage.gif(name: "pasokon")
        gifView.image = loadingImage
    }
    
    func cpuAnswer(){
        print(hintLabel.text!)
        if(hint == "あ"){
            guard let resized = UIImage(named: "ari")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "い"){
            guard let resized = UIImage(named: "itigo")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "う"){
            guard let resized = UIImage(named: "uuru")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "え"){
            guard let resized = UIImage(named: "ejiputononeko")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "お"){
            guard let resized = UIImage(named: "ooboe")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "か"){
            guard let resized = UIImage(named: "karubonara")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "き"){
            guard let resized = UIImage(named: "kyusu")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "く"){
            guard let resized = UIImage(named: "grandpiano")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "け"){
            guard let resized = UIImage(named: "geta")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "こ"){
            guard let resized = UIImage(named: "kounotori")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "さ"){
            guard let resized = UIImage(named: "sangosho")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "し"){
            guard let resized = UIImage(named: "shimauma")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "す"){
            guard let resized = UIImage(named: "zukkini")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "せ"){
            guard let resized = UIImage(named: "semi")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "そ"){
            guard let resized = UIImage(named: "sougankyou")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "た"){
            guard let resized = UIImage(named: "tanuki")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ち"){
            guard let resized = UIImage(named: "ti-ta-")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "つ"){
            guard let resized = UIImage(named: "tsume")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "て"){
            guard let resized = UIImage(named: "tv")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "と"){
            guard let resized = UIImage(named: "donguri")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "な"){
            guard let resized = UIImage(named: "nabe")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "に"){
            guard let resized = UIImage(named: "nyuyokucap")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ぬ"){
        }else if(hint == "ね"){
            guard let resized = UIImage(named: "neckless")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "の"){
            guard let resized = UIImage(named: "note")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "は"){
            guard let resized = UIImage(named: "banana")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ひ"){
            guard let resized = UIImage(named: "binnocap")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ふ"){
            guard let resized = UIImage(named: "huutou")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "へ"){
            guard let resized = UIImage(named: "petorisara")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ほ"){
            guard let resized = UIImage(named: "potpie")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ま"){
            guard let resized = UIImage(named: "mashpotato")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "み"){
            guard let resized = UIImage(named: "mimi")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "む"){
            guard let resized = UIImage(named: "musubime")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "め"){
            guard let resized = UIImage(named: "menbou")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "も"){
            guard let resized = UIImage(named: "morumotto")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "や"){
            guard let resized = UIImage(named: "yadokari")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ゆ"){
            guard let resized = UIImage(named: "yumi")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "よ"){
            guard let resized = UIImage(named: "yo-ru")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ら"){
            guard let resized = UIImage(named: "racket")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "り"){
            guard let resized = UIImage(named: "riboruba")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "る"){
            guard let resized = UIImage(named: "rule")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "れ"){
            guard let resized = UIImage(named: "redfox")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "ろ"){
            guard let resized = UIImage(named: "romendensya")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }else if(hint == "わ"){
            guard let resized = UIImage(named: "wahhuruyakigata")?.resize(size: CGSize(width: 224, height: 224)) else {
                    return
            }
            imageView.image  = resized
            gifView.image  = resized
        }
    }
    
    private var heightAtIndexPath: Dictionary<IndexPath, CGFloat> = [:]
    
    private var dataSource: Array<(Bool, String)> = []
    
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

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scrollViewのページ移動に合わせてpageControlの表示も移動
        self.pageControl.currentPage = Int(self.scrollView.contentOffset.x / self.scrollView.frame.size.width)
        // offsetXの値を更新
        self.offsetX = self.scrollView.contentOffset.x
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
        gifView.image = resized
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
            
            let predict2 = sorted[0].key.components(separatedBy:",")
            let text:String? = predict2[0]
            let isMe = self.myTurnFlg
            
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
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.5) {
                
                // 最後の一文字(平仮名)を格納
                let convertedHiragana = TextConverter.convert(convertedText, to: .hiragana)
                self.answer = String(convertedHiragana)
                let atamamoji = self.cleanHiragana(str:String(convertedHiragana.prefix(1)))
                var shirimoji = self.cleanHiragana(str:String(convertedHiragana.suffix(1)))
                if(shirimoji == "ー"){
                    shirimoji = self.cleanHiragana(str:String(convertedHiragana.suffix(2)))
                }
                print(convertedHiragana)
                
                // 先頭文字が前回末尾文字と一致している場合
                if (atamamoji == self.hint) {
                    // 末尾文字が「ん」の場合GameOver
                    if(shirimoji == "ん"){
                        self.gameOverMessage = "「ん」で終わったら負けだよ"
                        self.performSegue(withIdentifier: "FailedSegue", sender: nil)
                    }
                    // 末尾文字を登録
                    self.hint = shirimoji
                    // しりとりに成功したことをポップアップで通知
                    self.performSegue(withIdentifier: "SuccessSegue", sender: nil)
                    if(self.myTurnFlg){
                        self.score = self.score + 1
                    }         
                    //  文字列追加
                    self.dataSource.append((isMe, convertedText))
                    self.imageTextList.append(convertedHiragana)
                    self.imageView.image = self.predictImageView.image
                    self.beforeImageView.image = self.predictImageView.image
                    self.myTurnFlg.toggle()
                    // 正解したためoffsetを変更
                    self.offsetX = 0
                    self.photoList.forEach {_ in
                        if self.photoList.count > 0 {
                            self.offsetX += self.view.frame.size.width
                            self.maxX += self.view.frame.size.width
                        }
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.scrollView.contentOffset.x = self.offsetX
                    }
                    // スクロールに追加
                    self.photoList.append((self.imageView.image?.resize(size: CGSize(width: 224, height: 224)))!)
                    self.setUpImageView()
                    
                // 一致しない場合
                } else {
                    self.lifePoint -= 1
                    // 文字が一致していないことをポップアップで通知
                    self.performSegue(withIdentifier: "FailedSegue", sender: nil)
                }
                // gifImageを更新
                let battleImage:UIImage?
                if(self.myTurnFlg){
                    battleImage = UIImage.gif(name: "myTurn")
                }else{
                    battleImage = UIImage.gif(name: "enemyTurn")
                }
                self.gifView.image = battleImage
                self.imageView.image = nil
            }
        } catch {
            print(error)
        }

    }
    
    func cleanHiragana(str: String) -> String{
        if(str == "ぁ"){
            return "あ"
        }else if(str == "ぃ"){
            return "い"
        }else if(str == "ゔ" || str == "ぅ"){
            return "う"
        }else if(str == "ぇ"){
            return "え"
        }else if(str == "ぉ"){
            return "お"
        }else if(str == "が"){
            return "か"
        }else if(str == "ぎ"){
            return "き"
        }else if(str == "ぐ"){
            return "く"
        }else if(str == "げ"){
            return "け"
        }else if(str == "ご"){
            return "こ"
        }else if(str == "ざ"){
            return "さ"
        }else if(str == "じ"){
            return "し"
        }else if(str == "ず"){
            return "す"
        }else if(str == "ぜ"){
            return "せ"
        }else if(str == "ぞ"){
            return "そ"
        }else if(str == "だ"){
            return "た"
        }else if(str == "ぢ"){
            return "ち"
        }else if(str == "づ" || str == "っ"){
            return "つ"
        }else if(str == "で"){
            return "て"
        }else if(str == "ど"){
            return "と"
        }else if(str == "ば" || str == "ぱ"){
            return "は"
        }else if(str == "び" || str == "ぴ"){
            return "ひ"
        }else if(str == "ぶ" || str == "ぷ"){
            return "ふ"
        }else if(str == "べ" || str == "ぺ"){
            return "へ"
        }else if(str == "ぼ" || str == "ぽ"){
            return "ほ"
        }else if(str == "ゃ"){
            return "や"
        }else if(str == "ゅ"){
            return "ゆ"
        }else if(str == "ょ"){
            return "よ"
        }else if(str == "ゎ"){
            return "わ"
        }
        return str
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
