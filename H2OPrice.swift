import Foundation

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


