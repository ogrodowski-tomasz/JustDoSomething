//
//  UnlockManager.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 04/05/2022.
//

import Combine
import StoreKit

/// SKPaymentTransactionObserver:  watches for purchase happening
/// SKProductsRequestDelegate: we know how to respond to a request for products

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    enum RequestState {

        /// We are about to start looking for information about products to buy, but he haven't response yet.
        case loading

        /// We have the request from Apple describing which products are avalible in sotre, ready to purchase.
        case loaded(SKProduct)

        /// Something failed
        case failed(Error?)

        /// User successfully purchased the IAP or restored the IAP
        case purchased

        /// Current user doesn't have permission to buy the product. (f.ex. underage kids)
        case deferred
    }

    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    @Published var requestState = RequestState.loading

    private let dataController: DataController
    private let request: SKProductsRequest // Fetching all products avalible for purchase
    private var loadedProducts = [SKProduct]() // storing IAPs to not fetched them all the time

    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    init(dataController: DataController) {
        self.dataController = dataController

        let productIDs = Set(["me.ogrodowski.tomasz.UltimatePortoflioApp.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        // Using super.init() so we can uself 'self'
        super.init()

        /// As soon as we can, we start watching for purchases.
        ///
        /// Let us know if any purchase or restores happened
        SKPaymentQueue.default().add(self)

        /// When finished, tell what got loaded, but only if we haven't already bought premium version.
        guard dataController.fullVersionUnlocked == false else { return }
        request.delegate = self
        request.start()
    }

    /// We should always make sure to remove 'self' from the transaction observer when app is being terminated
    ///
    /// It avoids any kind of problems when iOS thinks our app's been told by transaction when really it hasn't.
    /// If there is no observer in the transaction queue, iOS will hold on that message. When the app is launched again
    /// then to add itself.
    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)
                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }
                    queue.finishTransaction(transaction)
                case .deferred:
                    self.requestState = .deferred
                default:
                    break
                }
            }
        }
    }

    /// Called when request finishes
    ///
    /// Gets 'products app can sell'
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.loadedProducts = response.products

            /// Checking if anything was loaded into loadedProducts array
            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }

            /// Checking presence of invalid identifiers.
            ///
            /// If there is at least one object in invalidProductIdentifiers array, error occurs
            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            self.requestState = .loaded(unlock)
        }
    }

    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}
