//
//  Event+UI.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import SwiftUI

extension Event {
  @MainActor  // isAppClip
  public var ui: [EventDetailUI] {
    return [
      .details(title: title, remoteImage: nil, cloudKitImageID: id, shareURL: rsvpURL),
      .raffle("67sp"),
      .card(
        title: nil,
        ui: [
          .qa(sessionID: "event-\(self.id.uuidString)")
        ]),
      .card(
        title: nil,
        ui: [
          .text("Running on app clip: \(Bundle.main.isAppClip)"),
          .caption(text: "(Este card só aparece para usuários do TestFlight)")
        ]
      ).debug(),
      // TODO: `EventDetailUI.appClip(enabled: Bool, ui: EventDetailUI` so we can encode this info
      UIApplication.shared.isAppClip
        ? .empty
        : .card(
          title: nil,
          ui: [
            .callToAction(title: "Confirmar presença!", url: .apple, systemImage: "figure.walk"),
            .caption(
              text: "A entrada será permitida somente após o preenchimento dos dados "
                + "necessários para cadastro no evento dentro do app Meetup."),
            .caption(
              text: "(Esse card inteiro desaparece quando é um App Clip, dá uma olhada lá no TestFlight!)"
            ).debug()
          ]),
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
              subtitle: "Rua Butantã, 194 - São Paulo, SP",
              systemImage: "mappin"
            )
          ])
        ]
      ),
      .card(
        title: "Talks & Palestrantes",
        ui: [
          .speaker(name: "Aleph Retamal", talk: "URLSession 101"),
          .carousel(ui: [
            .link(.apple, title: "Canal YouTube"),
            .link(.codeOfConduct),
            .link(.apple)
          ]),
          .speaker(
            name: "Ruan Reis",
            talk: "Swift Concurrency: Desafios na adaptação e implementação de código assíncrono"
          ),
          .link(.apple, title: "LinkedIn")
        ]
      ),
      .card(
        title: "TO-DO: Card de socials",
        ui: [
          .caption(text: "Adicionar socials e etc")
        ]
      ),
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
      ),
      .card(
        title: "Onde",
        ui: [
          .text("Rua Butantã 194, São Paulo - SP"),
          .map(
            address: "Rua Butantã 194, São Paulo - SP",
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
          )
        ]
      )
    ]
  }
}
