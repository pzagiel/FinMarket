//
//  YahooPrice.swift
//  HelloIphone
//
//  Created by patrick zagiel on 18/04/2022.
//

import Foundation

class YahooPrice: ObservableObject{
   // var code: String
    //var name: String
    @Published var priceValue: Double = 0.0
    @Published var priceEvol: Double = 0.0
    var priceData:String?
    //var priceValue=0.0
    //var priceEvol=0.0
    
    
    var timer: Timer?

        func startTimerForPriceUpdates(ticker: String) {
            // Arrêter le timer existant s'il y en a un
            timer?.invalidate()

            // Créer un nouveau timer qui appelle getPrice toutes les 20 secondes
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
                // Appeler la fonction getPrice avec le paramètre ticker
                self.getPrice(ticker: ticker)
            }

            // Assurer que le timer est ajouté au mode de l'événement principal
            RunLoop.current.add(timer!, forMode: .common)
        }
    
    
    
    
    var yahooPriceResult1:YahooPriceResult?
    
    func getLastPrice()->Double {
        return (yahooPriceResult1?.chart.result[0].meta.regularMarketPrice)!
    }
    
    func getPriceEvol()->Double {
        let prevPrice=(yahooPriceResult1?.chart.result[0].meta.chartPreviousClose)!
        let lastPrice=self.getLastPrice()
        return (lastPrice-prevPrice)/prevPrice
    }
    
    func getPrice(ticker:String){
        print("Get Price call")
        let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/"+ticker+"?interval=1d&range=1d")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: getData)
        
    func getData(data: Data?, response: URLResponse?, error: Error?) {
        guard let data = data else { return }
        //  self.priceData = String(data: data, encoding: .utf8)!
      
        
        do {
            let  yahooPriceResult = try JSONDecoder().decode(YahooPriceResult.self, from: data)
            yahooPriceResult1=yahooPriceResult
            let resultMeta=yahooPriceResult.chart.result[0].meta
            let priceValue1=(yahooPriceResult1?.chart.result[0].meta.regularMarketPrice)!
            //priceValue=resultMeta.regularMarketPrice
            //let prevPrice=resultMeta.chartPreviousClose
            //priceEvol=((priceValue-prevPrice)/prevPrice)*100
            
            // Sleep tometime to analyse and debug
            //let randomDelay = Int.random(in: 3...10)
            //sleep(UInt32(randomDelay))
            
            
            // Ensure synchro with main thread -change nothing it seems
            DispatchQueue.main.async {
                        
                        print("Get Data from request")
                           // Mettre à jour les propriétés sur la file principale
                           self.priceValue = resultMeta.regularMarketPrice
                           let prevPrice = resultMeta.chartPreviousClose
                           self.priceEvol = ((priceValue1 - prevPrice) / prevPrice) * 100
                           print(ticker + ":" + String(self.priceValue))
                           self.objectWillChange.send()
                           
                       }
            
            
        } catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
        }
    }
    task.resume()
    }
    
}
