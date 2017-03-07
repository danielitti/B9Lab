pragma solidity ^0.4.0;

contract ShopFront {
    
    address private pOwner; 
    address public merchantAddress;
    address public customerAddress;

    struct Product {
        uint productId;
        bool isAvailable;
        bytes32 name;
        uint stock;
        uint price;
     } 

    struct ProductPurchased {
        address seller;
        bytes32 sellerName;
        uint productId;
        bytes32 name;
        uint quantity;
        uint totalPrice;
     } 

    struct Merchant {
           bool isActive;
           bytes32 name;
           Product[] inventory;
     } 

    struct Customer {
           bool isActive;
           bytes32 name;
           ProductPurchased[] shopping;
     } 

    mapping(address => Merchant) public merchants;
    mapping(address => Customer) public customers;

    function ShopFront() payable {
            pOwner = msg.sender;
    }

// modifiers

    modifier isOwner() {
        if (pOwner != msg.sender) {
                throw;
        }
        _;
    }
 
    modifier isMerchant() {
        merchantAddress = msg.sender;
        if (!merchants[merchantAddress].isActive) {
                throw;
        }
        _;
    }

    modifier isCustomer() {
        customerAddress = msg.sender;
        if (!customers[customerAddress].isActive) {
                throw;
        }
        _;
    }

    modifier isProductAvailable(address parMerchantAddress, uint parId) {
            merchantAddress = parMerchantAddress;
            if (!merchants[parMerchantAddress].inventory[parId].isAvailable) {
                throw;
            }
            _;
        }        

    modifier isProductInStock(address parMerchantAddress, uint parId, uint parQuantity) {
            merchantAddress = parMerchantAddress;
            if (parQuantity > merchants[parMerchantAddress].inventory[parId].stock) {
                throw;
            }
            _;
        }        

    modifier isTotalPriceCorrect(address parMerchantAddress, uint parId, uint parQuantity, uint parTotalPrice) {
            merchantAddress = parMerchantAddress;
            if (parTotalPrice != (merchants[parMerchantAddress].inventory[parId].price * parQuantity)) {
                throw;
            }
            _;
        }        
        
// Owner code

    function addMerchant(address parMerchantAddress, bytes32 parMerchantName) 
        isOwner() {
            merchantAddress = parMerchantAddress;
            merchants[merchantAddress].isActive = true;
            merchants[merchantAddress].name =  parMerchantName;    
    }

    function addCustomer(address parCustomerAddress, bytes32 parCustomerName) 
        isOwner() {
            customerAddress = parCustomerAddress;
            customers[customerAddress].isActive = true;
            customers[customerAddress].name =  parCustomerName;    
    }
     
    function isMerchantActive(address parMerchantAddress) constant returns (bool) {
        return (merchants[parMerchantAddress].isActive);
    }   

    function getMerchantName(address parMerchantAddress) constant returns (bytes32) {
        return (merchants[parMerchantAddress].name);
    }   

    function isCustomerActive(address parCustomerAddress) constant returns (bool) {
        return (customers[parCustomerAddress].isActive);
    }   

    function getCustomerName(address parCustomerAddress) constant returns (bytes32) {
        return (customers[parCustomerAddress].name);
    }   

    function withdrawn(uint parAmount) 
        isOwner() {
            if (this.balance > parAmount && parAmount > 0) {
                if (!pOwner.send(parAmount)) throw;
            }
     }

// Merchant code

    function addProduct(uint parId, bool parIsAvailable, bytes32 parName, uint parStock, uint parPrice) 
        isMerchant() {
            merchantAddress = msg.sender;
            merchants[merchantAddress].inventory.push(Product({
                            productId: parId,
                            isAvailable: parIsAvailable,
                            name: parName,
                            stock: parStock,
                            price: parPrice
                        }));
    }

    function getProduct(uint parId)  
        isMerchant() 
        constant returns (uint id, bool isAvailable, bytes32 name, uint stock, uint price){
            merchantAddress = msg.sender;
            Product p = merchants[merchantAddress].inventory[parId];
            return (p.productId, p.isAvailable, p.name, p.stock, p.price);
    }   

    function updateAvailability(uint parId, bool parIsAvailable) 
        isMerchant() {
            merchantAddress = msg.sender;
            merchants[merchantAddress].inventory[parId].isAvailable = parIsAvailable;
    }
    
    function updatePrice(uint parId, uint parPrice) 
        isMerchant() {
            merchantAddress = msg.sender;
            merchants[merchantAddress].inventory[parId].price = parPrice;
    }


    function updateStock(uint parId, uint parStock) 
        isMerchant() {
            merchantAddress = msg.sender;
            merchants[merchantAddress].inventory[parId].stock = parStock;
    }

// Customer code


    function isBuyingProductAllowed(address parMerchantAddress, uint parId, uint parQuantity, uint MsgValue) 
        isProductAvailable(parMerchantAddress, parId)
        isProductInStock(parMerchantAddress, parId, parQuantity)
        isTotalPriceCorrect(parMerchantAddress, parId, parQuantity, MsgValue) {

    }
        

    function buyProduct(address parMerchantAddress, uint parId, uint parQuantity)
        isCustomer() 
        payable {
            isBuyingProductAllowed(parMerchantAddress, parId, parQuantity, msg.value);

            merchantAddress = parMerchantAddress;
            customerAddress = msg.sender;
            merchants[parMerchantAddress].inventory[parId].stock -= parQuantity; 

            customers[customerAddress].shopping.push(ProductPurchased({
                seller: merchantAddress,
                sellerName: merchants[parMerchantAddress].name,
                productId: parId,
                name: merchants[parMerchantAddress].inventory[parId].name,
                quantity: parQuantity,
                totalPrice: msg.value
            }));

    }

    function getProductPurchased(uint parId)  
        isCustomer() 
        constant returns (address parSellerAddress, bytes32 parSellerName, uint productId, bytes32 productName, uint quantity, uint totalPrice){
            customerAddress = msg.sender;
            ProductPurchased pp = customers[customerAddress].shopping[parId];
            return (pp.seller, pp.sellerName, pp.productId, pp.name, pp.quantity, pp.totalPrice);
    }   


// default checks
    function getN() constant returns (uint) {
         return 36;
    }

}