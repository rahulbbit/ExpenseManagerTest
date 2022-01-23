//
//  CategorySelectionVC.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import UIKit

class CategorySelectionVC: UIViewController {
    
    // MARK:- IBOutlets
    @IBOutlet weak var tblCategories: UITableView!
    
    //MARK:- Global Variables
    var allCateogory : [Category]?
    var expenseCategoryInputClosure: ((Category) -> Void)?
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setNavigationBar()
        self.fetchCategoryList()
        self.tblCategories.register(UINib(nibName: "CategoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoriesTableViewCell")
    }
    
    private func fetchCategoryList()
    {
        allCateogory = CoreDataManger.sharedInstance.fetchAllManageObjects(EntityName: "Category" , sortDescriptorKey: nil, isAscending: false, fetchLimit: false) as? [Category]
        
        self.tblCategories.reloadData()
    }
    
    func setNavigationBar()
    {
        let searchBar:UISearchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self as UISearchBarDelegate
        searchBar.placeholder = "Search Category"
        searchBar.sizeToFit()
        searchBar.returnKeyType = .done
        self.navigationItem.titleView = searchBar
    }
    
}

//MARK:- NavigationBar Buttons Delegates
extension CategorySelectionVC
{
    @IBAction func cancelButtonTapped(sender: AnyObject)
    {
        self.dismissVC()
    }
    
    func dismissVC()
    {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- CollectionView DataSource Methods
extension CategorySelectionVC : UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCateogory?.count ?? 0
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblCategories.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as? CategoriesTableViewCell
        cell?.category = allCateogory?[indexPath.row]
        return cell ?? UITableViewCell()
    }
}

//MARK:- CollectionView Delegate Methods
extension CategorySelectionVC : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let category = allCateogory?[indexPath.row]
        {
            expenseCategoryInputClosure?(category)
            self.dismissVC()
        }
    }
}

extension CategorySelectionVC : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let height = collectionView.frame.size.height
        let width = collectionView.frame.size.width
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            if (height < 400)
            {
                return CGSize(width: width/4, height: height/3)
            }
            else
            {
                return CGSize(width: width/4, height: height/6)
            }
            
        }else
        {
            return CGSize(width: width/8, height: height/4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    
}

//MARK:- UISearchBar Delegate Methods
extension CategorySelectionVC : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.tblCategories.reloadData()
        searchBar.resignFirstResponder()
    }
}

extension CategorySelectionVC : UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class HalfSizePresentationController : UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let theView = containerView else {
                return CGRect.zero
            }
            return CGRect(x: 0, y: theView.bounds.height/2, width: theView.bounds.width, height: theView.bounds.height/2)
        }
    }
}
