//
//  SearchResultViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 29/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import MagicalRecord

class SearchResultViewController: UIViewController {
	
	
	@IBOutlet weak var searchTextField: SearchTextField!
    
    //MARK:- Properties:
    var searchController: UISearchController!
    var filteredProductsList: [Product]?
    var filteredArray: [Product]? {
        get {
            return filteredProductsList
        } set {
            if let newValue = newValue {
                self.filteredProductsList = newValue
                self.searchResultTableView.reloadData()
            }
        }
    }
    var searchText: String? = ""
    var _searchString: String = ""
    var searchDataText: String? {
        get {
            return self._searchString
        } set {
            if let newString = newValue {
                self._searchString = newString
            }
        }
    }
    var onlineSearchResult = [[String: AnyObject]]()
    
    //MARK:- IB-Outlets:
    
    @IBOutlet weak var searchResultTableView: UITableView!
    
    //MARK:- Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
		self.searchTextField.placeholder = NSLocalizedString("Search", comment: "")
        self.addNotificationObservers()
				self.searchTextField.becomeFirstResponder()
				self.searchTextField.addTarget(self, action: #selector(SearchResultViewController.textFieldTextChanged), for: UIControlEvents.editingChanged)
				self.searchTextField.rightView?.isHidden = true
				self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}

extension SearchResultViewController {
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SearchResultViewController.keyBoardWillShow),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SearchResultViewController.keyBoardWillCollapse),
                                               name: .UIKeyboardWillHide, object: nil)
    }
	
	func textFieldTextChanged(_ textField: UITextField) {
			print("Changed text \(textField.text)")
			if let searchText = textField.text {
				if searchText != "" {
					
					if AppManager.currentApplicationMode() == .online {
						if searchText.characters.count >= 3 {
							self.searchResultTableView.isHidden = false
							self.getSearchResults(withText: searchText)
						}
					} else {
						if searchText.characters.count >= 3 {
							self.searchResultTableView.isHidden = false
							self.getMatchingProducts(withText: searchText)
						}
					}
				} else {
					self.searchResultTableView.isHidden = true
					self.onlineSearchResult = []
					self.filteredArray = []
					self.searchResultTableView.reloadData()
				}
			}
		}
}

extension SearchResultViewController: UISearchResultsUpdating {
	
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if AppManager.currentApplicationMode() == .online {
                if searchText.characters.count >= 3 {
                    self.getSearchResults(withText: searchText)
                }
            } else {
                if searchText.characters.count >= 3 {
                    self.getMatchingProducts(withText: searchText)
                }
            }
        }
    }
}

extension SearchResultViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			textField.resignFirstResponder()
			return true
	}
}

extension SearchResultViewController: UISearchControllerDelegate {
    
}

extension SearchResultViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var searchTextStr = ""
        if AppManager.currentApplicationMode() == .online {
            searchTextStr = searchText.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: " ")
            
            if searchText.characters.count >= 3 {
                self.getSearchResults(withText: searchTextStr)
            }
            
            if searchText.characters.count >= 3 {
                self.getSearchResults(withText: searchText)
            }
        } else {
            if searchText.characters.count >= 3 {
                self.getMatchingProducts(withText: searchText)
            }
        }
    }
}

