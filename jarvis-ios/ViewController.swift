//
//  ViewController.swift
//  jarvis-ios
//
//  Created by soojin on 26/04/2018.
//  Copyright © 2018 naverlabs. All rights reserved.
//

import UIKit
import NaverThirdPartyLogin
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet var micStatusLabel: UILabel!
    @IBOutlet var clovaStatusLabel: UILabel!
    @IBOutlet var contentCollectionView: UICollectionView!
    
    let connection = NaverThirdPartyLoginConnection.getSharedInstance()
    let clovaAccessTokenManager = ClovaAccessTokenManager()
    let clovaServiceClient = ClovaServiecClient()
    
    // for audio recored
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    
    private var isRecording = false
    private var jsonList = [[String:Any]]()
    
    // for stream audio
    private let audioEngine = AVAudioEngine()
    private var audioQueue:PCMBuffer = PCMBuffer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        connection?.delegate = self
        connection?.requestThirdPartyLogin()
        
        clovaAccessTokenManager.delegate = self
        clovaServiceClient.delegate = self
        clovaServiceClient.dataSource = self
        clovaServiceClient.renderTemplateDelegate = self
        
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func micButtonClick(_ sender: Any) {
//        clovaServiceClient.exampleEventRequest(text: "너 뭐야?")
        postAudioEvent()
        
//        clovaServiceClient.exampleStreamAudioRequest()
//        RunLoop.current.run()
        
//        isRecording = true
//        prepareAudioSession()
//        recordAudio()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//            self.clovaServiceClient.exampleStreamAudioRequest()
//        })
    }
    
    func postAudioEvent() {
        if (self.isRecording) {
            self.isRecording = false
            audioRecorder.stop()
            
        } else {
            self.isRecording = true
            prepareAudioSession()
            print("---------record start---------")
            
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
    }
    
    func recordAudio() {
        if (self.isRecording) {
            audioRecorder.prepareToRecord()
            audioRecorder.record(forDuration: TimeInterval(2)/10)
        }
    }
    
    func prepareAudioSession() {
        do {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = directory.appendingPathComponent(Settings.Audio.TEMP_FILE_NAME)
            try audioRecorder = AVAudioRecorder(url: fileURL, settings: Settings.Audio.RECORDING_SETTING as [String : AnyObject])
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:[AVAudioSessionCategoryOptions.allowBluetooth, AVAudioSessionCategoryOptions.allowBluetoothA2DP])
            self.audioRecorder.delegate = self
        } catch let ex {
            print("Audio session has an error: \(ex.localizedDescription)")
        }
    }
    
    /// for stream audio
//    private func startRecording(audioQueue: PCMBuffer) throws {
//        if !(self.isRecording) {
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(AVAudioSessionCategoryRecord)
//            try audioSession.setMode(AVAudioSessionModeMeasurement)
//            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
//
//            let inputNode = audioEngine.inputNode
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//
//            inputNode.installTap(onBus: 0, bufferSize: 10, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//                print("enqueu")
//                audioQueue.enqueue(self.audioPCMBufferToData(buffer: buffer))
//            }
//
//            audioEngine.prepare()
//            try audioEngine.start()
//            self.isRecording = true
//        } else {
//            try audioEngine.stop()
//            var audio = Data()
//            while audioQueue.buffer.count > BufferSize {
//                print("denqueu")
//                audio.append(audioQueue.dequeue())
//            }
//
//            print(audio)
//            do {
//                audioPlayer = try AVAudioPlayer(data: audio)
//                audioPlayer.play()
//            } catch {
//                print(error.localizedDescription)
//            }
//             self.isRecording = false
//        }
//    }
    
    func audioPCMBufferToData(buffer: AVAudioPCMBuffer) -> Data {
        let numOfChannel = 1
        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: numOfChannel)
        let length = Int(buffer.frameLength * buffer.format.streamDescription.pointee.mBytesPerFrame)
        return Data(bytes: channels[0], count: length)
    }
    
    func copyAudioBufferBytes(_ audioBuffer: AVAudioPCMBuffer) -> [UInt8] {
        let srcLeft = audioBuffer.floatChannelData![0]
        let bytesPerFrame = audioBuffer.format.streamDescription.pointee.mBytesPerFrame
        let numBytes = Int(bytesPerFrame * audioBuffer.frameLength)
        
        // initialize bytes to 0 (how to avoid?)
        var audioByteArray = [UInt8](repeating: 0, count: numBytes)
        
        // copy data from buffer
        srcLeft.withMemoryRebound(to: UInt8.self, capacity: numBytes) { srcByteData in
            audioByteArray.withUnsafeMutableBufferPointer {
                $0.baseAddress!.initialize(from: srcByteData, count: numBytes)
            }
        }
        
        return audioByteArray
    }
}

extension ViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {

    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Naver login Success")
        self.clovaAccessTokenManager.requestClovaAccessToken(accessToken: (connection?.accessToken)!)
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        self.clovaAccessTokenManager.requestClovaAccessToken(accessToken: (connection?.accessToken)!)
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print(error)
    }
}

extension ViewController: ClovaAccessTokenManagerDelegate {
    func clovaConnectionDidFinishRequestAccessToken() {
        self.clovaServiceClient.setClova(accessToken: clovaAccessTokenManager.clovaAccessToken!)
        self.clovaServiceClient.requestDownchannel()
    }
}

extension ViewController: ClovaServiceClientDelgate {
    func clovaServiceShowRecognizedText(text: String) {
        DispatchQueue.main.async {
            self.micStatusLabel.text = text
        }
    }
    
    func clovaServiceStopCapture(recognizedText: String) {
         self.clovaServiceClient.exampleEventRequest(text: recognizedText)
    }
    
    func clovaServiceAttachmentAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.play()
        } catch {
            print("errrrr")
        }
    }
    
    func clovaServiceDownchannelSet() {
        DispatchQueue.main.async {
            self.clovaStatusLabel.text = "Downchannel 세팅 완료~!"
        }
    }
}

extension ViewController: RenderTemplateDelegate {
    func renderTemplate(json: [String : Any]) {
        DispatchQueue.main.async {
            self.jsonList.reverse()
            self.jsonList.append(json)
            self.jsonList.reverse()
            
            self.contentCollectionView.reloadData()
        }
    }
}

extension ViewController: ClovaServiceClientDataSource {
    func audioBuffer() -> PCMBuffer{
        return audioQueue
    }
    
    func audioData() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = directory.appendingPathComponent(Settings.Audio.TEMP_FILE_NAME)
        
        return fileURL
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("-----------json----------")
        print(jsonList[indexPath.row])

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EncyclopediaTemplate", for: indexPath) as? EncyclopediaTemplateCollectionCell {
            cell.putCellContent(json: jsonList[indexPath.row])
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 385)
    }
}

extension ViewController: AVAudioRecorderDelegate {
    // full audio data
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        do {
            try clovaServiceClient.exampleAudioRequest(audioData: Data(contentsOf: audioRecorder.url))
        } catch let err {
            print(err)
        }
    }
    
    // stack audio data
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        do {
//            print("--------enqueue--------")
//            try audioQueue.enqueue(Data(contentsOf: audioRecorder.url))
//            recordAudio()
//        } catch let err {
//            print(err)
//        }
//    }
}
