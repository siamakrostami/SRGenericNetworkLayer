import Foundation

// MARK: - FileTypes

public enum FileTypes: Sendable {
    case amr, ar, avi, bmp, bz2, cab, cr2, crx, deb, dmg, eot, epub, exe, flac, flif, flv, gif, gz, ico, jpg, jxr, lz
    case m4a, m4v, mid, mkv, mov, mp3, mp4, mpg, msi, mxf, nes, ogg, opus, otf, pdf, png, ps, psd, rar, rpm, rtf
    case sevenZ, sqlite, swf, tar, tif, ttf, wav, webm, webp, wmv, woff, woff2, xpi, xz, z, zip
}

// MARK: - MimeType

public struct MimeType: Sendable {
    // MARK: Lifecycle

    public init(mime: String, ext: String, type: FileTypes, bytesCount: Int) {
        self.mime = mime
        self.ext = ext
        self.type = type
        self.bytesCount = bytesCount
    }

    // MARK: Public

    public static let all: [MimeType] = [
        MimeType(mime: "image/jpeg", ext: "jpg", type: .jpg, bytesCount: 3),
        MimeType(mime: "image/png", ext: "png", type: .png, bytesCount: 4),
        MimeType(mime: "image/gif", ext: "gif", type: .gif, bytesCount: 3),
        MimeType(mime: "image/webp", ext: "webp", type: .webp, bytesCount: 12),
        MimeType(mime: "application/pdf", ext: "pdf", type: .pdf, bytesCount: 4),
        MimeType(mime: "application/zip", ext: "zip", type: .zip, bytesCount: 4),
        MimeType(mime: "video/mp4", ext: "mp4", type: .mp4, bytesCount: 12),
        MimeType(mime: "audio/mpeg", ext: "mp3", type: .mp3, bytesCount: 3),
        MimeType(mime: "audio/x-wav", ext: "wav", type: .wav, bytesCount: 12),
        MimeType(mime: "audio/ogg", ext: "ogg", type: .ogg, bytesCount: 4),
        MimeType(mime: "application/x-bzip2", ext: "bz2", type: .bz2, bytesCount: 3),
        MimeType(mime: "application/x-rar-compressed", ext: "rar", type: .rar, bytesCount: 7),
        MimeType(mime: "application/x-tar", ext: "tar", type: .tar, bytesCount: 262),
        MimeType(mime: "video/quicktime", ext: "mov", type: .mov, bytesCount: 8),
        MimeType(mime: "audio/flac", ext: "flac", type: .flac, bytesCount: 4),
        MimeType(mime: "image/tiff", ext: "tif", type: .tif, bytesCount: 4),
        MimeType(mime: "video/x-msvideo", ext: "avi", type: .avi, bytesCount: 11),
        MimeType(mime: "video/x-ms-wmv", ext: "wmv", type: .wmv, bytesCount: 10),
        MimeType(mime: "application/vnd.adobe.photoshop", ext: "psd", type: .psd, bytesCount: 4),
        MimeType(mime: "application/x-msdownload", ext: "exe", type: .exe, bytesCount: 2),
        MimeType(mime: "application/x-7z-compressed", ext: "7z", type: .sevenZ, bytesCount: 6),
        MimeType(mime: "application/x-xz", ext: "xz", type: .xz, bytesCount: 6),
        MimeType(mime: "video/x-flv", ext: "flv", type: .flv, bytesCount: 4),
        MimeType(mime: "audio/x-opus+ogg", ext: "opus", type: .opus, bytesCount: 36),
        MimeType(mime: "application/epub+zip", ext: "epub", type: .epub, bytesCount: 58),
        MimeType(mime: "application/x-sqlite3", ext: "sqlite", type: .sqlite, bytesCount: 4),
        MimeType(mime: "application/x-deb", ext: "deb", type: .deb, bytesCount: 21),
        MimeType(mime: "application/x-dmg", ext: "dmg", type: .dmg, bytesCount: 2),
        MimeType(mime: "audio/m4a", ext: "m4a", type: .m4a, bytesCount: 11),
        MimeType(mime: "video/x-m4v", ext: "m4v", type: .m4v, bytesCount: 11),
        MimeType(mime: "application/x-compress", ext: "Z", type: .z, bytesCount: 2),
        MimeType(mime: "application/font-woff", ext: "woff", type: .woff, bytesCount: 8),
        MimeType(mime: "application/font-woff", ext: "woff2", type: .woff2, bytesCount: 8),
        MimeType(mime: "application/x-apple-diskimage", ext: "dmg", type: .dmg, bytesCount: 2),
        // More MIME types can be added as needed
    ]

