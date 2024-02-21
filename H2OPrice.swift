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
    let value: Double
}
class H2OPrice: ObservableObject{

public var prices: [Price] = []

    
func getNav() {
    let url = URL(string: "https://www.h2o-am.com/wp-content/themes/amarou/hs/get_json.php?isin=FR0011015478")!
    print("before")
    let task = URLSession.shared.dataTask(with: url, completionHandler: getData)
    print("after")

    
func getData(data: Data?, response: URLResponse?, error: Error?) {
    guard let data = data else { return }
   
    do {
        let decodedData = try JSONDecoder().decode(JSONPrices.self, from: data)
        
            prices=decodedData.map {
            let date = Date(timeIntervalSince1970: $0[0] / 1000) // Convert Unix timestamp to Date
            let value = $0[1]
            return Price(date: date, value: value)
        }
    } catch let jsonError as NSError {
        print("JSON decode failed: \(jsonError.localizedDescription)")
    }
}
    task.resume()
}

func decodeJSONPrices() {
do {
    let decodedData = try JSONDecoder().decode(JSONPrices.self, from: jsonData)
    
    let formattedData: [Price] = decodedData.map {
        let date = Date(timeIntervalSince1970: $0[0] / 1000) // Convert Unix timestamp to Date
        let value = $0[1]
        return Price(date: date, value: value)
    }
    
    print(formattedData)
} catch {
    print("Erreur de décodage : \(error)")
}
}

}

