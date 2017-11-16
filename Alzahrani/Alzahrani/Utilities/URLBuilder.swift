//
//  URLBuilder.swift
//  Alzahrani
//
//  Created by Hardwin on 05/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class URLBuilder: NSObject {

    class func baseUrl() -> String {
        return "https://alzahrani-online.com/index.php?route="
    }
   
    class func serviceAPIURL() -> String {
        return baseUrl() + "api/customer/"
    }
}

//MARK:- Service API Url:
extension URLBuilder {
	
	class func payfortTokenGeneration() -> String {
		return serviceAPIURL() + "generateSdkToken"
	}
    
    class func payFortTokenUrl() -> String {
        return "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
    }
    
    class func getUserRegisterURL() -> String {
        return serviceAPIURL() + "register"
    }
    
    class func getImageDownloadBaseURL() -> String {
        return "https://alzahrani-online.com/image/"
    }
    
    class func getLoginURL() -> String {
        return serviceAPIURL() + "login"
    }
    
    class func getForgotPasswordURL() -> String {
        return serviceAPIURL() + "forgotPassword"
    }
    
    class func getCountriesListURL() -> String {
        return serviceAPIURL() + "country"
    }
    
    class func getCitiesListURL() -> String {
        return serviceAPIURL() + "city&country_id="
    }
    
    class func getAddAddressURL() -> String {
        return serviceAPIURL() + "addAddressList"
    }
    
    class func getPlaceOrderURL() -> String {
        return serviceAPIURL() + "placeOrder"
    }
    
    class func aramexShippingURL() -> String {
        return serviceAPIURL() + "getAramexValue"
    }
   
    class func getCitiesBasedOnZoneId() -> String {
        return serviceAPIURL() + "getCity&zone_id="
    }
    
    class func getPolicyData() -> String {
        return serviceAPIURL() + "getInformations"
    }
	
	class func getMyProfileData() -> String {
		return serviceAPIURL() + "getmyProfile&customer_id="
	}
}

//MARK:- Products:
extension URLBuilder {
    
    
    class func getHomeScreenDataURL()-> String{
        return serviceAPIURL() + "getHomeScreenData"
    }
    class func getProductURL()-> String{
        return serviceAPIURL() + "getProductDetails"
    }
    class func getProductsFromBrandNameURL()-> String{
        return serviceAPIURL() + "getProductsFromBrandName"
    }
    
    class func getProductsListURL() -> String {
        return serviceAPIURL() + "EnglishCategories&language_id="
    }
    
    class func getProductSubcategoriesURL() -> String {
        return serviceAPIURL() + "EnglishSubCategories&category_id="
    }

    class func getNewArrivatURL() -> String {
        return serviceAPIURL() + "newArrivals&customer_group_id="
    }
    
    class func getBrandsURL() -> String {
        return serviceAPIURL() + "getBrands"
    }
    
    class func getBannerImagesURL() -> String {
        return serviceAPIURL() + "getBanners"
    }
    
    class func getTopSellingProductsURL() -> String {
        return serviceAPIURL() + "mostSellerProducts&customer_group_id="
    }
    
    class func getProductsBasedOnCategory() -> String {
        return serviceAPIURL() + "getALLProductsInEnglish&category_id="
    }
    
    class func getSliderImages() -> String {
        return serviceAPIURL() + "getSliders"
    }
    
    class func getProductSpecificationsURL() -> String {
        return serviceAPIURL() + "getProductsSpecifications"
    }
    
    class func getBrandsBasedOnCategory() -> String {
        return serviceAPIURL() + "getBrandsbtCategoryid&category_id="
    }
    
    class func getUserExistingAddressURL() -> String {
        return serviceAPIURL() + "getAddressBookList&customer_id="
    }
    
    class func getShippingChargesURL() -> String {
        return serviceAPIURL() + "getPrices&delivery_type="
    }
    
    class func getBankDetailsURL() -> String {
        return serviceAPIURL() + "getBanksDet"
    }
    
    class func getCouponCodeURL() -> String {
        return serviceAPIURL() + "applyCoupon"
    }
    
    class func writeReviewsURL() -> String {
        return serviceAPIURL() + "writeReview"
    }
    
    class func getFinalPriceURL() -> String {
        return serviceAPIURL() + "finalPriceInCheckout"
    }
	
	class func downloadAllProductsData() -> String {
		return serviceAPIURL() + "listALLProducts"
	}
}

//MARK:- WishList Data:
extension URLBuilder {
    class func getAllWishLists() -> String {
        return serviceAPIURL() + "getWishlistInEnglish"
    }
    
    class func getWishListArabic() -> String {
        return serviceAPIURL() + "getWishlistInArabic"
    }
    
    class func getAllMyCartLists() -> String {
        return serviceAPIURL() + "getCartDetails"
    }
}

//MARK:- Upload Tasks
extension URLBuilder {
    class func getwishListUploadURL() -> String {
        return serviceAPIURL() + "AddToWishlist"
    }
    
    class func getWishListDeleteURL() -> String {
        return serviceAPIURL() + "deleteWishlistItems"
    }
    
    class func getMyCartUploadURL() -> String {
        return serviceAPIURL() + "addCart"
    }
    
    class func getMyCartDeleteURL() -> String {
        return serviceAPIURL() + "removeFromCart"
    }
}

//MARK:- Search
extension URLBuilder {
    
    class func getSearchProductURL() -> String {
        return serviceAPIURL() + "searchProduct&search="
    }
}

//MARK:- Payment Gateway:
extension URLBuilder {
    
    class func getPaymentGatewayURL() -> String {
        return "https://checkout.payfort.com/FortAPI/paymentPage"
    }
}
