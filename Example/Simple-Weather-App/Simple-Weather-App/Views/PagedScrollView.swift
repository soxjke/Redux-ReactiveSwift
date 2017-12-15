//
//  PagedScrollView.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 12/3/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveCocoa
import ReactiveSwift
import Result

class PagedScrollView<T: UIView>: UIScrollView {
    var pages: [T] {
        didSet {
            recreateSubviews()
            recreateConstraints()
        }
    }
    private (set) var isSoftwareAnimation: Bool = false
    
    init() {
        pages = []
        super.init(frame: CGRect.zero)
        isPagingEnabled = true
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented. Use init()")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init()")
    }
    
    func set(page: Int, animated: Bool = true) {
        isSoftwareAnimation = true
        setContentOffset(CGPoint(x: CGFloat(page) * bounds.size.width, y: 0), animated: animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.isSoftwareAnimation = false
        }
    }
    
    private func recreateSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
        pages.forEach { addSubview($0) }
    }
    private func recreateConstraints() {
        (0..<pages.count).forEach { (index) in
            pages[index].snp.makeConstraints({ (make) in
                make.height.equalToSuperview()
                make.width.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                if (0 == index) {
                    make.left.equalToSuperview()
                } else {
                    make.left.equalTo(pages[index - 1].snp.right)
                }
                if (pages.count - 1 == index) {
                    make.right.equalToSuperview()
                }
            })
        }
    }
}

extension PagedScrollView {
    var reactivePages: BindingTarget<[T]> {
        return reactive.makeBindingTarget { $0.pages = $1 }
    }
    func reactiveSetPage(animated: Bool = true) -> BindingTarget<Int> {
        return reactive.makeBindingTarget { $0.set(page: $1, animated: animated) }
    }
    func reactivePageProducer() -> SignalProducer<Int, NoError> {
        return reactive.producer(forKeyPath: "contentOffset")
            .map { (value) -> CGPoint in
                guard let objectValue = value as? NSValue else {
                    return .zero
                }
                return objectValue.cgPointValue
            }
            .map { [weak self] (value) -> Int in
                guard let strongSelf = self,
                        strongSelf.bounds.size.width > 0 else { return 0 }
                return Int((value.x / strongSelf.bounds.size.width).rounded())
            }
            .skipRepeats()
    }
}
