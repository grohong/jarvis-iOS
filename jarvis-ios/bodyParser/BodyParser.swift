/*
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

// MARK: BodyParser

/// Router middleware for parsing the body of the request.
internal class BodyParser {

    /// BodyParser archiver
    private static let parserMap: [String: BodyParserProtocol] =
        ["application/json": JSONBodyParser(),
         "application/x-www-form-urlencoded": URLEncodedBodyParser(),
         "text": TextBodyParser()]

    /// Initializes a BodyParser instance.
    /// Needed since default initalizer is internal.
    init() {}

    class func getParser(contentType: String) -> BodyParserProtocol? {
        // Handle Content-Type with parameters.  For example, treat:
        // "application/x-www-form-urlencoded; charset=UTF-8" as
        // "application/x-www-form-urlencoded"
        var contentTypeWithoutParameters = contentType
        if let parameterStart = contentTypeWithoutParameters.range(of: ";") {
            contentTypeWithoutParameters = contentType.stringByIndex(to: parameterStart.lowerBound)
        }
        if let parser = parserMap[contentTypeWithoutParameters] {
            return parser
        } else if let parser = parserMap["text"], contentType.hasPrefix("text/") {
            return parser
        } else if contentType.hasPrefix("multipart/form-data") {
            guard let boundryIndex = contentType.range(of: "boundary=") else {
                return nil
            }
            var boundary = contentType.stringByIndex(from: boundryIndex.upperBound).replacingOccurrences(of: "\"", with: "")
            // remove any trailing parameters - as per RFC 2046 section 5.1.1., a semicolon cannot be part of a boundary
            if let parameterStart = boundary.range(of: ";") {
                boundary = boundary.stringByIndex(to: parameterStart.lowerBound)
            }
            return MultiPartBodyParser(boundary: boundary)
        } else { //Default: parse body as `.raw(Data)`
            return RawBodyParser()
        }
    }
}

extension Data {
    func hasPrefix(_ data: Data) -> Bool {
        if data.count > self.count {
            return false
        }
        return self.subdata(in: 0 ..< data.count) == data
    }
}
