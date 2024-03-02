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
    // Apparement State est nécessaire pour pouvoir réordonner les element de la liste !
    @State var funds=[["FR0011015478","H20 Vivace EUR"],["FR0012497980","H20 Vivace USD"],["FR0011061803","H20 Multistrategies"],["FR0013393329","H20 Multibonds"],["FR0011008762","H2O Multiequities"]]
    //let funds = ["H2O Vivace", "H2O Multibonds","H2O Multiequities"]
    var body: some View {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Choisissez le format de date souhaité
       
     /*   var fundsIsin: [String] {
               return funds.map { $0[0] }
           } */
        
        return
        List {
           // List(funds, id: \.self[0]) { fund in
            ForEach(funds, id: \.self[0]) { fund in
            //let fund = funds[index] plus utile
            if let h2OPrice = viewModel.h2OPrices[fund[0]] {
                HStack {
                    VStack(alignment: .leading){
                    // More like H20 Color
                    Text(fund[1]).bold().foregroundColor(Color(red: 0.439, green: 0.647, blue: 0.839))
                    //Text(fund[1]).bold().foregroundColor(Color(red: 0.5, green: 0.7, blue: 1.0))
                    Spacer()
                    Text(dateFormatter.string(from:h2OPrice.lastprice.date))
                            .font(.system(size: 12)) // Ajuster la taille de la police selon vos préférences
                            .foregroundColor(Color.gray)
                    // Je ne comprends pas pourquoi il faut alignment: .topLeading a la fois sur le frame est sur le stack
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).border(Color.black, width: 0)
                  /*  VStack {
                        Text(dateFormatter.string(from:h2OPrice.lastprice.date))
                        .font(.system(size: 12)) // Ajuster la taille de la police selon vos préférences
                        .foregroundColor(Color.gray)
                    }.frame(maxHeight: .infinity, alignment: .bottomLeading ).border(Color.black, width: 2)*/
                VStack (alignment: .trailing, spacing: 3) {
                        Text(String(format: "%+.2f%%", h2OPrice.lastprice.evol*100)).foregroundColor(h2OPrice.lastprice.evol >= 0 ? Color.green : Color.red).multilineTextAlignment(.trailing)
                        Text(String(format: "%.2f",h2OPrice.lastprice.value)).multilineTextAlignment(.trailing)
                    Text(String(format: "%+.2f%%", h2OPrice.perfYtd*100 )).foregroundColor(h2OPrice.perfYtd >= 0 ? Color.green : Color.red).multilineTextAlignment(.trailing)
                }.border(Color.black, width: 0)
                        //Text(String(format: "%.3f", h2OPrice.getLastPrice().value))
                       
                       // Spacer()
                }
                
                }
            }
            // .onMove(perform: move)
            .onMove { indices, newOffset in
                     funds.move(fromOffsets: IndexSet(indices), toOffset: newOffset)
                 }
        }
            .navigationTitle("H2O Funds")
            .navigationBarItems(trailing: EditButton())
            /*.toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                EditButton()
                            }
                        }*/
            
            .onAppear {
                print("H2O Funds")
                let fundsIsin = funds.map { $0[0] }
                viewModel.getAllNAV(isins:fundsIsin)
                viewModel.subscribeAll()
            }
       /*     .onReceive(viewModel.$h2OPrices) { updatedPrices in
               print ("LAST NAV change")
                let numberOfElements = viewModel.h2OPrices.count
                print(numberOfElements)
            }*/
    }
/*    mutating func move(from source: IndexSet, to destination: Int) {
          funds.move(fromOffsets: source, toOffset: destination)
      }*/
    
}


struct H2OFundsView_Previews: PreviewProvider {
    static var previews: some View {
        H2OFundsView()
    }
}
