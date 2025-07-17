import Foundation

func startGame() -> [Int] {
    return (0..<4).map { _ in Int.random(in: 1...6) }
}

func findResult(code: [Int], guess: [Int]) -> (black: Int, white: Int) {
    var b = 0
    var w = 0
    var codeCopy = code
    var guessCopy = guess

    for i in 0..<4 {
        if guessCopy[i] == codeCopy[i] {
            b += 1
            codeCopy[i] = -1
            guessCopy[i] = -2
        }
    }

    for i in 0..<4 {
        if let j = codeCopy.firstIndex(of: guessCopy[i]), guessCopy[i] > 0 {
            w += 1
            codeCopy[j] = -1
            guessCopy[i] = -2
        }
    }

    return (b, w)
}

func play() {
    print("Welcome to Mastermind!")
    print("Guess the 4-digit code (digits between 1 and 6).")
    print("Enter 'exit' to quit the game.")

    let code = startGame()

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
        let result = findResult(code: code, guess: guess)

        let feedback = String(repeating: "B", count: result.black) + String(repeating: "W", count: result.white)
        print("Result: \(feedback)")

        if result.black == 4 {
            print("Congratulations! You won!")
            break
        }
    }

    print("The secret code was: \(code.map(String.init).joined())")
}

play()
