//
//  FirecrawlService.swift
//  backend
//
//  Created by Mauricio Cardozo on 10/24/25.
//

import CocoaHeadsCore
import Vapor

protocol FirecrawlServiceProtocol: Sendable {
  func extract<T: Content>(
    req: Request,
    request: FirecrawlRequest
  ) async throws -> T
}

struct FirecrawlService: FirecrawlServiceProtocol {
  static let firecrawlURL = URI(string: "https://api.firecrawl.dev/v2/extract")

  func extract<T: Content>(
    req: Request,
    request: FirecrawlRequest
  ) async throws -> T {
    guard let apiKey = Environment.get("FIRECRAWL_API_KEY") else {
      throw FirecrawlError.missingAPIKey
    }

    let response = try await req.client.post(Self.firecrawlURL) { clientReq in
      clientReq.headers.add(name: .authorization, value: "Bearer \(apiKey)")
      clientReq.headers.add(name: .contentType, value: "application/json")
      try clientReq.content.encode(request)
    }

    let firecrawlExtractResponse = try response.content.decode(
      FirecrawlExtractResponse.self
    )

    let firecrawlStatusURL = URI(
      string: Self.firecrawlURL.string.appending(
        "/\(firecrawlExtractResponse.id)"
      )
    )

    var firecrawlStatusResponse = try await req.client.get(firecrawlStatusURL) { clientReq in
      clientReq.headers.add(name: .authorization, value: "Bearer \(apiKey)")
      clientReq.headers.add(name: .contentType, value: "application/json")
    }

    var firecrawlStatus = try firecrawlStatusResponse.content.decode(FirecrawlExtractionStatus.self)
    while firecrawlStatus.status == .processing {
      try await Task.sleep(for: .seconds(2))
      firecrawlStatusResponse = try await req.client.get(firecrawlStatusURL) { clientReq in
        clientReq.headers.add(name: .authorization, value: "Bearer \(apiKey)")
        clientReq.headers.add(name: .contentType, value: "application/json")
      }
      firecrawlStatus = try firecrawlStatusResponse.content.decode(FirecrawlExtractionStatus.self)
    }

    let firecrawlResponse = try firecrawlStatusResponse.content.decode(
      FirecrawlResponse<T>.self
    )

    guard firecrawlResponse.success, let extractedData = firecrawlResponse.data else {
      throw FirecrawlError.extractionFailed
    }

    return extractedData
  }
}
