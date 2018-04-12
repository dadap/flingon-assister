//
//  TodayViewController.swift
//  Klingon Word of the Day
//
//  Created by Daniel Dadap on 4/9/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var definition: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBAction func buttonPressed(_ sender: Any) {
        let path = "content://org.tlhInganHol.android.klingonassistant.KlingonContentProvider/lookup/\(word.text?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        if let url = URL(string: path) {
            self.extensionContext?.open(url)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.string(forKey: "kwotd_word") != nil {
            updateText()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateText() {
        word.text = UserDefaults.standard.string(forKey: "kwotd_word")
        definition.text = "(\(UserDefaults.standard.string(forKey: "kwotd_pos") ?? "")) \(UserDefaults.standard.string(forKey: "kwotd_definition") ?? "")"
        spinner.stopAnimating()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        if let url = URL(string: "https://hol.kag.org/alexa.php?KWOTD=1") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (body : Data?, response : URLResponse?, error : Error?) -> Void in
                if (error != nil) {
                    completionHandler(NCUpdateResult.failed)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    let status = httpResponse.statusCode
                    if (status != 200) {
                        completionHandler(NCUpdateResult.failed)
                        return
                    }
                } else {
                    completionHandler(NCUpdateResult.failed)
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: body!, options: []) as! NSDictionary {
                    if (self.word.text == json["kword"] as? String) {
                        completionHandler(NCUpdateResult.noData)
                    } else {
                        if (json["kword"] as? String != nil && json["eword"] as? String != nil) {
                            UserDefaults.standard.set(json["kword"], forKey: "kwotd_word")
                            UserDefaults.standard.set(json["eword"], forKey: "kwotd_definition")
                            UserDefaults.standard.set(json["type"], forKey: "kwotd_pos")
                            self.updateText()
                            completionHandler(NCUpdateResult.newData)
                        } else {
                            completionHandler(NCUpdateResult.failed)
                        }
                    }
                    return
                }

                completionHandler(NCUpdateResult.failed)
            })
            task.resume()
        } else {
            completionHandler(NCUpdateResult.failed)
        }
    }
}
