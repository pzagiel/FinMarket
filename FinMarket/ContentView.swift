//
//  SwiftUIView.swift
//  HelloIphone
//
//  Created by patrick zagiel on 20/04/2023.
//

import SwiftUI
import Combine

var stockPrices=[String: YahooPrice]()
struct StockPrice: Codable {
    let regularMarketPrice: Double
}

/*class StockViewModel2: ObservableObject {
    @Published var stockPrices = [String: Double]()
    
    func fetchStockPrices(symbols: [String]) {
        let symbolsString = symbols.joined(separator: ",")
        let urlString = "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com&fields=regularMarketPrice&symbols=\(symbolsString)"
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(StockResults.self, from: data)
                    DispatchQueue.main.async {
                        self.stockPrices = Dictionary(uniqueKeysWithValues: zip(symbols, result.quote.map { $0.regularMarketPrice }))
                    }
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}*/

class StockViewModel: ObservableObject {
    // ...
    @Published var yahooPrices: [String: YahooPrice] = [:]
    // ...
    private var cancellables: Set<AnyCancellable> = []

     func   subscribeAll() {
            yahooPrices.values.forEach { object in
                object.$priceValue
                    .sink { [weak self] _ in
                        self?.objectDidChange()
                    }
                    .store(in: &cancellables)
            }
        }
    func getAllPrice(symbols: [String]) {
        for symbol in symbols {
            if yahooPrices[symbol] == nil {
                let yahooPrice = YahooPrice()
                //let yahooPrice = YahooPrice()
                yahooPrices[symbol] = yahooPrice // Ajout de l'instance au dictionnaire
                yahooPrice.getPrice(ticker: symbol)
                //yahooPrice.startTimerForPriceUpdates(ticker: symbol)
            }
            else
            {
                yahooPrices[symbol]?.getPrice(ticker:symbol)
            }
                
        }
    }
    func objectDidChange() {
           // Gérer ici les actions à effectuer lorsque la propriété change
           print("La propriété de l'objet Yahoo Pricea changé!")
           
           // Notifier SwiftUI du changement dans le dictionnaire
           self.objectWillChange.send()
       }
}

struct StockResults: Codable {
    let quote: [StockPrice]
}

var currentDate: String {
       let dateFormatter = DateFormatter()
       dateFormatter.dateStyle = .medium
       return dateFormatter.string(from: Date())
   }


struct ContentView: View {
    @State private var refreshId = UUID()
    @ObservedObject var viewModel = StockViewModel()
    //@StateObject var yahooPrice=YahooPrice()
    //@ObservedObject var yahooPrice: YahooPrice = YahooPrice()
    // rajouter chat gpt
    //@State private var yahooPrices: [String: YahooPrice] = [:]
    
    let symbols = ["UBSG.SW", "INGA.AS", "PHIA.AS", "PANW","MU","CAP.PA", "ALGN","AMZN","BABA","JD","MDB","MRNA","SBUX","LOTB.BR","AIR.PA","STMPA.PA","DIM.PA","TSM","TSLA","AAPL"]
    let symbols1 = ["UBSG.SW", "INGA.AS","BABA","MDB"]
    var body: some View {
        NavigationView {
           
       /* Button("Refresh") {
                    // Action à exécuter lorsque l'utilisateur appuie sur le bouton
                    print("Le bouton a été cliqué !")
                    self.refreshId = UUID()
                } */
        List(symbols, id: \.self) { symbol in
            if let yahooPrice = viewModel.yahooPrices[symbol] {
                HStack {
                    Text(symbol)
                    Spacer()
                    Text(String(format: "%.2f", yahooPrice.priceValue))
                    Text(String(format: "%+.2f%%", yahooPrice.priceEvol)).foregroundColor(yahooPrice.priceEvol >= 0 ? Color.green : Color.red)
                    }
               } else {
                   Text("\(symbol): Loading...")
                 }
            
 
            
       /* .onAppear {
            //viewModel.fetchStockPrices(symbols: symbols)
            print("on Appear")
            getAllPrice(symbols: symbols)
        }*/
       // .id(refreshId)
    }
        .onAppear {
                    print("Refresh is called")
                    //getAllPrice2(symbols: symbols)
                    viewModel.getAllPrice(symbols: symbols)
                    viewModel.subscribeAll()
                    self.startRefreshTimer()
                   
                }
        
        
        
        .onReceive(viewModel.$yahooPrices) { updatedPrices in
           print ("Price change")
            let numberOfElements = viewModel.yahooPrices.count
            print(numberOfElements)
        }
        
        
        .navigationTitle("Stocks") // Ajoutez le titre à la barre de navigation
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                        Button("EDR") {
                        // Action à effectuer lorsque "EDR" est sélectionné dans le menu
                        print("Sélectionné EDR")
                        }
                        Button("SOX") {
                        // Action à effectuer lorsque "SOX" est sélectionné dans le menu
                        print("Sélectionné SOX")
                        }
                    } label: {
                                Image(systemName: "ellipsis.circle")
                            }
            }
                }
        }
        //.id(refreshId)
    }
       
 
    private func startRefreshTimer() {
         Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { timer in
             self.viewModel.getAllPrice(symbols: symbols)
         }
    }
        
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView().preferredColorScheme(.dark)
    }
}
