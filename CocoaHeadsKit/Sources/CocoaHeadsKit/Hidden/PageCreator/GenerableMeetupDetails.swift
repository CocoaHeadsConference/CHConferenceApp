//
//  GenerableMeetupDetails.swift
//  CocoaHeadsKit
//
//  Created by Mauricio Cardozo on 9/30/25.
//

import FoundationModels
import Playgrounds

@Generable
struct GeneratedMeetupDetails {
  @Guide(description: "Location info")
  var locationInfo: String

  @Guide(description: "Details for all speakers")
  var speakers: [SpeakerData]

  @Generable
  struct SpeakerData {
    @Guide(description: "The name of a speaker")
    var name: String

    @Guide(description: "The title of that speaker's talk")
    var talk: String
  }
}

#Playground {
  let text = """
    O CocoaHeads SP é um evento gratuito sobre desenvolvimento e design de tecnologias Apple (iOS, macOS, visionOS, iPadOS, tvOS, watchOS, Swift e tudo que envolve essas plataformas) e vamos nos encontrar mais uma vez para trocar conhecimentos e experiências!

    Para esta edição contaremos com as talks Escalando aplicativos com React Native do Luis Oliveira (OLX) e a talk Um dev iOS se aventurando no macOS, do Bruno Faganello (Thoughtworks)

    • Quer ficar por dentro de tudo que tá rolando no CocoaHeads, quer palestrar ou precisa conversar com a gente? Segue a gente nas redes sociais!👇

    LinkedIn: CocoaHeads Brasil
    Bluesky: [@cocoaheads.com.br](https://bsky.app/profile/cocoaheads.com.br)
    Instagram: @CocoaHeadsBr

    • Como chego lá?
    O Mackenzie fica na Avenida da Consolação, bem próximo da estação Higienópolis - Mackenzie da linha 4 Amarela, e também existe bicicletário no local.

    Por favor, identifique-se corretamente na pergunta ao se inscrever com o seu RG e CPF.

    Inscrições sem os dados preenchidos vão ser removidas em favor daquelas que foram preenchidas corretamente!
    """

  let session = LanguageModelSession(instructions: "Extract event details from the following text")

  let result = try await session.respond(
    to: text,
    generating: GeneratedMeetupDetails.self
  )
}
