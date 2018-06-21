//
//  ClovaServiceClient.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 9..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation
import Alamofire

struct DirectiveData {
    var namespace = String()
    var name = String()
    var messageId: String?
    var dialogRequestId: String?
    
    var payload: [String:Any]?
}

class ClovaServiecClient: NSObject {
    var deviceId = APIKeyManager.deviceId
    let clientId = APIKeyManager.clovaId
    let clientSecret = APIKeyManager.clovaSecret
    let modelId = APIKeyManager.naverUrlScheme
    let userAgent = "jarvis-hackday/jarvis-ios/1.0.0 (iOS 11.3; model=iPhone10,4)"
    var clovaAccessToken: String?
    
    var delegate: ClovaServiceClientDelgate?
    var renderTemplateDelegate: RenderTemplateDelegate?
    var dataSource: ClovaServiceClientDataSource?
    
    var session: URLSession!
    
    let DIRECTIVES_ENDPOINT: String = "https://prod-ni-cic.clova.ai/v1/directives"
    let EVENTS_ENDPOINT: String = "https://prod-ni-cic.clova.ai/v1/events"
    let PING_ENDPOINT: String = "https://prod-ni-cic.clova.ai/ping"
    
    var isRecording = false
    var state: State
    var audioQueue: PCMBuffer

    var inputStream: InputStream?
    
    // context info
    let alertState = "{\"header\": {\"namespace\": \"Alerts\", \"name\": \"AlertsState\"}, \"payload\": {\"allAlerts\": [], \"activeAlerts\": []}}"
    let playerState = "{\"header\": {\"namespace\": \"AudioPlayer\", \"name\": \"PlaybackState\"}, \"payload\": {\"playerActivity\": \"IDLE\", \"repeatMode\": \"NONE\"}}"
    let deviceState = "{\"header\": {\"namespace\": \"Device\", \"name\": \"DeviceState\"}, \"payload\": {}}"
    let display = "{\"header\": {\"namespace\": \"Device\", \"name\": \"Display\"}, \"payload\": {\"orientation\": \"portrait\", \"dpi\": 300, \"size\": \"custom\", \"contentLayer\": {\"width\": 375, \"height\": 667}}}"
    let location = "{\"header\": {\"namespace\": \"Clova\", \"name\": \"Location\"}, \"payload\": {\"latitude\": \"37.3594915\", \"longitude\": \"127.1032242\", \"refreshedAt\": \"2018-05-06T13:34:15.074361+08:28\"}}"
    let savedPlace = "{\"header\": {\"namespace\": \"Clova\", \"name\": \"SavedPlace\"}, \"payload\": {\"places\": []}}"
    let volumnState = "{\"header\": {\"namespace\": \"Speaker\", \"name\": \"VolumeState\"}, \"payload\": {\"volume\": 100, \"muted\": false}}"
    let speechState = "{\"header\": {\"namespace\": \"SpeechSynthesizer\", \"name\": \"SpeechState\"}, \"payload\": {\"token\": \"dc706e02-fe16-4337-9a6c-51f670b5adb2\", \"playerActivity\": \"FINISHED\"}}"
    
    override init() {
        self.state = .initialised
        audioQueue = PCMBuffer()
        super.init()
        
        // MARK: sessonConfig set
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpMaximumConnectionsPerHost = 1
        sessionConfig.timeoutIntervalForRequest = 30.0
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        print("Session created")
    }
    
    func setClova(accessToken: String) {
        self.clovaAccessToken = accessToken
    }
    
