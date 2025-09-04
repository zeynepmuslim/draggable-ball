//
//  ViewController.swift
//  BallAnimation
//
//  Created by Zeynep Müslim on 28.08.2025.
//


import UIKit

class ViewController: UIViewController {
    
    private let menuItems = ["Test Ball", "Single Ball"]
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.text = "Developed by Zeynep Müslim"
        authorLabel.textColor = .secondaryLabel
        authorLabel.font = .systemFont(ofSize: 12, weight: .medium)
        authorLabel.textAlignment = .center
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Draggable Ball"
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let articleButton = createButton(title: "Read the Article")
        let githubButton = createButton(title: "View on GitHub")
        
        articleButton.addTarget(self, action: #selector(articleButtonTapped), for: .touchUpInside)
        githubButton.addTarget(self, action: #selector(githubButtonTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(articleButton)
        stackView.addArrangedSubview(githubButton)
        stackView.addArrangedSubview(authorLabel)
        view.addSubview(tableView)
        view.addSubview(stackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            authorLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func articleButtonTapped() {
        if let url = URL(string: "http://zeynepmuslim.blog/post.html?post=draggable-ball-eng%2Fdraggable-ball-eng.md") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func githubButtonTapped() {
        if let url = URL(string: "https://github.com/zeynepmuslim/draggable-ball") {
            UIApplication.shared.open(url)
        }
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return button
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var destinationVC: UIViewController?
        
        switch indexPath.row {
        case 0:
            destinationVC = TestDraggableVC()
        case 1:
            destinationVC = SingleBallAnimationVC()
        default:
            break
        }
        
        if let vc = destinationVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
