---
name: pdf-reader
description: Extract text from PDF files using pdftotext. Handles local files, WhatsApp/Telegram attachments, and URL fetching. Use when the user sends a PDF or asks to read a PDF.
---

# PDF Reader

Extract text from PDF files using `pdftotext` from poppler-utils. Available as a container CLI tool.

## Quick Usage

```bash
# Extract text from a PDF file
pdf-reader /workspace/group/attachments/report.pdf

# Fetch and extract a PDF from a URL
pdf-reader fetch https://example.com/document.pdf

# Show PDF metadata (page count, author, etc.)
pdf-reader info /workspace/group/attachments/report.pdf
```

## When to Use

- User sends a PDF file as an attachment (WhatsApp, Telegram, etc.)
- User asks to read/summarize/extract text from a PDF
- User provides a URL to a PDF document

## How It Works

The `pdf-reader` tool wraps `pdftotext` and `pdfinfo` from poppler-utils. It:

1. Validates the file is actually a PDF (checks `%PDF-` header)
2. Extracts text with layout preservation
3. Outputs the text with metadata header (filename, page count, text size)

### Attachment Paths

PDFs sent via messaging channels are downloaded to the group's attachments directory:

- **Telegram documents**: `/workspace/group/attachments/<filename>`
- **WhatsApp documents**: `/workspace/group/attachments/<filename>`

When a user sends a PDF, the channel delivers the file path in the message content. Use `pdf-reader` on that path to extract the text.

### URL Fetching

`pdf-reader fetch <url>` downloads the PDF to a temp file, extracts text, then cleans up. Use this when the user provides a URL instead of a file attachment.

## Limitations

- **Scanned/image PDFs**: `pdftotext` only works on text-based PDFs. If the PDF is scanned images of text, extraction returns empty. In this case, suggest using `agent-browser` to open the PDF visually.
- **Encrypted PDFs**: Password-protected PDFs cannot be processed.
- **Very large PDFs**: May produce large output. Consider summarizing by sections or reading specific pages if needed.

## Workflow

When a user sends a PDF:

1. Acknowledge receipt of the PDF
2. Run `pdf-reader <path>` to extract text
3. Summarize or answer questions about the content
4. If extraction fails (empty text), explain it may be a scanned PDF and offer to use `agent-browser` instead

## Example

User sends `quarterly-report.pdf` via Telegram. The message content includes:

```
[Document: quarterly-report.pdf] (/workspace/group/attachments/quarterly-report.pdf)
```

Run:

```bash
pdf-reader /workspace/group/attachments/quarterly-report.pdf
```

Then summarize the extracted text for the user.
