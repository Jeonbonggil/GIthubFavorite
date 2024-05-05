//
//  UITableView.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import UIKit

protocol NibLoadable where Self: UIView {
    func fromNib() -> UIView?
    static var nibName: String { get }
}

public protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

public extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
    
    static var reuseIdentifirer: String {
        return "\(self)"
    }
}

extension NibLoadable {
    @discardableResult
    func fromNib() -> UIView? {
        let contentView = Bundle(for: type(of: self)).loadNibNamed(
            String(describing: type(of: self)),
            owner: self,
            options: nil
        )?.first as? UIView
        addSubview(contentView ?? UIView())
        contentView?.translatesAutoresizingMaskIntoConstraints = false
        contentView?.edges(to: self)
        return contentView
    }
    
    func fromNib(_ xibName: String) -> UIView? {
        let contentView = Bundle(for: type(of: self)).loadNibNamed(
            xibName,
            owner: self,
            options: nil
        )?.first as? UIView
        addSubview(contentView ?? UIView())
        contentView?.translatesAutoresizingMaskIntoConstraints = false
        contentView?.edges(to: self)
        return contentView
    }
    
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    static var nibNm: String {
        return "\(self)"
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView, T: NibLoadable {
        register(UINib(nibName: T.nibNm, bundle: nil), forCellReuseIdentifier: T.reuseIdentifirer)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(
        forIndexPath indexPath: IndexPath
    ) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.reuseIdentifirer,
            for: indexPath
        ) as? T else {
            return UITableViewCell() as! T
        }
        return cell
    }
}
