//
//  Meetup+UI.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import CocoaHeadsCore
import Common
import CoreLocation
import SwiftUI

extension MeetupEvent {
  @MainActor
  var ui: [EventDetailUI] {
    [
      .details(title: title, remoteImage: image, cloudKitImageID: nil, shareURL: url),
      .rsvpCard(url: url),
      .qaCard(for: self),
      .infoCard(date: date, address: address),
      .descriptionCard(description),
      .socials(adding: nil),
      .codeOfConduct,
      .whereCard(
        address: address,
        location: location
      )
    ]
  }

  @MainActor
  func ui(
    customDescription: String,
    withExtraSocial socialURL: URL?,
    speakers: EventDetailUI
  ) -> [EventDetailUI] {
    [
      .details(title: title, remoteImage: image, cloudKitImageID: nil, shareURL: url),
      .rsvpCard(url: url),
      .qaCard(for: self),
      .infoCard(date: date, address: address),
      .descriptionCard(customDescription),
      speakers,
      .socials(adding: socialURL),
      .codeOfConduct,
      .whereCard(
        address: address,
        location: location
      )
    ]
  }
}

extension EventDetailUI {
  @MainActor
  fileprivate static func rsvpCard(url: URL) -> EventDetailUI {
    UIApplication.shared.isAppClip
      ? .empty
      : .card(
        title: nil,
        ui: [
          .callToAction(title: "Confirmar presença!", url: url, systemImage: "figure.walk"),
          .caption(
            text: "A entrada será permitida somente após o preenchimento dos dados "
              + "necessários para cadastro no evento dentro do app Meetup."),
          .caption(
            text: "(Esse card inteiro desaparece quando é um App Clip, dá uma olhada lá no TestFlight!)"
          ).debug()
        ])
  }

  fileprivate static func infoCard(
    date: Date,
    address: String
  ) -> EventDetailUI {
    .card(
      title: "Informações",
      ui: [
        .vstack(ui: [
          .titleSubtitle(
            title: "Data",
            subtitle: date.formatted(date: .complete, time: .omitted),
            systemImage: "calendar"
          ),
          .divider,
          .titleSubtitle(
            title: "Duração",
            // TODO: Event should have duration
            subtitle:
              date.formatted(date: .omitted, time: .shortened) + " - "
              + date.advanced(by: 3600 * 3).formatted(date: .omitted, time: .shortened),
            systemImage: "clock"
          ),
          .divider,
          .titleSubtitle(
            title: "Endereço",
            subtitle: address,
            systemImage: "mappin"
          )
        ])
      ]
    )
  }

  fileprivate static func descriptionCard(_ description: String) -> EventDetailUI {
    .card(
      title: "Descrição",
      ui: [
        .text(description)
      ])
  }

  fileprivate static func socials(adding link: URL?) -> EventDetailUI {
    .card(
      title: "Siga nossas redes sociais",
      ui: [
        .carousel(ui: [
          .link(orEmpty: link),
          .link(URL(string: "https://www.linkedin.com/company/cocoaheads-brasil")!),
          .link(URL(string: "https://www.instagram.com/cocoaheadsbr/")!),
          .link(URL(string: "https://bsky.app/profile/cocoaheads.com.br")!, title: "bluesky.app")
        ])
      ])
  }

  // TODO: Move to a better place
  static func link(orEmpty url: URL?) -> EventDetailUI {
    if let url {
      .link(url)
    } else {
      .empty
    }
  }

  fileprivate static func qaCard(for meetupEvent: MeetupEvent) -> EventDetailUI {
    .card(
      title: nil,
      ui: [
        .qa(sessionID: "meetup-\(meetupEvent.url.absoluteString.hash)")
      ]
    )
  }

  fileprivate static var codeOfConduct: EventDetailUI {
    .card(
      title: "Avisos",
      ui: [
        .text(
          "A organização do CocoaHeads captura fotos durante o evento todo, "
            + "para divulgação de futuros eventos.\n"
            + "Não quer aparecer nas nossas redes? "
            + "Avise o organizador ou faça 🖐️ para a foto."
        ),
        // TODO: Create in-app screen for this
        .callToAction(title: "Leia nosso código de conduta", url: .codeOfConduct)
      ]
    )
  }

  fileprivate static func whereCard(address: String, location: MeetupEvent.Location) -> EventDetailUI {
    .card(
      title: "Onde",
      ui: [
        .text(address),
        .map(
          address: address,
          lat: location.latitude,
          lng: location.longitude
        )
      ]
    )
  }
}