//MARK:- UITableViewDataSource
extension SearchResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AppManager.currentApplicationMode() == .online {
            return self.onlineSearchResult.count
        } else {
            return self.filteredArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultsTableViewCell
		
			 cell.selectionStyle = .none
        if AppManager.currentApplicationMode() == .online {
            let searchResultProd = self.onlineSearchResult[indexPath.row]
            
            if let productName = (AppManager.languageType() == .arabic ? searchResultProd["arname"] as? String : searchResultProd["name"] as? String), let image = searchResultProd["image"] {
                cell.productNameLabel.text = productName
					
					let prorperURL = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
					let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
					
					UploadTaskHandler.sharedInstance.setImage(onImageView: (cell.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
					self.handleProductSpecialPrice(atCell: cell, atIndexPath: indexPath)
            }
        } else {
			if let searchedName = filteredArray?[indexPath.row] {
				cell.productNameLabel.text = (AppManager.languageType() == .arabic ? searchedName.arName : searchedName.productName)
				if let imageData = filteredArray?[indexPath.row].imageData as? Data {
					if let prouctImage = UIImage(data: imageData) {
						cell.productImageView.image = prouctImage
					} else {
						cell.productImageView.image = #imageLiteral(resourceName: "placeHolderImage")
					}
				} else {
					cell.productImageView.image = #imageLiteral(resourceName: "placeHolderImage")
				}
			}
        }
		handleProductSpecialPrice(atCell: cell, atIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10.0)
        return cell
    }
}

//MARK:- UITableViewDelegate
extension SearchResultViewController: UITableViewDelegate {
    //currentProductInfo
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchTextField.resignFirstResponder()
        if AppManager.currentApplicationMode() == .online {
            let selectedProduct = self.onlineSearchResult[indexPath.row]
            if let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: ProductDetailViewController.selfName()) as? ProductDetailViewController {
                productDetailVc.currentProductInfo = selectedProduct
                productDetailVc.fromScreenType = .search
                self.navigationController?.pushViewController(productDetailVc, animated: true)
            }
        } else {
            if let selectedProduct = self.filteredArray?[indexPath.row] {
                        /* switch languageType {
                        case .arabic:
                            /* productData = ProductData(withName: selectedProduct.arName!, withProductId: selectedProduct.productId!, andDescription: selectedProduct.arDescription!, selectedProduct.model!, selectedProduct.price, prodImage: selectedProduct.image!, selectedProduct.isInCart, selectedProduct.isProductLiked, specialPrice: selectedProduct.specialPrice, availability: selectedProduct.availability.description, selectedProduct.arName!, selectedProduct.arDescription!) */
									
                        case .english:
                            productData = ProductData(withName: selectedProduct.productName!, withProductId: selectedProduct.productId!, andDescription: selectedProduct.productDescription!, selectedProduct.model!, selectedProduct.price, prodImage: selectedProduct.image!, selectedProduct.isInCart, selectedProduct.isProductLiked, specialPrice: selectedProduct.specialPrice, availability: selectedProduct.availability.description, selectedProduct.arName!, selectedProduct.arDescription!)
                        } */
                        if let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: ProductDetailViewController.selfName()) as? ProductDetailViewController {
									productDetailVc.currentProdId = selectedProduct.productId
							productDetailVc.fromScreenType = .search
                            self.navigationController?.pushViewController(productDetailVc, animated: true)
                        }
            }
        }
    }
}

extension SearchResultViewController {
    
    func getMatchingProducts(withText text: String) {
        if let fetchedProducts = Product.getAllProducts(matchingText: text) {
            self.filteredArray = fetchedProducts
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        
    }
    
	func getSearchResults(withText text: String) {
		if text != "" {
				let customerGrpId = AppManager.getCustGroupId()
				let syncFormat = text + "&customer_group_id=\(customerGrpId)"
				SyncManager.syncOperation(operationType: .onlineProductSearch, info: syncFormat) { (response, error) in
					if error == nil {
						print("Search Results: \(response)")
						self.onlineSearchResult = []
						if let searchResponse = response as? [[String: AnyObject]] {
							if searchResponse.count == 0 {
								ALAlerts.showToast(message: NSLocalizedString("NO_SEARCH_RESULT_MSG", comment: ""))
							}
							self.onlineSearchResult = searchResponse
							self.searchResultTableView.reloadData()
						}
					}
				}
			}
		}
	
    func getProductData(atIndex indexPath: IndexPath) -> ProductData {
        let product = self.onlineSearchResult[(indexPath.row)]
        let isInCart = self.checkProducIsInCart(withProdId: product["product_id"] as! String)
        let isLiked = self.checkProductIsLiked(withProdId: product["product_id"] as! String)
        let productData = ProductData(withName: product["name"] as! String, withProductId: product["product_id"] as! String, andDescription: product["description"] as! String, product["sku"] as! String, product["price"] as! String, prodImage: product["image"] as! String, isInCart, isLiked, specialPrice: product["special"] as? String ?? "", availability: product["quantity"] as! String, product["arname"] as! String, product["ardescription"] as! String)
        
        return productData
    }
    
    func checkProducIsInCart(withProdId id: String) -> Bool {
        if let _ = MyCart.getProductWith(productId: id) {
            return true
        } else {
            return false
        }
    }
    
    func checkProductIsLiked(withProdId id: String) -> Bool {
        if let _ = WishLists.getProductWith(productId: id) {
            return true
        } else {
            return false
        }
    }
}

//MARK:- Helper Methods:
extension SearchResultViewController {
    
