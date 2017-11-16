//
//  VoiceSearchWindowViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 31/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Speech
//import NVActivityIndicatorView

protocol SearchCompletionDelegate: NSObjectProtocol {
    
    func didTapDoneButton(withResultText text: String)
    func exitFormVoiceSearch()
}

class VoiceSearchWindowViewController: UIViewController {

    
    @IBOutlet weak var progressIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var voiceActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pleaseWaitLabel: UILabel!
    @IBOutlet weak var voiceSearchHeadingLabel: UILabel!
    @IBOutlet weak var voiceSearchResultLabel: UILabel!
    
    //MARK:- Audio-Recognizers Properties:
    fileprivate var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    fileprivate let audioEngine = AVAudioEngine()
    
    weak var delegate: SearchCompletionDelegate?
    let WELCOME_TEXT = "Say something, I'm listening!"
    let ERROR_TEXT = "Please try again..!"
    var searchResultString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGesture()
//        self.voiceActivityIndicator.startAnimating()
        self.progressIndicatorView.startAnimating()
        self.setupVoiceSearch()
        if AppManager.languageType() == .arabic {
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ar-SA"))!
        } else {
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
        }
        self.startRecording()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.audioEngine.stop()
        
        self.dismiss(animated: true, completion: {
            let finalTextStr = self.voiceSearchResultLabel.text?.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "")
            self.delegate?.didTapDoneButton(withResultText: finalTextStr!)
        })
    }
}

//MARK:- Initial Setup:
extension VoiceSearchWindowViewController {
    
    func setupVoiceSearch() {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                //self.voiceButton.isEnabled = isButtonEnabled
//                self.searchTextField.searchByVoiceButton?.isEnabled = isButtonEnabled
                
            }
        }
    }
    
    func handleUIElements() {
        self.voiceSearchResultLabel.isHidden = false
//        self.voiceActivityIndicator.isHidden = true
        self.pleaseWaitLabel.isHidden = true
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        self.pleaseWaitLabel.text = "Please Wait..!"
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.handleUIElements()
                self.progressIndicatorView.stopAnimating()
//                self.voiceActivityIndicator.stopAnimating()
                self.pleaseWaitLabel.text = ""
                if let resultStr = result?.bestTranscription.formattedString {
                    self.searchResultString = resultStr
                    self.voiceSearchResultLabel.text = self.searchResultString
                }
                
                
                //self.searchByVoiceText = self.searchTextField.text
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.progressIndicatorView.stopAnimating()
//                self.voiceActivityIndicator.stopAnimating()
                self.pleaseWaitLabel.text = self.ERROR_TEXT
                self.audioEngine.stop()
                self.audioEngine.inputNode?.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //self.voiceButton.isEnabled = true
                //self.searchTextField.searchByVoiceButton?.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        self.pleaseWaitLabel.text = WELCOME_TEXT
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(VoiceSearchWindowViewController.dismissViewController))
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissViewController() {
        dismiss(animated: true, completion: {
            self.delegate?.exitFormVoiceSearch()
        })
    }
}

//MARK:- SFSpeechRecognizerDelegate
extension VoiceSearchWindowViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            //self.voiceButton.isEnabled = true
            //self.searchTextField.searchByVoiceButton?.isEnabled = true
        } else {
            //self.voiceButton.isEnabled = false
            //self.searchTextField.searchByVoiceButton?.isEnabled = false
        }
    }
}