    func requestDownchannel() {
        var request = URLRequest(url: URL(string: DIRECTIVES_ENDPOINT)!)
        request.httpMethod = "GET"
        addAuthHeader(request: &request)
        session.dataTask(with: request).resume()
        
        // Send a Ping every 5 minutes
        Timer.scheduledTimer(timeInterval: 300,
                             target: self,
                             selector: #selector(ping),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func ping() {
        var request = URLRequest(url: URL(string: PING_ENDPOINT)!)
        request.httpMethod = "GET"
        addAuthHeader(request: &request)
        session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if (error != nil) {
                print("Ping failure: \(String(describing: error?.localizedDescription))")
                self.requestDownchannel()
            } else {
                let res = response as! HTTPURLResponse
                print("Ping status code: \(res.statusCode)")
                if (res.statusCode == 204) {
                    self.requestDownchannel()
                } else {
                    self.requestDownchannel()
                }
            }
        }).resume()
    }
    
    func exampleAudioRequest(audioData: Data) {
        let speechRecognizerPayload = "{\"lang\": \"ko\", \"profile\": \"CLOSE_TALK\", \"format\": \"AUDIO_L16_RATE_16000_CHANNELS_1\"}"
        
        let dialogRequestId = UUID().uuidString
        let messageId = UUID().uuidString
        
        let EXAMPLE_AUDIO_DATA = "{\"context\": [\(alertState), \(playerState), \(deviceState), \(display), \(location), \(savedPlace), \(volumnState), \(speechState)], \"event\": {\"header\": {\"namespace\": \"SpeechRecognizer\", \"name\": \"Recognize\", \"messageId\": \"\(messageId)\", \"dialogRequestId\": \"\(dialogRequestId)\"}, \"payload\": \(speechRecognizerPayload)}}"
        
        let boundary = getBoundary(exBoundary: false)
        var request = URLRequest(url: URL(string: EVENTS_ENDPOINT)!)
        request.httpMethod = "POST"
        addAuthHeader(request: &request)
        addContentTypeHeader(request: &request, boundary: boundary)
        // audio request log
        print("-------------------------")
        print("event boundary: \(boundary)")
        print(audioData)
        print(dialogRequestId)
        print("-------------------------")
        
        var bodyData = Data()
        bodyData.append(getBoundaryTermBegin(boundary: boundary))
        bodyData.append(addEventData(jsonData: EXAMPLE_AUDIO_DATA))
        bodyData.append(getBoundaryTermBegin(boundary: boundary))
        bodyData.append(addAudioData(audioData: audioData))
        bodyData.append(getBoundaryTermEnd(boundary: boundary))
        
        session.uploadTask(with: request, from: bodyData, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if (error != nil) {
                print("Send data error: \(String(describing: error?.localizedDescription))")
            } else {
                let res = response as! HTTPURLResponse
                print("Send audio status code: \(res.statusCode)")
                if (res.statusCode >= 200 && res.statusCode <= 299) {
                    guard let contentTypeHeader = res.allHeaderFields["Content-Type"] else {
                        return
                    }
                    let boundary = self.extractBoundary(contentTypeHeader: contentTypeHeader as! String)
                    let directives = self.extractDirectives(data: data!, boundary: boundary)

                    print("----------audio event-----------")
                    print(directives)
                    print("--------------------------------")
                }
            }
        }).resume()
    }
    
