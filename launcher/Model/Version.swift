// SPDX-License-Identifier: GPL-2.0-or-later
import Foundation

/// A version of the port: the dotted numbers of a release tag (mac-v0.5.2.2 -> 0.5.2.2) and what
/// follows them ("-test1" for a test build, "-5-g0b50589" for a build from a checkout).
/// Only the numbers decide what is newer: a checkout build sits on the release it follows, so it
/// is offered the next numbered release, never a reinstall of its own.
struct ReleaseVersion: Equatable, CustomStringConvertible {
    let numbers: [Int]
    /// "" for a plain numbered release.
    let suffix: String
    let text: String

    /// nil when the text does not start with a number ("dev-0b50589" from a manual CI run).
    init?(_ raw: String) {
        let text = raw.hasPrefix("mac-v") ? String(raw.dropFirst("mac-v".count)) : raw
        var head = text[..<(text.firstIndex { !($0.isASCII && ($0.isNumber || $0 == ".")) } ?? text.endIndex)]
        while head.hasSuffix(".") { head = head.dropLast() }
        let parts = head.split(separator: ".", omittingEmptySubsequences: false)
        let numbers = parts.compactMap { Int($0) }
        guard !numbers.isEmpty, numbers.count == parts.count else { return nil }
        self.numbers = numbers
        suffix = String(text[head.endIndex...])
        self.text = text
    }

    var isPlain: Bool { suffix.isEmpty }
    var description: String { text }

    func isNewer(than other: ReleaseVersion) -> Bool {
        for i in 0..<max(numbers.count, other.numbers.count) {
            let a = i < numbers.count ? numbers[i] : 0, b = i < other.numbers.count ? other.numbers[i] : 0
            if a != b { return a > b }
        }
        return false
    }
}
