import Foundation
import FoundationNetworking


struct GameResponse: Codable {
    let gameID: String

    enum CodingKeys: String, CodingKey {
        case gameID = "game_id"
    }
}

struct GuessRequest: Codable {
    let game_id: String
    let guess: String   
}

struct GuessResponse: Codable {
    let black: Int
    let white: Int
}

func startGameAPI() -> String? {
    guard let url = URL(string: "https://mastermind.darkube.app/game") else {
        print("Bad URL!")
        return nil
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let semaphore = DispatchSemaphore(value: 0)
    var gameID: String?
    var responseData: Data?
    var statusCode: Int?

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }

        if let error = error {
            print("Error sending request /game:", error)
            return
        }

        if let http = response as? HTTPURLResponse {
            statusCode = http.statusCode
            print("Received status code:", statusCode!)
        }

        responseData = data

        if let data = data {
            print("Received data:", String(data: data, encoding: .utf8) ?? "<non utf8 data>")
            if let responseObj = try? JSONDecoder().decode(GameResponse.self, from: data) {
                gameID = responseObj.gameID
            } else {
                print("Failed to decode GameResponse from data")
            }
        }
    }

    task.resume()
    semaphore.wait()
    return gameID
}


func makeGuessAPI(gameID: String, guess: [Int]) -> (black: Int, white: Int)? {
    guard let url = URL(string: "https://mastermind.darkube.app/guess") else { return nil }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Convert guess array [1,2,3,4] into "1234"
    let body = GuessRequest(game_id: gameID, guess: guess.map(String.init).joined())
    request.httpBody = try? JSONEncoder().encode(body)

    let semaphore = DispatchSemaphore(value: 0)
    var result: GuessResponse?

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }

        if let error = error {
            print("Error sending request /guess:", error)
            return
        }

        if let http = response as? HTTPURLResponse {
            print("Guess status code:", http.statusCode)
        }

        if let data = data {
            print("Guess response raw:", String(data: data, encoding: .utf8) ?? "<non utf8 data>")
            if let decoded = try? JSONDecoder().decode(GuessResponse.self, from: data) {
                result = decoded
            } else {
                print("Failed to decode GuessResponse from data")
            }
        }
    }

    task.resume()
    semaphore.wait()
    return result.map { ($0.black, $0.white) }
}



func play() {
    print("Welcome to Mastermind!")
    print("Guess the 4-digit code (digits between 1 and 6).")
    print("Enter 'exit' to quit the game.")

    guard let gameID = startGameAPI() else {
        print("Failed to start game.")
        return
    }

    while true {
        print("\nEnter your code:")
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("Invalid input. Try again.")
            continue
        }
        
        if input.lowercased() == "exit" {
            print("Goodbye!")
            break
        }

        if input.count != 4 || input.contains(where: { $0 < "1" || $0 > "6" }) {
            print("Invalid format! Enter 4 digits between 1 and 6.")
            continue
        }

        let guess = input.compactMap { Int(String($0)) }
        guard let result = makeGuessAPI(gameID: gameID, guess: guess) else {
            print("Error communicating with API.")
            continue
        }

        let feedback = String(repeating: "B", count: result.black) + String(repeating: "W", count: result.white)
        print("Result: \(feedback)")

        if result.black == 4 {
            print("Congratulations! You won!")
            break
        }
    }

}

play()