//    func exampleStreamAudioRequest() {
//        let speechRecognizerPayload = "{\"lang\": \"ko\", \"profile\": \"CLOSE_TALK\", \"format\": \"AUDIO_L16_RATE_16000_CHANNELS_1\"}"
//        let dialogRequestId = UUID().uuidString
//        let messageId = UUID().uuidString
//
//        let EXAMPLE_AUDIO_DATA = "{\"context\": [\(alertState), \(playerState), \(deviceState), \(display), \(location), \(savedPlace), \(volumnState), \(speechState)], \"event\": {\"header\": {\"namespace\": \"SpeechRecognizer\", \"name\": \"Recognize\", \"messageId\": \"\(messageId)\", \"dialogRequestId\": \"\(dialogRequestId)\"}, \"payload\": \(speechRecognizerPayload)}}"
//
//        let boundary = getBoundary(exBoundary: false)
//        var request = URLRequest(url: URL(string: EVENTS_ENDPOINT)!)
//        request.httpMethod = "POST"
//        addAuthHeader(request: &request)
//        addContentTypeHeader(request: &request, boundary: boundary)
//
//        var bodyData = Data()
//        bodyData.append(getBoundaryTermBegin(boundary: boundary))
//        bodyData.append(addEventData(jsonData: EXAMPLE_AUDIO_DATA))
//        bodyData.append(getBoundaryTermBegin(boundary: boundary))
//        bodyData.append(addAudioStream())
//
//        request.httpBody = bodyData
//
//        let task = session.uploadTask(withStreamedRequest: request)
//        self.state = .started(.init(task: task))
//        task.resume()
//    }
    
    func exampleStreamAudioRequest() {
//        let speechRecognizerPayload = "{\"lang\": \"ko\", \"profile\": \"CLOSE_TALK\", \"format\": \"AUDIO_L16_RATE_16000_CHANNELS_1\"}"
//        let dialogRequestId = UUID().uuidString
//        let messageId = UUID().uuidString
//
//        let EXAMPLE_AUDIO_DATA = "{\"context\": [\(alertState), \(playerState), \(deviceState), \(display), \(location), \(savedPlace), \(volumnState), \(speechState)], \"event\": {\"header\": {\"namespace\": \"SpeechRecognizer\", \"name\": \"Recognize\", \"messageId\": \"\(messageId)\", \"dialogRequestId\": \"\(dialogRequestId)\"}, \"payload\": \(speechRecognizerPayload)}}"


        let boundary = getBoundary(exBoundary: false)
        var request = URLRequest(url: URL(string: EVENTS_ENDPOINT)!)
        request.httpMethod = "POST"
        addAuthHeader(request: &request)
        addContentTypeHeader(request: &request, boundary: boundary)
        
//        var bodyData = Data()
//        bodyData.append(getBoundaryTermBegin(boundary: boundary))
//        bodyData.append(addEventData(jsonData: EXAMPLE_AUDIO_DATA))
//        bodyData.append(getBoundaryTermBegin(boundary: boundary))
//        bodyData.append(addAudioStream())

//        var bodyStreamData = Data()
//        bodyStreamData.append(getBoundaryTermBegin(boundary: boundary))
//        bodyStreamData.append(addAudioStream())

//        var inputStream: InputStream
//        var outputStream: OutputStream
//        (inputStream, outputStream) = Stream.boundPair(bufferSize: 6400)
//        self.audioQueue = (dataSource?.audioBuffer())!

//        request.httpBodyStream = InputStream(url: (dataSource?.audioData())!)
//        request.httpBody = bodyData
//        self.inputStream = inputStream
//        request.httpBodyStream = inputStream
//        print("---------Instream data---------")
        
        session.uploadTask(withStreamedRequest: request).resume()
//        session.uploadTask(with: request, from: bodyData, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
//            if (error != nil) {
//                print("Send data error: \(String(describing: error?.localizedDescription))")
//            } else {
//                let res = response as! HTTPURLResponse
//                print("Send event status code: \(res.statusCode)")
//                if (res.statusCode >= 200 && res.statusCode <= 299) {
//                    guard let contentTypeHeader = res.allHeaderFields["Content-Type"] else {
//                        return
//                    }
//                    let boundary = self.extractBoundary(contentTypeHeader: contentTypeHeader as! String)
//                    let directives = self.extractDirectives(data: data!, boundary: boundary)
//
//                    print("---------event direct-----------")
//                    print(directives)
//                    self.directivesParse(directives: directives)
//                    print("--------------------------------")
//                }
//            }
//        }).resume()

//        outputStream.open()
//        while (true) {
//            print("--------why--------")
//            print(self.audioQueue.dequeue())
//            outputStream.write(Array(self.audioQueue.dequeue()), maxLength: 1000000)
//        }
    }
    
    func exampleEventRequest(text: String) {
        let dialogRequestId = UUID().uuidString
        let messageId = UUID().uuidString
        
        let EXAMPLE_EVENT_DATA = "{\"context\": [\(alertState), \(playerState), \(deviceState), \(display), \(location), \(savedPlace), \(volumnState), \(speechState)], \"event\": {\"header\": {\"namespace\": \"TextRecognizer\", \"name\": \"Recognize\", \"messageId\": \"\(messageId)\", \"dialogRequestId\": \"\(dialogRequestId)\"}, \"payload\": {\"text\": \"\(text)\"}}}"
        
        let boundary = getBoundary(exBoundary: false)
        var request = URLRequest(url: URL(string: EVENTS_ENDPOINT)!)
        request.httpMethod = "POST"
        addAuthHeader(request: &request)
        addContentTypeHeader(request: &request, boundary: boundary)
        
        var bodyData = Data()
        bodyData.append(getBoundaryTermBegin(boundary: boundary))
        bodyData.append(addEventData(jsonData: EXAMPLE_EVENT_DATA))
        bodyData.append(getBoundaryTermEnd(boundary: boundary))
        
        session.uploadTask(with: request, from: bodyData, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if (error != nil) {
                print("Send data error: \(String(describing: error?.localizedDescription))")
            } else {
                let res = response as! HTTPURLResponse
                print("Send event status code: \(res.statusCode)")
                if (res.statusCode >= 200 && res.statusCode <= 299) {
                    guard let contentTypeHeader = res.allHeaderFields["Content-Type"] else {
                        return
                    }
                    let boundary = self.extractBoundary(contentTypeHeader: contentTypeHeader as! String)
                    let directives = self.extractDirectives(data: data!, boundary: boundary)
                    
                    print("---------event direct-----------")
//                    print(directives)
                    self.directivesParse(directives: directives)
                    print("--------------------------------")
                }
            }
        }).resume()
    }
    
    fileprivate func extractDirectives(data: Data, boundary: String) -> [DirectiveData] {
        var directives = [DirectiveData]()
        
        let body = MultiPartBodyParser(boundary: boundary).parse(data)
        guard let multipart = body?.asMultiPart else {
            return directives
        }
        
        for part in multipart {
            if let partBody = part.body.asJson {
                guard let directiveJson = partBody["directive"] as? [String:Any] else {
                    continue
                }
                guard let header = directiveJson["header"] as? [String:Any] else {
                    continue
                }
                let payload = directiveJson["payload"] as? [String:Any]
                
                guard let name = header["name"] as? String,
                    let namespcae = header["namespace"] as? String else {
                        continue
                }
                let messageId = header["messageId"] as? String
                let dialogRequestId = header["dialogRequestId"] as? String
                
                let directive = DirectiveData(namespace: namespcae, name: name, messageId: messageId, dialogRequestId: dialogRequestId, payload: payload)
                directives.append(directive)
            } else {
                if let audioData = part.body.asRaw {
                    self.delegate?.clovaServiceAttachmentAudio(data: audioData)
                }
            }
        }
        
        return directives
    }
    
    fileprivate func directivesParse(directives: [DirectiveData]) {
        for directive in directives {
            if directive.name == "Hello" {
                self.delegate?.clovaServiceDownchannelSet()
            } else if directive.name == "StopCapture" {
                if let payload = directive.payload,
                    let recognizedText = payload["recognizedText"] as? String {
                    self.delegate?.clovaServiceStopCapture(recognizedText: recognizedText)
                }
            } else if directive.name == "ShowRecognizedText" {
                if let payload = directive.payload,
                    let text = payload["text"] as? String {
                    self.delegate?.clovaServiceShowRecognizedText(text: text)
                }
            } else if directive.name == "RenderTemplate" {
                if let payload = directive.payload {
                    self.renderTemplateDelegate?.renderTemplate(json: payload)
                }
            }
        }
    }
}