    func keyBoardWillShow(notification: Notification) {
        if let keyBoardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
            
            self.searchResultTableView.contentInset = contentInset
            self.searchResultTableView.scrollIndicatorInsets = contentInset
        }
    }
    
    func keyBoardWillCollapse(notification: Notification) {
        self.searchResultTableView.contentInset = UIEdgeInsets.zero
        self.searchResultTableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
	
	func handleProductSpecialPrice(atCell cell: SearchResultsTableViewCell, atIndexPath indexPath: IndexPath) {
		if AppManager.currentApplicationMode() == .online {
			let currentProduct = self.onlineSearchResult[indexPath.row]
			if let specialPrice = currentProduct["special"] as? String {
				if specialPrice != "" {
					
					if let price = Double(currentProduct["price"] as? String ?? "") {
						let roundedPrice = String(format: "%.2f", price)
						let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
						attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
						attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
						cell.productSpecialPriceLabel.attributedText = attributeString
					}
					
					if let price = Double(specialPrice) {
						let roundedPrice = String(format: "%.2f", price)
						cell.productPriceLabel.text = roundedPrice + " " + "SAR"
					}
				} else {
					cell.productPriceLabel.text = ""
					if let price = Double((currentProduct["price"] as? String ?? "")) {
						let roundedPrice = String(format: "%.2f", price)
						cell.productSpecialPriceLabel.text = roundedPrice + " " + "SAR"
					}
				}
			} else {
				cell.productPriceLabel.text = ""
				if let price = Double((currentProduct["price"] as? String ?? "")) {
					let roundedPrice = String(format: "%.2f", price)
					cell.productSpecialPriceLabel.text = roundedPrice + " " + "SAR"
				}
			}
		} else {
			let currentProduct = self.filteredArray?[indexPath.row]
			if let specialPrice = currentProduct?.specialPrice {
				if specialPrice != "" {
					if let priceValue = currentProduct?.price {
						let price = Double(priceValue)
						let roundedPrice = String(format: "%.2f", price)
						let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
						attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
						attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
						cell.productSpecialPriceLabel.attributedText = attributeString
						
						if let price = Double(specialPrice) {
							let roundedPrice = String(format: "%.2f", price)
							cell.productPriceLabel.text = roundedPrice + " " + "SAR"
						}
					}
					
				} else {
					cell.productPriceLabel.text = ""
					if let priceVal = currentProduct?.price {
						let price = Double(priceVal)
						let roundedPrice = String(format: "%.2f", price)
						cell.productSpecialPriceLabel.text = roundedPrice + " " + "SAR"
					}
				}
			} else {
				cell.productPriceLabel.text = ""
				if let priceVal = currentProduct?.price {
					let price = Double(priceVal)
					let roundedPrice = String(format: "%.2f", price)
					cell.productSpecialPriceLabel.text = roundedPrice + " " + "SAR"
				}
			}
		}
	}
}
