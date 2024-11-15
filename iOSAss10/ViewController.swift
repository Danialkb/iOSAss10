//
//  ViewController.swift
//  iOSAss10
//
//  Created by мак on 14.11.2024.
//

import UIKit

struct Hero: Decodable {
    let name: String
    let slug: String
    let biography: Biography
    let images: HeroImage
    let powerstats: PowerStats

    struct Biography: Decodable {
        let fullName: String
    }
    
    struct PowerStats: Decodable {
        let intelligence: Int
        let strength: Int
        let speed: Int
        let durability: Int
        let power: Int
        let combat: Int
    }

    struct HeroImage: Decodable {
        let sm: String
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var heroImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var slugLabel: UILabel!
    
    @IBOutlet weak var intelligenceLabel: UILabel!
    
    @IBOutlet weak var strenthLabel: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var durabilityLabel: UILabel!
    
    @IBOutlet weak var powerLabel: UILabel!
    
    @IBOutlet weak var combatLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func setRandomHero(_ sender: Any) {
        let randomId = Int.random(in: 1...563)
        fetchRandomHero(randomId)
    }
    
    func fetchRandomHero(_ id: Int) {
        let urlString = "https://akabab.github.io/superhero-api/api/id/\(id).json"
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard self.isErrorResponse(error: error) == false else {
                return
            }

            guard let data else { return }
            self.handleHeroData(data: data)
        }.resume()
    }
    
    private func handleHeroData(data: Data) {
        do {
            let hero = try JSONDecoder().decode(Hero.self, from: data)
            let heroImage = self.getImageFromUrl(string: hero.images.sm)

            DispatchQueue.main.async {
                self.heroImage.image = heroImage
                self.nameLabel.text = hero.name
                self.fullNameLabel.text = hero.biography.fullName
                self.slugLabel.text = hero.slug
                self.fillHeroStatsLabels(hero)
            }
        } catch {
            DispatchQueue.main.async {
                self.nameLabel.text = "Try Again"
                self.fullNameLabel.text = ""
                self.slugLabel.text = ""
                self.heroImage.image = UIImage(named: "notfound")
                self.fillHeroStatsLabelsForIncorrectResponse()
            }
        }
    }
    
    private func fillHeroStatsLabels(_ hero: Hero) {
        let heroStats = hero.powerstats
        intelligenceLabel.text = "Intelligence: \(heroStats.intelligence)"
        strenthLabel.text = "Strength: \(heroStats.strength)"
        speedLabel.text = "Speed: \(heroStats.speed)"
        durabilityLabel.text = "Durability: \(heroStats.durability)"
        powerLabel.text = "Power: \(heroStats.power)"
        combatLabel.text = "Combat: \(heroStats.combat)"
    }
    
    private func fillHeroStatsLabelsForIncorrectResponse() {
        intelligenceLabel.text = "Intelligence: 0"
        strenthLabel.text = "Strength: 0"
        speedLabel.text = "Speed: 0"
        durabilityLabel.text = "Durability: 0"
        powerLabel.text = "Power: 0"
        combatLabel.text = "Combat: 0"
    }

    private func getImageFromUrl(string: String) -> UIImage? {
        guard
            let heroImageURL = URL(string: string),
            let imageData = try? Data(contentsOf: heroImageURL)
        else {
            return nil
        }
        return UIImage(data: imageData)
    }

    private func isErrorResponse(error: Error?) -> Bool {
        guard let error else {
            return false
        }
        print(error.localizedDescription)
        return true
    }
    
}