extension ClovaServiecClient: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let response = dataTask.response as! HTTPURLResponse
        guard let contentTypeHeader = response.allHeaderFields["Content-Type"] else {
            return
        }
        
        let boundary = self.extractBoundary(contentTypeHeader: contentTypeHeader as! String)
        let directives = self.extractDirectives(data: data, boundary: boundary)
        
        print("--------in downchannel--------")
        print(directives)
        print("------------------------------")
        
        self.directivesParse(directives: directives)
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        print("new body")
        let speechRecognizerPayload = "{\"lang\": \"ko\", \"profile\": \"CLOSE_TALK\", \"format\": \"AUDIO_L16_RATE_16000_CHANNELS_1\"}"
        let dialogRequestId = UUID().uuidString
        let messageId = UUID().uuidString
        
        let EXAMPLE_AUDIO_DATA = "{\"context\": [\(alertState), \(playerState), \(deviceState), \(display), \(location), \(savedPlace), \(volumnState), \(speechState)], \"event\": {\"header\": {\"namespace\": \"SpeechRecognizer\", \"name\": \"Recognize\", \"messageId\": \"\(messageId)\", \"dialogRequestId\": \"\(dialogRequestId)\"}, \"payload\": \(speechRecognizerPayload)}}"
        
        let boundary = getBoundary(exBoundary: false)
        var bodyData = Data()
        bodyData.append(getBoundaryTermBegin(boundary: boundary))
        bodyData.append(addEventData(jsonData: EXAMPLE_AUDIO_DATA))
        bodyData.append(getBoundaryTermBegin(boundary: boundary))
        bodyData.append(addAudioStream())
        
        var inputStream = InputStream(data: bodyData)
        var outputStream: OutputStream
        (inputStream, outputStream) = Stream.boundPair(bufferSize: 6400, inputStream: inputStream)
        self.audioQueue = (dataSource?.audioBuffer())!
        
        completionHandler(self.inputStream)
        
        outputStream.open()
        while (true) {
            print("--------why--------")
            print(self.audioQueue.dequeue())
            outputStream.write(Array(self.audioQueue.dequeue()), maxLength: 1000000000000)
        }
    }
    
    // Stream state
