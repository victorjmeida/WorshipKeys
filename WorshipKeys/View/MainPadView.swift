//
//  MainPadView.swift
//  WorshipKeys
//
//  Created by João VIctir da Silva Almeida on 10/04/25.
//

import UIKit

class MainPadView: UIView {
    
    // MARK: - UIElements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    let padPlayingBar = UIView()
    let tonesStackView = UIStackView()
    let padScrollView = UIScrollView()
    let padStackView = UIStackView()
    let cutControlStackView = UIStackView()
    let highCutLabel = UILabel()
    let highCutSlider = UISlider()
    let lowCutLabel = UILabel()
    let lowCutSlider = UISlider()
    var toneButtons: [UIButton] = []
    var padButtons: [UIButton] = []
    let defaultPadButtonColor = UIColor(hex: "#2C2C2E")
    let defaultToneButtonColor = UIColor(hex: "#505050")
    
    //MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.background
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButtonTargets(target: Any?, toneAction: Selector, padAction: Selector) {
        for row in tonesStackView.arrangedSubviews {
            if let stack = row as? UIStackView {
                for case let button as UIButton in stack.arrangedSubviews {
                    button.addTarget(target, action: toneAction, for: .touchUpInside)
                }
            }
        }

        for container in padStackView.arrangedSubviews {
            if let stack = container as? UIStackView,
               let button = stack.arrangedSubviews.first as? UIButton {
                button.addTarget(target, action: padAction, for: .touchUpInside)
            }
        }
    }
    
    //MARK: Components
    //PLAYINGBAR
    private func setupPadPlayingBar() {
        padPlayingBar.translatesAutoresizingMaskIntoConstraints = false
        padPlayingBar.backgroundColor = UIColor(hex: "#505050")
        padPlayingBar.alpha = 1
    }

    func updatePadPlayingBarColor(for style: PadStyle?) {
        let baseColor = UIColor(hex: "#505050")
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            if let style = style {
                let styleColor = style.color
                let mixedColor = baseColor.blended(with: styleColor, fraction: 1.0)
                self.padPlayingBar.backgroundColor = mixedColor
                self.padPlayingBar.layer.shadowColor = styleColor.cgColor
                self.padPlayingBar.layer.shadowOffset = CGSize(width: 0, height: 8)
                self.padPlayingBar.layer.shadowRadius = 8
                self.padPlayingBar.layer.shadowOpacity = 0.7
            } else {
                self.padPlayingBar.backgroundColor = baseColor
                self.padPlayingBar.layer.shadowOpacity = 0
            }
        }
    }
    
    //TONES
    private func setupToneButtons() {
        tonesStackView.axis = .vertical
        tonesStackView.spacing = 8
        tonesStackView.distribution = .fillEqually

        let tones = Tone.allCases
        let tonesPerRow = 4

        for rowIndex in stride(from: 0, to: tones.count, by: tonesPerRow) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            rowStack.heightAnchor.constraint(equalToConstant: 92).isActive = true

            for column in 0..<tonesPerRow {
                let index = rowIndex + column
                guard index < tones.count else { break }
                let tone = tones[index]

                let button = createToneButton(title: tone.displayName, tag: index)
                toneButtons.append(button)
                rowStack.addArrangedSubview(button)
            }

            tonesStackView.addArrangedSubview(rowStack)
        }
    }

    private func createToneButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 34, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = defaultToneButtonColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.tag = tag
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    //Reposta visual Pads tocando
    func highlightButton(_ button: UIButton?) {
        guard let button = button else { return }
        
        UIView.animate(withDuration: 0.6) {
            button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 2, height: 2)
            button.layer.shadowRadius = 6
            button.layer.shadowOpacity = 0.2
        }
    }

    func resetToneButtonAppearance(_ button: UIButton?) {
        guard let button = button else { return }

        UIView.animate(withDuration: 0.3) {
            button.backgroundColor = self.defaultToneButtonColor
            button.setTitleColor(.white, for: .normal)
            button.layer.shadowOpacity = 0
        }
    }
    
    func resetPadButtonAppearance(_ button: UIButton?) {
        guard let button = button else { return }

        UIView.animate(withDuration: 0.3) {
            button.backgroundColor = .clear
            button.setTitleColor(.lightGray, for: .normal)
            button.layer.shadowOpacity = 0
        }
    }
    
    //STYLES
    func createPadButton(backgroundImageName: String, size: CGFloat, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)

        // Imagem de fundo personalizada
        if let backgroundImage = UIImage(named: backgroundImageName) {
            button.setBackgroundImage(backgroundImage, for: .normal)
        }

        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
        button.tag = tag

        return button
    }
    
    func setupPadButtons() {
        padScrollView.showsHorizontalScrollIndicator = false

        padStackView.axis = .horizontal
        padStackView.spacing = 16
        padStackView.alignment = .center
        padStackView.distribution = .equalSpacing

        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding: CGFloat = 24 * 2
        let spacing: CGFloat = 16 * 2
        let buttonWidth = ((screenWidth - horizontalPadding - spacing) / 3) + 16

        let backgroundImages = [
            "pad_base",
            "pad_shimmer",
            "pad_shiny",
            "pad_warm",
            "pad_reverse",
            "pad_vassal"
        ]

        for (index, style) in PadStyle.allCases.enumerated() {
            let button = createPadButton(backgroundImageName: backgroundImages[index], size: buttonWidth, tag: index)
            padButtons.append(button)

            let label = UILabel()
            label.text = style.rawValue
            label.textColor = .white
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center

            let container = UIStackView(arrangedSubviews: [button, label])
            container.axis = .vertical
            container.alignment = .center
            container.spacing = 4

            padStackView.addArrangedSubview(container)
        }
    }
    
    func createPadButton(icon: String, size: CGFloat, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: icon)
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "toneBackground") ?? .darkGray
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
        button.tag = tag
        
        return button
    }
    
    //CUTS
    func setupCutControls() {
        cutControlStackView.axis = .vertical
        cutControlStackView.spacing = 24
        cutControlStackView.translatesAutoresizingMaskIntoConstraints = false
        
        //HIGHCUT
        highCutLabel.text = "High Cut"
        highCutLabel.textColor = .white
        highCutLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        highCutSlider.minimumValue = 1000
        highCutSlider.maximumValue = 8000
        highCutSlider.value = 4500
        highCutSlider.tintColor = .lightGray
        
        //LOWCUT
        lowCutLabel.text = "Low Cut"
        lowCutLabel.textColor = .white
        lowCutLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        lowCutSlider.minimumValue = 20
        lowCutSlider.maximumValue = 600
        lowCutSlider.value = 310
        lowCutSlider.tintColor = .lightGray
        
        // Agrupar cada controle em uma stack horizontal
        let highCutStack = UIStackView(arrangedSubviews: [highCutLabel, highCutSlider])
        highCutStack.axis = .vertical
        highCutStack.spacing = 8
        
        let lowCutStack = UIStackView(arrangedSubviews: [lowCutLabel, lowCutSlider])
        lowCutStack.axis = .vertical
        lowCutStack.spacing = 8
        
        // Adiciona os dois ao stack principal
        cutControlStackView.addArrangedSubview(highCutStack)
        cutControlStackView.addArrangedSubview(lowCutStack)
    }
}
    
