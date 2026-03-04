//
//  NativeRenderer.swift
//  FORME
//
//  Created by zhuopeijin on 2026/2/15.
//

import UIKit
import Foundation
import Markdown

class NativeMarkdownRenderer {
    static let shared = NativeMarkdownRenderer()
    
    public func parseMarkdown(_ text: String, isUser: Bool) -> NSAttributedString? {

        // 使用cmark-gfm解析Markdown为HTML
        guard let html = markdownToHTML(text) else {
            return nil
        }
        return html
    }

    private func markdownToHTML(_ markdown: String) -> NSAttributedString? {
        do {
            // 使用swift-markdown解析Markdown
            let document = Document(parsing: markdown)

            // 创建HTML格式化器
            var htmlFormatter = Markdownosaur()
            let html = htmlFormatter.visit(document)

            return html
        } catch {
            print("Markdown to HTML error: \(error)")
            return nil
        }
    }

    private func parseHTML(_ html: String, isUser: Bool) -> NSAttributedString {
        let baseColor = isUser ? .label : UIColor.label
        let baseFont = UIFont.systemFont(ofSize: 18)

        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(
                string: html,
                attributes: [
                    .font: baseFont,
                    .foregroundColor: baseColor
                ]
            )
        }

        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            let attributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )

            // 应用基础样式
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
            mutableAttributedString.addAttribute(.font, value: baseFont, range: fullRange)
            mutableAttributedString.addAttribute(.foregroundColor, value: baseColor, range: fullRange)

            return mutableAttributedString
        } catch {
            print("HTML parsing error: \(error)")
            return NSAttributedString(
                string: html,
                attributes: [
                    .font: baseFont,
                    .foregroundColor: baseColor
                ]
            )
        }
    }
    
}
