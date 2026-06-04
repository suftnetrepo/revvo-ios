import SwiftUI
import PDFKit

struct SummaryView: View {
    let title: String
    let summary: String
    var onDismiss: () -> Void

    @State private var showShareSheet = false
    @State private var showTextSize = false
    @State private var pdfData: Data?
    @State private var showPDFShare = false
    @ObservedObject var textPreference = TextSizePreference.shared

    var paragraphs: [String] {
        summary.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if !title.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SUMMARY")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Color(hex: "6C5CE7"))
                                    .kerning(1)
                                Text(title)
                                    .font(.system(size: textPreference.size.questionSize + 4, weight: .medium))
                                    .foregroundStyle(.white)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }

                        Divider()
                            .background(Color(hex: "2a2a3a"))
                            .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                                HStack(alignment: .top, spacing: 12) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(hex: "6C5CE7"))
                                        .frame(width: 3)
                                        .padding(.top, 4)

                                    Text(paragraph)
                                        .font(.system(size: textPreference.size.answerSize))
                                        .foregroundStyle(Color(hex: "cccccc"))
                                        .lineSpacing(6)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .sheet(isPresented: $showTextSize) {
            TextSizeSheet(onDismiss: { showTextSize = false })
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["\(title)\n\n\(summary)"])
        }
        .sheet(isPresented: $showPDFShare) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color(hex: "888888"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "1a1a2e"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
            Text("Summary")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            HStack(spacing: 8) {
                Button(action: { showTextSize = true }) {
                    Image(systemName: "textformat.size")
                        .foregroundStyle(Color(hex: "888888"))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "1a1a2e"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Menu {
                    Button(action: { showShareSheet = true }) {
                        Label("Share as text", systemImage: "square.and.arrow.up")
                    }
                    Button(action: exportAsPDF) {
                        Label("Export as PDF", systemImage: "doc.fill")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color(hex: "6C5CE7"))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "1a1a2e"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(16)
    }

    private func exportAsPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "Revvo",
            kCGPDFContextAuthor: "Revvo App",
            kCGPDFContextTitle: title
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 60

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            let titleRect = CGRect(x: margin, y: yPosition, width: pageWidth - margin * 2, height: 200)
            titleString.draw(in: titleRect)
            yPosition += titleString.boundingRect(
                with: CGSize(width: pageWidth - margin * 2, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                context: nil
            ).height + 20

            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            UIColor.lightGray.setStroke()
            dividerPath.stroke()
            yPosition += 20


            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 12

            for paragraph in paragraphs {
                let paraAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: paragraphStyle
                ]
                let paraString = NSAttributedString(string: paragraph, attributes: paraAttributes)
                let availableWidth = pageWidth - margin * 2 - 16

                let paraHeight = paraString.boundingRect(
                    with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    context: nil
                ).height

                if yPosition + paraHeight > pageHeight - margin {
                    context.beginPage()
                    yPosition = margin
                }

                // Purple bar
                let barRect = CGRect(x: margin, y: yPosition, width: 3, height: paraHeight)
                UIColor(red: 0.42, green: 0.36, blue: 0.91, alpha: 1).setFill()
                UIBezierPath(roundedRect: barRect, cornerRadius: 1.5).fill()

                let paraRect = CGRect(x: margin + 16, y: yPosition, width: availableWidth, height: paraHeight)
                paraString.draw(in: paraRect)
                yPosition += paraHeight + 16
            }

            // Footer
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.lightGray
            ]
            let footerString = NSAttributedString(string: "Generated by Revvo", attributes: footerAttributes)
            let footerRect = CGRect(x: margin, y: pageHeight - margin, width: pageWidth - margin * 2, height: 20)
            footerString.draw(in: footerRect)
        }

        pdfData = data
        showPDFShare = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