//MARK: Constrains e Hierarchy
extension MainPadView {
    
    // MARK: - Setup
    private func setupView() {
        setHierarchy()
        setupPadPlayingBar()
        setupToneButtons()
        setupPadButtons()
        setupCutControls()
        setConstraints()
    }
    
    // MARK: - Hierarquia
    private func setHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [padPlayingBar, tonesStackView, padScrollView, cutControlStackView].forEach {
            contentView.addSubview($0)
        }

        padScrollView.addSubview(padStackView)
    }
    
    // MARK: - Constraints
    private func setConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        tonesStackView.translatesAutoresizingMaskIntoConstraints = false
        padScrollView.translatesAutoresizingMaskIntoConstraints = false
        padStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // ScrollView ocupa toda a tela
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // ContentView dentro da ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Barra de toque
            padPlayingBar.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            padPlayingBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            padPlayingBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            padPlayingBar.heightAnchor.constraint(equalToConstant: 14),

            // Stack dos tons
            tonesStackView.topAnchor.constraint(equalTo: padPlayingBar.bottomAnchor, constant: 38),
            tonesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tonesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Scroll horizontal dos pads
            padScrollView.topAnchor.constraint(equalTo: tonesStackView.bottomAnchor, constant: 32),
            padScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            padScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            padScrollView.heightAnchor.constraint(equalToConstant: 160),

            padStackView.topAnchor.constraint(equalTo: padScrollView.topAnchor),
            padStackView.bottomAnchor.constraint(equalTo: padScrollView.bottomAnchor),
            padStackView.leadingAnchor.constraint(equalTo: padScrollView.leadingAnchor, constant: 24),
            padStackView.trailingAnchor.constraint(equalTo: padScrollView.trailingAnchor, constant: -24),
            padStackView.heightAnchor.constraint(equalTo: padScrollView.heightAnchor),

            // EQ Controls
            cutControlStackView.topAnchor.constraint(equalTo: padScrollView.bottomAnchor, constant: 32),
            cutControlStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cutControlStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            contentView.bottomAnchor.constraint(equalTo: cutControlStackView.bottomAnchor, constant: 48)
        ])
    }

}

