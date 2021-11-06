//
//  ViewController.swift
//  WikiFinder
//
//  Created by Владимир Тимофеев on 05.11.2021.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UIWebViewDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    let targets = ["Jeff Bezos":"https://ru.m.wikipedia.org/wiki/%D0%91%D0%B5%D0%B7%D0%BE%D1%81,_%D0%94%D0%B6%D0%B5%D1%84%D1%84", "Oxygen":"https://ru.m.wikipedia.org/wiki/%D0%9A%D0%B8%D1%81%D0%BB%D0%BE%D1%80%D0%BE%D0%B4", "Napoleon Bonaparte":"https://ru.m.wikipedia.org/wiki/%D0%9D%D0%B0%D0%BF%D0%BE%D0%BB%D0%B5%D0%BE%D0%BD_I"]
    let randomWikiPage = "https://ru.wikipedia.org/wiki/%D0%A1%D0%BB%D1%83%D0%B6%D0%B5%D0%B1%D0%BD%D0%B0%D1%8F:%D0%A1%D0%BB%D1%83%D1%87%D0%B0%D0%B9%D0%BD%D0%B0%D1%8F_%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0"
    var target = "Jeff Bezos"
    var gameStarted = false
    var count = 6
    var gamesWon = 0
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(newGameTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Games won: \(gamesWon)", style: .plain, target: self, action: nil)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        let url = URL(string: "https://ru.wikipedia.org/")
        guard let url = url else { return }
        webView.load(URLRequest(url: url))
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @objc func newGameTapped() {
        gameStarted = true
        count = 6
        navigationItem.leftBarButtonItem?.title = "Games won: \(gamesWon)"
        target = targets.randomElement()!.key
        let ac = UIAlertController(title: "Find the \(target)", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Let's start!", style: .default))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
        let url = URL(string: randomWikiPage)
        guard let url = url else { return }
        webView.load(URLRequest(url: url))
    }
    
    func startAgain(_action: UIAlertAction) {
        newGameTapped()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString == targets[target] {
            let ac = UIAlertController(title: "You won!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Start again", style: .cancel, handler: startAgain))
            present(ac, animated: true)
            gamesWon += 1
        } else if count <= 0 {
            let ac = UIAlertController(title: "You lose", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Start again", style: .cancel, handler: startAgain))
            present(ac, animated: true)
        } else {
            count -= 1
        }
        if gameStarted {
            title = "It's \(count) steps left"
        } else {
            title = "Tap to start ->"
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

}