    public func matches(bytes: [UInt8]) -> Bool {
        switch type {
        case .jpg:
            return bytes.starts(with: [0xff, 0xd8, 0xff])
        case .png:
            return bytes.starts(with: [0x89, 0x50, 0x4e, 0x47])
        case .gif:
            return bytes.starts(with: [0x47, 0x49, 0x46])
        case .webp:
            return bytes[8...11] == [0x57, 0x45, 0x42, 0x50]
        case .pdf:
            return bytes.starts(with: [0x25, 0x50, 0x44, 0x46])
        case .zip:
            return bytes.starts(with: [0x50, 0x4b, 0x03, 0x04])
        case .mp4:
            return bytes[4...7] == [0x66, 0x74, 0x79, 0x70] // "ftyp"
        case .mp3:
            return bytes.starts(with: [0x49, 0x44, 0x33]) || bytes.starts(with: [0xff, 0xfb])
        case .wav:
            return bytes[8...11] == [0x57, 0x41, 0x56, 0x45]
        case .ogg:
            return bytes.starts(with: [0x4f, 0x67, 0x67, 0x53])
        case .bz2:
            return bytes.starts(with: [0x42, 0x5a, 0x68])
        case .rar:
            return bytes.starts(with: [0x52, 0x61, 0x72, 0x21, 0x1a, 0x07])
        case .tar:
            return bytes[257...261] == [0x75, 0x73, 0x74, 0x61, 0x72]
        case .mov:
            return bytes.starts(with: [0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70])
        case .flac:
            return bytes.starts(with: [0x66, 0x4c, 0x61, 0x43])
        case .tif:
            return (bytes.starts(with: [0x49, 0x49, 0x2a, 0x00]) || bytes.starts(with: [0x4d, 0x4d, 0x00, 0x2a]))
        case .avi:
            return (bytes.starts(with: [0x52, 0x49, 0x46, 0x46]) && bytes[8...10] == [0x41, 0x56, 0x49])
        case .wmv:
            return bytes.starts(with: [0x30, 0x26, 0xb2, 0x75])
        case .psd:
            return bytes.starts(with: [0x38, 0x42, 0x50, 0x53])
        case .exe:
            return bytes.starts(with: [0x4d, 0x5a])
        case .xz:
            return bytes.starts(with: [0xfd, 0x37, 0x7a, 0x58])
        case .flv:
            return bytes.starts(with: [0x46, 0x4c, 0x56, 0x01])
        default:
            return false
        }
    }

    // MARK: Internal

    let mime: String
    let ext: String
    let type: FileTypes

    // MARK: Private

    private let bytesCount: Int
}

// MARK: - MimeTypeDetector

public struct MimeTypeDetector: Sendable {
    // Detect the MIME type from the data's file signature (magic number)
    public static func detectMimeType(from data: Data) -> MimeType? {
        let bytes = Array(data.prefix(262)) // Read first 262 bytes (magic number analysis)
        for mime in MimeType.all {
            if mime.matches(bytes: bytes) {
                return mime
            }
        }
        return nil
    }

    // Detect the MIME type based on the file extension
    public static func detectMimeType(fromExtension fileExtension: String) -> MimeType? {
        return MimeType.all.first { $0.ext == fileExtension }
    }
}
