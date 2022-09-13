//
//  ViewController.swift
//  ColorGene
//
//  Created by Hai Le on 13/09/2022.
//

import UIKit

class ViewController: UIViewController {
    private let splitChar: Character = "@"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "data.json", withExtension: nil)!
        let text = try! String(contentsOf: url)
        
        let decode = JSONDecoder()
        let data = try! decode.decode([Color].self, from: text.data(using: .utf8)!)
        
        guard let saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        for color in data {
            var newFolderColor = saveURL.appendingPathComponent("\(color.name).colorset")
            if color.name.contains("\(splitChar)light") {
                newFolderColor = saveURL.appendingPathComponent("\(color.name.split(separator: splitChar).first!).colorset")
            }
            if color.name.contains("\(splitChar)dark") {
                continue
            }
            
            try? FileManager.default.createDirectory(at: newFolderColor, withIntermediateDirectories: true, attributes: nil)
            
            let obj = color.color.filter { c in
                return (c <= "9" && c >= "0") || c == "," || c == "."
            }.split(separator: ",")
            var json = """
            {
              "colors" : [
                {
                  "color" : {
                    "color-space" : "srgb",
                    "components" : {
                      "alpha" : "\(Double(obj[3])!)",
                      "blue" : "\(Double(obj[2])! / 255.0)",
                      "green" : "\(Double(obj[1])! / 255.0)",
                      "red" : "\(Double(obj[0])! / 255.0)"
                    }
                  },
                  "idiom" : "universal"
                }
              ],
              "info" : {
                "author" : "xcode",
                "version" : 1
              }
            }
            """
            
            if color.name.contains("\(splitChar)light") {
                guard let c = data.filter ({ c in
                    return c.name.contains(color.name.split(separator: splitChar).first!) && c.name.contains("\(splitChar)dark")
                }).first else {
                    print("no dark found")
                    return
                }
                let obj_dark = c.color.filter { c in
                    return (c <= "9" && c >= "0") || c == "," || c == "."
                }.split(separator: ",")
                json = """
                {
                  "colors" : [
                    {
                      "color" : {
                        "color-space" : "srgb",
                        "components" : {
                            "alpha" : "\(Double(obj[3])!)",
                            "blue" : "\(Double(obj[2])! / 255.0)",
                            "green" : "\(Double(obj[1])! / 255.0)",
                            "red" : "\(Double(obj[0])! / 255.0)"
                        }
                      },
                      "idiom" : "universal"
                    },
                    {
                      "appearances" : [
                        {
                          "appearance" : "luminosity",
                          "value" : "dark"
                        }
                      ],
                      "color" : {
                        "color-space" : "srgb",
                        "components" : {
                          "alpha" : "\(Double(obj_dark[3])!)",
                          "blue" : "\(Double(obj_dark[2])! / 255.0)",
                          "green" : "\(Double(obj_dark[1])! / 255.0)",
                          "red" : "\(Double(obj_dark[0])! / 255.0)"
                        }
                      },
                      "idiom" : "universal"
                    }
                  ],
                  "info" : {
                    "author" : "xcode",
                    "version" : 1
                  }
                }
                """
            }
            
            let pathWithFilename = newFolderColor.appendingPathComponent("Contents.json")
            do {
                try json.write(to: pathWithFilename,
                                     atomically: true,
                                     encoding: .utf8)
            } catch {
                // Handle error
                print("nope")
            }
        }
        var a = saveURL.path
        a.removeFirst()
        print("Go to folder: \(a)")
    }
}
struct Color: Codable {
    var name: String
    var description: String
    var color: String
}

