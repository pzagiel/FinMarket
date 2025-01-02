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

    
    
    func calculateYTDPerformance1() -> Double {
            guard let lastPrice = prices.last else {
                return 0.0 // Retourne 0 si la liste des prix est vide
            }
           // let currentDate = Date()
        let calendar = Calendar.current
        var currentYear: Int=0
        // For determining the current year take the year of last NAV in place of the current date
        // wich doesn't work for the last day of the year
        if let currentDate = prices.last?.date {
            currentYear = calendar.component(.year, from: currentDate)
        } else {
            currentYear = 0
        }

        if currentYear != 0  {
            print("L'année courante est \(currentYear)")
        } else {
            print("Aucune année disponible")
        }


        
          //  var currentDate=prices.last?.date
          //  let calendar = Calendar.current
          //  let currentYear = calendar.component(.year, from: currentDate)

            // Filtrer les prix pour l'année précédente
            let pricesForPreviousYear = prices.filter {
                let year = calendar.component(.year, from: $0.date)
                return year == currentYear - 1
            }

            // Si aucun prix n'est disponible pour l'année précédente, retourne 0
            guard let firstPriceOfPreviousYear = pricesForPreviousYear.last else {
                return 0.0
            }

            // Calculer la performance YTD
            let ytdPerformance = (lastPrice.value / firstPriceOfPreviousYear.value - 1.0)

            return ytdPerformance
        }
 
   

  

    func csvToJSON(data: Data) -> Data? {
        // Convertit les données en une chaîne de caractères UTF-8
        guard let csvString = String(data: data, encoding: .utf8) else {
            print("Impossible de convertir les données en chaîne de caractères UTF-8")
            return nil
        }
        print(csvString)
        // Divise les lignes du CSV en un tableau de chaînes de caractères
        let lines = csvString.components(separatedBy: .newlines)
        
        var jsonArray = [[Any]]()
        
        // Parcourt chaque ligne du CSV à partir de la deuxième ligne (pour ignorer l'en-tête)
        for line in lines.dropFirst() {
            // Divise chaque ligne en colonnes
            let columns = line.components(separatedBy: "\t")
            
            // Si la ligne a exactement deux colonnes
            if columns.count == 2 {
                // Convertit la date en millisecondes depuis 1970
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: columns[0]) {
                    let milliseconds = Int(date.timeIntervalSince1970 * 1000)
                    let navValue = Double(columns[1].replacingOccurrences(of: ",", with: "."))
                    // Crée un tableau avec la date en millisecondes et la valeur NAV
                    let rowData: [Any] = [milliseconds,navValue]
                    
                    // Ajoute le tableau au tableau JSON
                    jsonArray.append(rowData)
                }
            }
        }
        
        do {
            // Convertit le tableau JSON en données JSON
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            
            // Convertit les données JSON en chaîne de caractères
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            return jsonData
            //}
        } catch {
            print("Erreur de conversion en JSON : \(error)")
        }
        
        return nil
    }

 

 
func loadNav(isin:String) {
    //https://www.h2o-am.com/wp-content/plugins/sand360/sand360.get_xls.php?type=xls&key=FR0011015478
    let url = URL(string: "https://www.h2o-am.com/wp-content/plugins/sand360/sand360.get_xls.php?type=xls&key="+isin)!
    print("before")
    print(url)
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
    print(data)
    let jsonData=csvToJSON(data: data)
    guard let jsonData = jsonData else {
        // Gérer le cas où jsonData est nil
        print("Les données JSON sont nil.")
        return // Ou tout autre action appropriée
    }
    do {
        let decodedData = try JSONDecoder().decode(JSONPrices.self, from: jsonData)
            
            prices=decodedData.map {
            let date = Date(timeIntervalSince1970: $0[0] / 1000) // Convert Unix timestamp to Date
            let value = $0[1]
                return Price(date: date, value: value, evol:0)
        }
        let result=calculateYTDPerformance1()
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

