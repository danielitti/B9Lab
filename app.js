function displayAddress(AccountName) {
  var mySplitter = Splitter.deployed();
  var ContractAddress = mySplitter.address; 
  if (AccountName == "Contract") {
    document.getElementById(AccountName + "Address").innerHTML = ContractAddress; 
  } 
  else {
    mySplitter.getAddress.call(AccountName).then(function(result) {
       document.getElementById(AccountName + "Address").innerHTML = result;
    });
  }
};

function refreshBalance(AccountName) {
  var mySplitter = Splitter.deployed();
  var ContractAddress = mySplitter.address; 
  if (AccountName == "Contract") {
    web3.eth.getBalance(ContractAddress, function(error, result) {
      document.getElementById(AccountName + "Balance").innerHTML = result / 1000000000000000000;
    }); 
  } 
  else {
    mySplitter.getAddress.call(AccountName).then(function(resulttmp) {
      web3.eth.getBalance(resulttmp, function(error, result) {
        document.getElementById(AccountName + "Balance").innerHTML = web3.fromWei(result, "ether");
      });
    });
  } 
};

function Split(AccountName) {
  var mySplitter = Splitter.deployed();
  var amount = parseInt(document.getElementById(AccountName + "Amount").value);
  if (AccountName == "Anyone") {
    var address = document.getElementById(AccountName + "Address").value;
    web3.eth.sendTransaction({from: address, to: mySplitter.address, value: web3.toWei(amount, "ether")}); 
  }
  else {
    mySplitter.getAddress.call(AccountName).then(function(resulttmp) {
      mySplitter.split({from: resulttmp, value: web3.toWei(amount, "ether")}).then(function(trxHash) {
      }).catch(function(e) {
        console.log(e);
      });  
    });
  }
};

function refreshBalances() {
    refreshBalance('Owner');
    refreshBalance('Alice');
    refreshBalance('Bob');
    refreshBalance('Carol');
    refreshBalance('Contract');
};

window.onload = function() {
  web3.eth.getAccounts(function(err, accs) {
    if (err != null) {
      alert("There was an error fetching your accounts.");
      return;
    }

    if (accs.length == 0) {
      alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
    }

    displayAddress('Owner');
    displayAddress('Alice');
    displayAddress('Bob');
    displayAddress('Carol');
    displayAddress('Contract');
    refreshBalance('Owner');
    refreshBalance('Alice');
    refreshBalance('Bob');
    refreshBalance('Carol');
    refreshBalance('Contract');
  });
}