//    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
//        let task: URLSessionDataTask
//        switch self.state {
//        case .started(let startedState):
//            task = startedState.task
//        case .streaming(let streamingState):
//            streamingState.stop()
//            task = streamingState.task
//        case .initialised, .stopping, .stopped:
//            assert(false)
//            completionHandler(nil)
//            return
//        }
//
//        let sendTimer = Timer(timeInterval: TimeInterval(1), target: self, selector: #selector(didFire(sendTimer:)), userInfo: nil, repeats: true)
//
//        let streamingState = StreamingState(task: task, sendTimer: sendTimer)
//        self.state = .streaming(streamingState)
//
//        RunLoop.current.add(streamingState.sendTimer, forMode: .defaultRunLoopMode)
//        streamingState.outputStream.delegate = self
//        streamingState.outputStream.schedule(in: .current, forMode: .defaultRunLoopMode)
//        streamingState.outputStream.open()
//
//        print("-----------completionHandler---------------")
//        completionHandler(streamingState.inputStream)
//    }
    
    // Stream error
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        print("-----------------didCompleteWithError---------------")
//        var actualError = error
//        switch self.state {
//        case .initialised, .stopped:
//            assert(false)
//        case .started:
//            break
//        case .streaming(let streamingState):
//            streamingState.stop()
//        case .stopping(let stoppedState):
//            if let e = stoppedState.error {
//                actualError = e
//            }
//        }
//
//        self.state = .stopped(.init(error: actualError))
//
//        if let error = actualError as NSError? {
//            NSLog("task did stop, error %@ / %d", error.domain, error.code)
//        } else {
//            NSLog("task did stop")
//        }
//        exit(EXIT_SUCCESS)
//    }
}

extension ClovaServiecClient: StreamDelegate {
    enum State {
        case initialised
        case started(StartedState)
        case streaming(StreamingState)
        case stopping(StoppedState)
        case stopped(StoppedState)
    }
    
    struct StartedState {
        let task: URLSessionDataTask
    }
    
    struct StreamingState {
        let task: URLSessionDataTask
        let inputStream: InputStream
        let outputStream: OutputStream
        var hasSpaceAvailable: Bool
        
        var sendTimer: Timer
        var sendCount: Int
        
        init(task: URLSessionDataTask, sendTimer: Timer) {
            let streams = Stream.boundPair(bufferSize: 6400)
            
            self.task = task
            self.inputStream = streams.inputStream
            self.outputStream = streams.outputStream
            self.hasSpaceAvailable = false
            self.sendTimer = sendTimer
            self.sendCount = 0
        }
        
        func stop() {
            self.outputStream.delegate = nil
            self.outputStream.close()
            self.sendTimer.invalidate()
        }
    }
    
    struct StoppedState {
        let error: Error?
    }
    
    func stop(error: Error?) {
        guard case .streaming(let streamingState) = self.state else { fatalError() }
        if let error = error as NSError? {
            NSLog("task will stop, error %@ / %d", error.domain, error.code)
        } else {
            NSLog("task will stop")
        }
        streamingState.stop()
        self.state = .stopping(.init(error: error))
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard case .streaming(var streamingState) = self.state else { fatalError() }
        
        switch eventCode {
        case [.openCompleted]:
            NSLog("stream did open")
        case [.hasBytesAvailable]:
            break
        case [.hasSpaceAvailable]:
            NSLog("stream has space available")
            streamingState.hasSpaceAvailable = true
            self.state = .streaming(streamingState)
        case [.endEncountered]:
            break
        case [.errorOccurred]:
            self.stop(error: aStream.streamError)
        default:
            break
        }
    }
    
    @objc private func didFire(sendTimer: Timer) {
        guard case .streaming(var streamingState) = self.state else { fatalError() }
        
        guard streamingState.hasSpaceAvailable else {
            self.stop(error: NSError(domain: NSPOSIXErrorDomain, code: Int(ETIMEDOUT), userInfo: nil))
            return
        }
        
        let buffer = "chunk \(streamingState.sendCount)\r\n".data(using: .utf8)!
        let bufferCount = buffer.count
        let bytesWritten = buffer.withUnsafeBytes { (bufferPtr: UnsafePointer<UInt8>)  in
            return streamingState.outputStream.write(bufferPtr, maxLength: bufferCount)
        }
        
        guard bytesWritten >= 0 else {
            self.stop(error: streamingState.outputStream.streamError)
            return
        }
        guard bytesWritten == buffer.count else {
            self.stop(error: NSError(domain: NSPOSIXErrorDomain, code: Int(ETIMEDOUT), userInfo: nil))
            return
        }
        
        NSLog("stream did send chunk %d", streamingState.sendCount)
        streamingState.hasSpaceAvailable = false
        streamingState.sendCount += 1
        
        if streamingState.sendCount == 5 {
            NSLog("stream will close")
            streamingState.stop()
            self.state = .stopping(.init(error: nil))
        } else {
            self.state = .streaming(streamingState)
        }
    }
}

