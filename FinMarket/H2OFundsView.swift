//
//  H2OFundsView.swift
//  FinMarket
//
//  Created by patrick zagiel on 28/02/2024.
//

import SwiftUI
import Combine

class H2OFundsViewModel: ObservableObject {
    @Published var h2OPrices: [String: H2OPrice] = [:]
    private var cancellables: Set<AnyCancellable> = []

     func   subscribeAll() {
            h2OPrices.values.forEach { object in
                object.$lastprice
                    .sink { [weak self] _ in
                        self?.objectDidChange()
                    }
                    .store(in: &cancellables)
            }
        }
    func objectDidChange() {
           // Gérer ici les actions à effectuer lorsque la propriété change
           print("La propriété de l'objet Yahoo Pricea changé!")
           
           // Notifier SwiftUI du changement dans le dictionnaire
           self.objectWillChange.send()
       }
    func getAllNAV(isins: [String]) {
        for symbol in isins {
            if h2OPrices[symbol] == nil {
                let h2OPrice = H2OPrice()
                //let yahooPrice = YahooPrice()
                h2OPrices[symbol] = h2OPrice // Ajout de l'instance au dictionnaire
                h2OPrice.loadNav(isin: symbol)
            }
            else
            {
                h2OPrices[symbol]?.loadNav(isin: symbol)
            }
                
        }
    }
}



struct H2OFundsView: View {
    @StateObject var viewModel = H2OFundsViewModel()
    
    var body: some View {
        //let funds = ["H2O Vivace", "H2O Multibonds","H2O Multiequities"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Choisissez le format de date souhaité
        let funds=[["FR0011015478","H20 Vivace EUR"],["FR0012497980","H20 Vivace USD"],["FR0011061803","H20 Multistrategies"],["FR0013393329","H20 Multibonds"]]
        var fundsIsin: [String] {
               return funds.map { $0[0] }
           }
        return
        VStack(alignment: .center, spacing:0) {
                   Text("H2O Funds")
                    .font(.title)
                    .bold()  // Appliquer le gras
                    .foregroundColor(Color.blue)  // Appliquer la couleur bleu clair
                    .padding(.bottom, 10)
        List(funds, id: \.self[0]) { fund in
            if let h2OPrice = viewModel.h2OPrices[fund[0]] {
                HStack {
                        Text(fund[1]).bold()
                Spacer()
                VStack (alignment: .trailing, spacing: 3) {
                    
                        //Text(String(format: "%.3f", h2OPrice.getLastPrice().value))
                        Text(dateFormatter.string(from:h2OPrice.lastprice.date))
                       // Spacer()
                    Text(String(format: "%.3f",h2OPrice.lastprice.value)).multilineTextAlignment(.trailing)
                    Text(String(format: "%+.2f%%", h2OPrice.lastprice.evol*100)).foregroundColor(h2OPrice.lastprice.evol >= 0 ? Color.green : Color.red).multilineTextAlignment(.trailing)
                       

                        }
                }

                    }
            }
        }
            .onAppear {
            print("H2O Funds")
            viewModel.getAllNAV(isins:fundsIsin)
            viewModel.subscribeAll()
        }
            .onReceive(viewModel.$h2OPrices) { updatedPrices in
               print ("LAST NAV change")
                let numberOfElements = viewModel.h2OPrices.count
                print(numberOfElements)
            }
    
    }
}


struct H2OFundsView_Previews: PreviewProvider {
    static var previews: some View {
        H2OFundsView()
    }
}
