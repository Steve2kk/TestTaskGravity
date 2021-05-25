//
//  ViewController.swift
//  TestTaskGravity
//
//  Created by Vsevolod Shelaiev on 25.05.2021.
//

import UIKit

class GameViewController: UIViewController {
    
    var numberOfTaps = 0
    var showRulesCounter = 0
    
    var winnerStringUrl:String?
    var looserStringUrl:String?
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 64))
        button.backgroundColor = .red
        button.setTitle("Start game", for: .normal)
        button.addTarget(self, action: #selector(handleStartGame), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if showRulesCounter < 2 {
            showRules()
        }
        setupUI()
        fetchData()
    }
    
    private func showRules() {
        let alert = UIAlertController(title: "Game rules", message: "To win you have to touch the aim 10 times faster than 7 seconds", preferredStyle: .alert)
        let rulesAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(rulesAction)
        self.present(alert, animated: true, completion: nil)
        showRulesCounter += 1
    }
    
    private func fetchData() {
        let url = URL(string: "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod")!
        let task = URLSession.shared.dataTask(with: url){ (data,response,error) in
            if let error = error {
                print("Failed to fetch data: ",error)
                return
            }
            
            guard let data = data else {
                print("Empty data")
                return
            }
            
            var result:Player?
            
            do {
                result = try JSONDecoder().decode(Player.self, from: data)
            }catch {
                print("Error: ",error)
            }
            
            guard let json = result else {
                return
            }
            
            self.winnerStringUrl = json.winner
            self.looserStringUrl = json.loser
            
        }
        task.resume()
    }
    
    private func setupUI() {
        numberOfTaps = 0
        view.backgroundColor = .green
        navigationController?.navigationBar.isHidden = true
        view.addSubview(button)
        button.isHidden = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func updatePositionOfAim() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        
        let frame = calcNextCircleFrame()
        let circleView = UIView(frame: frame)
        circleView.backgroundColor = .red
        view.addSubview(circleView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleUpdatePosition(_:)))
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 1
        circleView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func calcNextCircleFrame() -> CGRect {
        let circleSize = CGFloat(64)
        let x = CGFloat(arc4random_uniform(UInt32(self.view.frame.size.width - circleSize)))
        let y = CGFloat(arc4random_uniform(UInt32(self.view.frame.size.height - circleSize)))
        
        return CGRect(x: x, y: y, width: circleSize, height: circleSize)
    }
    
    private func moveToWebView(url: URL) {
        let webView = WebViewViewController(url: url, title: "WebView")
        let navVC = UINavigationController(rootViewController: webView)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc private func chooseWinnerOrLooser() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        if numberOfTaps >= 10 {
            guard let url = URL(string: self.winnerStringUrl!) else {return}
            moveToWebView(url: url)
        }else {
            guard let url = URL(string: self.looserStringUrl!) else {return}
            moveToWebView(url: url)
        }
    }
    
    @objc private func handleStartGame() {
        button.isHidden = true
        //Create timer
        let timer = Timer(timeInterval: 7.0,
                            target: self,
                            selector: #selector(chooseWinnerOrLooser),
                            userInfo: nil,
                            repeats: false)
          RunLoop.current.add(timer, forMode: .default)

        updatePositionOfAim()
    }
    
    @objc private func handleUpdatePosition(_ gesture: UITapGestureRecognizer) {
        numberOfTaps += 1
        updatePositionOfAim()
    }
   
}