// header Info
extension ClovaServiecClient {
    fileprivate func addAuthHeader(request: inout URLRequest) {
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        if let accessToken = clovaAccessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("no access token")
        }
    }
    
    fileprivate func addAudio(audioData: Data) -> Data {
        var bodyData = Data()
        bodyData.append(audioData)
        return bodyData
    }
    
    fileprivate func extractBoundary(contentTypeHeader: String) -> String {
        var boundary: String?
        let ctbRange = (contentTypeHeader as AnyObject).range(of: "boundary=.*?;", options: .regularExpression)
        if ctbRange.location != NSNotFound {
            let boundryNSS = (contentTypeHeader as AnyObject).substring(with: ctbRange) as NSString
            boundary = boundryNSS.substring(with: NSRange(location: 9, length: boundryNSS.length - 10))
        }
        return boundary!
    }
}

// body Info
extension ClovaServiecClient {
    func getDialogId() -> String {
        if let exDialogRequestId = UserDefaults.standard.string(forKey: "dialogRequestId") {
            return exDialogRequestId
        } else {
            let dialogRequestId = UUID().uuidString
            UserDefaults.standard.setValue(dialogRequestId, forKey: "dialogRequestId")
            return dialogRequestId
        }
    }
    
    func getMessageId() -> String {
        if let exMessageId = UserDefaults.standard.string(forKey: "messageId") {
            return exMessageId
        } else {
            let messageId = UUID().uuidString
            UserDefaults.standard.setValue(messageId, forKey: "messageId")
            return messageId
        }
    }
    
    func getBoundary(exBoundary: Bool) -> String {
        if exBoundary  {
            return UserDefaults.standard.string(forKey: "boundary")!
        } else {
            let boundary = UUID().uuidString
            UserDefaults.standard.setValue(boundary, forKey: "boundary")
            return boundary
        }
    }
    
    fileprivate func addContentTypeHeader(request: inout URLRequest, boundary: String) {
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    }
    
    fileprivate func getBoundaryTermBegin(boundary: String) -> Data {
        return "--\(boundary)\r\n".data(using: String.Encoding.utf8)!
    }
    
    fileprivate func getBoundaryTermEnd(boundary: String) -> Data {
        return "--\(boundary)--\r\n".data(using: String.Encoding.utf8)!
    }
    
    fileprivate func addEventData(jsonData: String) -> Data {
        var bodyData = Data()
        bodyData.append("Content-Disposition: form-data; name=\"metadata\"\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append(jsonData.data(using: String.Encoding.utf8)!)
        bodyData.append("\r\n".data(using: String.Encoding.utf8)!)
        return bodyData
    }
    
    fileprivate func addAudioData(audioData: Data) -> Data {
        var bodyData = Data()
        bodyData.append("Content-Disposition: form-data; name=\"audio\"\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append(audioData)
        bodyData.append("\r\n".data(using: String.Encoding.utf8)!)
        return bodyData
    }
    
    fileprivate func addAudioDisposition() -> Data {
        var bodyData = Data()
        bodyData.append("Content-Disposition: form-data; name=\"audio\"\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
        return bodyData
    }
    
    fileprivate func addAudioStream() -> Data {
        var bodyData = Data()
        bodyData.append("Content-Disposition: form-data; name=\"audio\"\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
        return bodyData
    }

}

public protocol ClovaServiceClientDataSource: class {
    func audioBuffer() -> PCMBuffer
    func audioData() -> URL
}

public protocol ClovaServiceClientDelgate: class {
    func clovaServiceAttachmentAudio(data: Data) -> Void
    func clovaServiceDownchannelSet() -> Void
    func clovaServiceStopCapture(recognizedText: String) -> Void
    func clovaServiceShowRecognizedText(text: String) -> Void
}

public protocol RenderTemplateDelegate: class {
    func renderTemplate(json: [String:Any]) -> Void
}
