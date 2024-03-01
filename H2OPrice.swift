import Foundation


// http://www.h2o-am.com/wp-content/themes/amarou/hs/get_json.php?isin=FR0011015478

let jsonData = """
[
    [1600992000000, 27994.39],
    [1601424000000, 28261.79],
    [1601510400000, 28108.38],
    [1601596800000, 28236.09],
    [1601856000000, 29101.46],
    [1601942400000, 30198.1],
    [1602028800000, 30242.2],
    [1602115200000, 30394.64]
]
""".data(using: .utf8)!

typealias JSONPrices = [[Double]]

struct Price {
    let date: Date
    var value: Double
    var evol: Double
}
class H2OPrice: ObservableObject{
    @Published public var lastprice: Price = Price(date: Date(), value: 0.0,evol:0.0)
    @Published public var prices: [Price] = []
    @Published public var perfYtd=0.0

    
func loadNav(isin:String) {
    let url = URL(string: "https://www.h2o-am.com/wp-content/themes/amarou/hs/get_json.php?isin="+isin)!
    print("before")
    let task = URLSession.shared.dataTask(with: url, completionHandler: getData)
    print("after")

    // Ajoutez une fonction pour calculer la performance YTD
       func calculateYTDPerformance() -> Double {
           guard let lastPrice = prices.last else {
               return 0.0 // Retourne 0 si la liste des prix est vide
           }

           let currentDate = Date()
           let calendar = Calendar.current
           let currentYear = calendar.component(.year, from: currentDate)

           // Filtrer les prix pour l'année en cours
           let pricesForCurrentYear = prices.filter {
               let year = calendar.component(.year, from: $0.date)
               return year == currentYear
           }

           // Si aucun prix n'est disponible pour l'année en cours, retourne 0
           guard let firstPriceOfYear = pricesForCurrentYear.first else {
               return 0.0
           }

           // Calculer la performance YTD
           print(lastPrice.value )
           print(firstPriceOfYear.value)
           let ytdPerformance = (lastPrice.value-firstPriceOfYear.value)/firstPriceOfYear.value
           print(ytdPerformance)
           return ytdPerformance
       }
    
    
func getData(data: Data?, response: URLResponse?, error: Error?) {
    guard let data = data else { return }
   
    do {
        let decodedData = try JSONDecoder().decode(JSONPrices.self, from: data)
            
            prices=decodedData.map {
            let date = Date(timeIntervalSince1970: $0[0] / 1000) // Convert Unix timestamp to Date
            let value = $0[1]
                return Price(date: date, value: value, evol:0)
        }
        let result=calculateYTDPerformance()
        DispatchQueue.main.async {
            self.perfYtd=result
            self.initLastPrice()
        }
    } catch let jsonError as NSError {
        print("JSON decode failed: \(jsonError.localizedDescription)")
    }
}
    
    task.resume()
}

func initLastPrice(){
    if (self.prices.count)>0 {
        self.prices[prices.count-1].evol=(prices[prices.count-1].value-prices[prices.count-2].value)/prices[prices.count-2].value
        self.lastprice=self.prices[prices.count-1];
        print(self.lastprice)
        }
    }
    
func setLastPrice()->Price? {
    if (prices.count)>0 {
        print ("LastPrice")
        return prices[prices.count-1]
    }
    else {
        return nil
    }
}
func decodeJSONPrices() {
do {
    let decodedData = try JSONDecoder().decode(JSONPrices.self, from: jsonData)
    
    let formattedData: [Price] = decodedData.map {
        let date = Date(timeIntervalSince1970: $0[0] / 1000) // Convert Unix timestamp to Date
        let value = $0[1]
        return Price(date: date, value: value,evol:0)
    }
    
} catch {
    print("Erreur de décodage : \(error)")
}
}

}

