//
//  DarkRoomPlayerControlView.swift
//
//
//  Created by Kiarash Vosough on 7/8/22.
//
//  Copyright (c) 2022 Divar
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Combine

// MARK: - Delegate

internal protocol DarkRoomPlayerControlViewDelegate: AnyObject {
    func controlView(_ view: DarkRoomPlayerControlView, didTouchUpInside button: UIButton)
}

internal protocol DarkRoomPlayerControlViewPublishers: AnyObject {
    var didPlayPauseButtonDidTouchUpInside: AnyPublisher<Void,Never> { get }
}

// MARK: - Implementation

internal final class DarkRoomPlayerControlView: UIView, DarkRoomPlayerControlViewPublishers, DarkRoomFailureRepresentableView {
    
    private var didPlayPauseButtonDidTouchUpInsideSubject: PassthroughSubject<Void,Never> = .init()
    
    internal var didPlayPauseButtonDidTouchUpInside: AnyPublisher<Void,Never> {
        didPlayPauseButtonDidTouchUpInsideSubject.share().eraseToAnyPublisher()
    }
    
    private var didMuteButtonDidTouchUpInsideSubject: PassthroughSubject<Void,Never> = .init()
    
    internal var didMuteButtonDidTouchUpInside: AnyPublisher<Void,Never> {
        didMuteButtonDidTouchUpInsideSubject.share().eraseToAnyPublisher()
    }
    
    // MARK: - Views
    
    private let stackview = UIStackView()
    
    private let controlButton = UIButton()
    
    private let muteButton = UIButton()
    
    internal private(set) lazy var slider: DarkRoomPlayerSliderView = DarkRoomPlayerSliderView(configuration: configuration.progressViewConfiguration)
    
    private let timeStatusLabel = UILabel()
    
    // MARK: - Setters & Getters
    
    internal weak var delegate: DarkRoomPlayerControlViewDelegate?
    
    internal var buttonImage: UIImage? {
        get {
            controlButton.image(for: .normal)
        } set {
            controlButton.setImage(newValue, for: .normal)
        }
    }
    
    internal var audioImage: UIImage? {
        get {
            muteButton.image(for: .normal)
        } set {
            muteButton.setImage(newValue, for: .normal)
        }
    }
    
    internal var timeLabelText: String? {
        get {
            timeStatusLabel.text
        } set {
            timeStatusLabel.text = newValue
        }
    }
    
    internal var isSlidingEnabled: Bool {
        get {
            slider.isSlidingEnabled
        } set {
            slider.isSlidingEnabled = newValue
        }
    }

    // MARK: - Inputs
    
    private var configuration: DarkRoomControlViewConfiguration
    
    // MARK: - LifeCycle
    
    internal init(configuration: DarkRoomControlViewConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        prepare()
    }

    internal required init?(coder: NSCoder) {
        self.configuration = DarkRoomControlViewDefaultConfiguration()
        super.init(coder: coder)
        prepare()
    }
    
    private func prepare() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.semanticContentAttribute = .forceLeftToRight
        prepareBackgroundView()
        prepareControlButton()
        prepareStackView()
        prepareSlider()
        guard configuration.useMute else {
            prepareTimeLabel()
            return
        }
        prepareMuteButton()
    }
    
    private func prepareBackgroundView() {
        let darkBackground = UIView()
        darkBackground.translatesAutoresizingMaskIntoConstraints = false
        darkBackground.backgroundColor = .black
        darkBackground.alpha = 0.6
        addSubview(darkBackground)
        
        NSLayoutConstraint.activate([
            darkBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            darkBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            darkBackground.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            darkBackground.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }

    private func prepareControlButton() {
        controlButton.setImage(configuration.playImage, for: .normal)
        controlButton.translatesAutoresizingMaskIntoConstraints = false
        controlButton.contentHorizontalAlignment = .fill
        controlButton.contentVerticalAlignment = .fill
        controlButton.imageView?.contentMode = .scaleAspectFit
        controlButton.addTarget(self, action: #selector(playButtonTapped), for: .primaryActionTriggered)
        controlButton.semanticContentAttribute = .forceLeftToRight
        self.addSubview(controlButton)

        NSLayoutConstraint.activate([
            controlButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            controlButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            controlButton.heightAnchor.constraint(equalToConstant: 35),
            controlButton.widthAnchor.constraint(equalTo: controlButton.heightAnchor)
        ])
    }

    private func prepareStackView() {
        stackview.semanticContentAttribute = .forceLeftToRight
        stackview.spacing = 16
        stackview.alignment = .fill
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackview)
        
        NSLayoutConstraint.activate([
            stackview.leadingAnchor.constraint(equalTo: controlButton.trailingAnchor, constant: 8),
            stackview.topAnchor.constraint(equalTo: topAnchor),
            stackview.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackview.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func prepareSlider() {
        slider.translatesAutoresizingMaskIntoConstraints = false
        stackview.addArrangedSubview(slider)
    }
    
    private func prepareMuteButton() {
        muteButtonToUnmute()
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        muteButton.contentHorizontalAlignment = .fill
        muteButton.contentVerticalAlignment = .fill
        muteButton.imageView?.contentMode = .scaleAspectFit
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .primaryActionTriggered)
       
        stackview.addArrangedSubview(muteButton)

        NSLayoutConstraint.activate([
            muteButton.heightAnchor.constraint(equalToConstant: 36),
            muteButton.widthAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func muteButtonToMute() {
        muteButton.setImage(configuration.muteAudioImage, for: .normal)
    }
    
    func muteButtonToUnmute() {
        muteButton.setImage(configuration.unmuteAudioImage, for: .normal)
    }
    
    private func prepareTimeLabel() {
        timeStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        timeStatusLabel.textAlignment = .center
        timeStatusLabel.numberOfLines = 1
        timeStatusLabel.textColor = configuration.timeStatusConfiguration.timeStatusLabelTextColor
        timeStatusLabel.font = configuration.timeStatusConfiguration.timeStatusLabelFont
        timeStatusLabel.text = configuration.timeStatusConfiguration.initialText
        
        stackview.addArrangedSubview(timeStatusLabel)
        
        NSLayoutConstraint.activate([
            timeStatusLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/6),
        ])
    }

    func updateView(shouldRepresentError: Bool) {
        slider.updateView(shouldRepresentError: shouldRepresentError)
        if shouldRepresentError {
            timeStatusLabel.textColor = configuration.errorColor
        } else {
            timeStatusLabel.textColor = .white
        }
    }

    @objc
    fileprivate func playButtonTapped(_ button: UIButton) {
        delegate?.controlView(self, didTouchUpInside: button)
        didPlayPauseButtonDidTouchUpInsideSubject.send()
    }
    
    @objc
    fileprivate func muteButtonTapped(_ button: UIButton) {
        delegate?.controlView(self, didTouchUpInside: button)
        didMuteButtonDidTouchUpInsideSubject.send()
    }
}
