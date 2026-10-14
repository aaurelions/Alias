import Foundation

/// Incrementally extracts `topic.name`, `topic.emoji` and `words[]` from a streamed JSON object,
/// so progress can be reported before the response is complete.
nonisolated struct StreamingWordListParser: Sendable {
    private(set) var words: [String] = []
    private(set) var topicName: String?
    private(set) var topicEmoji: String?

    private struct Frame {
        let isObject: Bool
        let name: String?
        var key: String?
        var isAwaitingKey: Bool
    }

    private var frames: [Frame] = []
    private var wordKeys = Set<String>()
    private var buffer = String.UnicodeScalarView()
    private var isInString = false
    private var isEscaping = false
    private var unicodeHex: String?
    private var highSurrogate: UInt32?

    mutating func consume(_ chunk: String) {
        for scalar in chunk.unicodeScalars {
            if isInString {
                consumeStringScalar(scalar)
            } else {
                consumeStructuralScalar(scalar)
            }
        }
    }

    private mutating func consumeStringScalar(_ scalar: Unicode.Scalar) {
        if unicodeHex != nil {
            consumeUnicodeHex(scalar)
        } else if isEscaping {
            isEscaping = false
            switch scalar {
            case "n": buffer.append("\n")
            case "t": buffer.append("\t")
            case "r": buffer.append("\r")
            case "b", "f": break
            case "u": unicodeHex = ""
            default: buffer.append(scalar)
            }
        } else if scalar == "\\" {
            isEscaping = true
        } else if scalar == "\"" {
            isInString = false
            finishString(String(buffer))
        } else {
            buffer.append(scalar)
        }
    }

    private mutating func consumeUnicodeHex(_ scalar: Unicode.Scalar) {
        unicodeHex?.unicodeScalars.append(scalar)
        guard let hex = unicodeHex, hex.count == 4 else { return }
        unicodeHex = nil
        guard let value = UInt32(hex, radix: 16) else { return }

        switch value {
        case 0xD800 ... 0xDBFF:
            highSurrogate = value
        case 0xDC00 ... 0xDFFF:
            if let high = highSurrogate,
               let combined = Unicode.Scalar(0x10000 + ((high - 0xD800) << 10) + (value - 0xDC00)) {
                buffer.append(combined)
            }
            highSurrogate = nil
        default:
            if let decoded = Unicode.Scalar(value) { buffer.append(decoded) }
        }
    }

    private mutating func consumeStructuralScalar(_ scalar: Unicode.Scalar) {
        switch scalar {
        case "\"":
            isInString = true
            buffer = String.UnicodeScalarView()
        case "{":
            frames.append(Frame(isObject: true, name: currentValueName, key: nil, isAwaitingKey: true))
        case "[":
            frames.append(Frame(isObject: false, name: currentValueName, key: nil, isAwaitingKey: false))
        case "}", "]":
            _ = frames.popLast()
        case ",":
            if frames.last?.isObject == true {
                frames[frames.count - 1].isAwaitingKey = true
                frames[frames.count - 1].key = nil
            }
        case ":":
            if frames.last?.isObject == true {
                frames[frames.count - 1].isAwaitingKey = false
            }
        default:
            break
        }
    }

    private var currentValueName: String? {
        guard let frame = frames.last, frame.isObject else { return nil }
        return frame.key
    }

    private mutating func finishString(_ value: String) {
        guard let frame = frames.last else { return }

        if frame.isObject {
            if frame.isAwaitingKey {
                frames[frames.count - 1].key = value
            } else if frames.count == 2, frame.name == "topic" {
                switch frame.key {
                case "name": topicName = WordList.clean(value)
                case "emoji": topicEmoji = value.trimmingCharacters(in: .whitespacesAndNewlines)
                default: break
                }
            }
        } else if frames.count == 2, frame.name == "words" {
            let word = WordList.clean(value)
            guard !word.isEmpty, wordKeys.insert(WordList.key(for: word)).inserted else { return }
            words.append(word)
        }
    }
}
