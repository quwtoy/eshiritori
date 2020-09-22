//
//  yokoViewController.swift
//  CoreML-samples
//
//  Created by 伊藤優樹 on 2020/04/01.
//  Copyright © 2020 ytakzk. All rights reserved.
//

import UIKit

class yokoViewController: UIViewController {
    var photoList:[UIImage] = []
    
    private var scrollView: UIScrollView!
    private var pageControl: UIPageControl!
    private var offsetX: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoList.append(UIImage(named: "kyusu")!)
        photoList.append(UIImage(named: "tanuki")!)
        photoList.append(UIImage(named: "uuru")!)
        // scrollViewの画面表示サイズを指定
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: self.view.frame.size.width, height: 200))
        // scrollViewのサイズを指定（幅は1メニューに表示するViewの幅×ページ数）
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 3, height: 200)
        // scrollViewのデリゲートになる
        self.scrollView.delegate = self as! UIScrollViewDelegate
        // メニュー単位のスクロールを可能にする
        self.scrollView.isPagingEnabled = true
        // 水平方向のスクロールインジケータを非表示にする
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        
        // scrollView上にUIImageViewを配置
        self.setUpImageView()
        
        // pageControlの表示位置とサイズの設定
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: 370, width: self.view.frame.size.width, height: 30))
        // pageControlのページ数を設定
        self.pageControl.numberOfPages = 4
        // pageControlのドットの色
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        // pageControlの現在のページのドットの色
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(self.pageControl)
        
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
            let imageView = createImageView(x: 0, y: 0, width: self.view.frame.size.width, height: self.scrollView.frame.size.height, image: photoItem)
            imageView.frame = CGRect(origin: CGPoint(x: self.view.frame.size.width * CGFloat(i), y: 0), size: CGSize(width: self.view.frame.size.width, height: self.scrollView.frame.size.height))
            self.scrollView.addSubview(imageView)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.offsetX += self.view.frame.size.width
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset.x = self.offsetX
        }
    }
    
    @IBAction func prevButtonAction(_ sender: Any) {
        self.offsetX -= self.view.frame.size.width
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset.x = self.offsetX
        }
    }
}

extension yokoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scrollViewのページ移動に合わせてpageControlの表示も移動
        self.pageControl.currentPage = Int(self.scrollView.contentOffset.x / self.scrollView.frame.size.width)
        // offsetXの値を更新
        self.offsetX = self.scrollView.contentOffset.x
    }
}
