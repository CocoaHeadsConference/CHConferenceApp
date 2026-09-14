import CocoaHeadsCore
import Foundation

/// Synthetic content with stable identities and dates relative to the supplied clock.
/// Mock media URLs resolve to bundled assets without using HTTP.
public enum CatalogFixtures {
  public static let heroImageURL = URL(string: "https://fixtures.cocoaheads.example/community-hero.png")!

  public static func catalog(now: Date = .now) -> EventCatalog {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo") ?? .gmt
    let anchor = Date(timeIntervalSince1970: now.timeIntervalSince1970.rounded(.down))
    let today = calendar.startOfDay(for: anchor)
    func date(days: Int, hour: Int = 19) -> Date {
      let day = calendar.date(byAdding: .day, value: days, to: today) ?? today
      return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
    }
    func registration(_ id: String) -> URL {
      // Reserved example domain: these fixture events are not real registrations.
      URL(string: "https://example.com/cocoaheads/\(id)") ?? URL(filePath: "/")
    }
    let chapters = [
      ChapterSummary(id: "sao-paulo", name: "São Paulo", region: "SP"),
      ChapterSummary(id: "rio-de-janeiro", name: "Rio de Janeiro", region: "RJ"),
      ChapterSummary(id: "belo-horizonte", name: "Belo Horizonte", region: "MG"),
      ChapterSummary(id: "florianopolis", name: "Florianópolis", region: "SC"),
      ChapterSummary(id: "curitiba", name: "Curitiba", region: "PR"),
      ChapterSummary(id: "porto-alegre", name: "Porto Alegre", region: "RS"),
      ChapterSummary(id: "fortaleza", name: "Fortaleza", region: "CE")
    ]
    let spVenue = EventVenue(
      name: "Apple Developer Academy", address: "Rua da Consolação, 930 · São Paulo, SP",
      latitude: -23.5488, longitude: -46.6505,
      arrivalInstructions:
        "Entrada pela portaria da Rua da Consolação. Informe que você veio para o CocoaHeads e aguarde a equipe na recepção. Haverá orientação para o auditório e acesso por elevador."
    )
    let endedToday = today.addingTimeInterval((anchor.timeIntervalSince(today) / 2).rounded(.down))
    let events = [
      CommunityEvent(
        id: "demo-sp-swiftui", chapterID: "sao-paulo",
        title: "SwiftUI em produção: lições de escala", edition: "Encontro #42",
        startDate: date(days: 3), endDate: date(days: 3).addingTimeInterval(10_800),
        summary:
          "Como levamos uma base SwiftUI de protótipo a produção: arquitetura, performance e os erros que evitamos no caminho. Depois das palestras, vamos trocar experiências com a comunidade.",
        registrationURL: registration("demo-sp-swiftui"), venue: spVenue,
        imageURL: heroImageURL,
        talks: [
          EventTalk(
            id: "demo-talk-swiftui", title: "SwiftUI em produção", speakerName: "Ana Ribeiro",
            speakerRole: "iOS Engineer"),
          EventTalk(
            id: "demo-talk-testing", title: "Testes que acompanham o produto", speakerName: "Bruno Costa",
            speakerRole: "Desenvolvedor iOS")
        ], qaSessionID: "demo-sp-swiftui"),
      CommunityEvent(
        id: "demo-sp-live", chapterID: "sao-paulo",
        title: "Encontro da comunidade: construindo juntos", edition: "Encontro #41",
        startDate: anchor.addingTimeInterval(-3_600), endDate: anchor.addingTimeInterval(3_600),
        summary:
          "Nosso encontro está acontecendo agora. Compartilhe suas perguntas e venha conversar sobre o que estamos construindo com Swift.",
        registrationURL: registration("demo-sp-live"), venue: spVenue,
        imageURL: heroImageURL,
        talks: [
          EventTalk(
            id: "demo-talk-live", title: "Pequenos apps, grandes aprendizados",
            speakerName: "Carla Oliveira", speakerRole: "Apple platforms developer")
        ],
        qaSessionID: "demo-sp-live"),
      CommunityEvent(
        id: "demo-bh-concurrency", chapterID: "belo-horizonte",
        title: "async/await na prática", edition: "Encontro #28",
        startDate: date(days: 10, hour: 20),
        summary:
          "Uma conversa prática sobre concorrência em Swift, cancelamento e como deixar interfaces responsivas. O encontro é online e aberto a pessoas de todas as cidades.",
        registrationURL: registration("demo-bh-concurrency"), format: .online,
        onlineURL: registration("demo-bh-concurrency/transmissao"),
        talks: [
          EventTalk(
            id: "demo-talk-concurrency", title: "Concorrência sem mistério",
            speakerName: "Marina Alves", speakerRole: "iOS Engineer")
        ],
        qaSessionID: "demo-bh-concurrency"),
      CommunityEvent(
        id: "demo-floripa-hackathon", chapterID: "florianopolis",
        title: "Hackathon CocoaHeads Brasil", edition: "Edição especial",
        startDate: date(days: 24, hour: 9), endDate: date(days: 25, hour: 18),
        summary:
          "Dois dias para aprender, criar e conhecer pessoas da comunidade Apple. Forme uma equipe e transforme uma ideia em um protótipo. Participe presencialmente ou acompanhe online.",
        registrationURL: registration("demo-floripa-hackathon"), format: .hybrid,
        venue: EventVenue(
          name: "Espaço da comunidade", address: "Centro · Florianópolis, SC",
          latitude: -27.5949, longitude: -48.5482),
        onlineURL: registration("demo-floripa-hackathon/transmissao"),
        imageURL: heroImageURL,
        links: [
          EventLink(
            id: "demo-hackathon-guide", title: "Como participar",
            url: registration("demo-floripa-hackathon/guia"))
        ], isFeatured: true),
      CommunityEvent(
        id: "demo-rio-today", chapterID: "rio-de-janeiro",
        title: "Acessibilidade desde o primeiro commit", edition: "Encontro #35",
        startDate: endedToday.addingTimeInterval(-7_200), endDate: endedToday,
        summary:
          "Nosso encontro de hoje já terminou. Obrigado por participar da conversa sobre Dynamic Type, VoiceOver e interfaces inclusivas.",
        registrationURL: registration("demo-rio-today"),
        venue: EventVenue(name: "Casa da comunidade", address: "Botafogo · Rio de Janeiro, RJ"),
        talks: [
          EventTalk(
            id: "demo-talk-accessibility", title: "Acessibilidade no dia a dia",
            speakerName: "João Pereira", speakerRole: "Desenvolvedor iOS")
        ],
        qaSessionID: "demo-rio-today"),
      CommunityEvent(
        id: "demo-poa-testing", chapterID: "porto-alegre",
        title: "Swift Testing na prática", edition: "Encontro #19",
        startDate: date(days: -14), endDate: date(days: -14, hour: 21),
        summary:
          "Revisitamos estratégias de testes para apps Swift: modelos, networking e os fluxos que precisam continuar funcionando a cada versão.",
        registrationURL: registration("demo-poa-testing"),
        venue: EventVenue(name: "Hub da comunidade", address: "Centro Histórico · Porto Alegre, RS"),
        talks: [
          EventTalk(
            id: "demo-talk-past", title: "Testes claros com Swift Testing",
            speakerName: "Lucas Martins", speakerRole: "iOS Engineer")
        ],
        qaSessionID: "demo-poa-testing")
    ]
    let features = [
      CatalogFeature(
        id: "demo-feature-floripa-hackathon", chapterID: "florianopolis",
        title: "Hackathon CocoaHeads Brasil", subtitle: "Dois dias para criar com a comunidade",
        imageURL: heroImageURL, destination: .event(id: "demo-floripa-hackathon")),
      CatalogFeature(
        id: "demo-feature-floripa-community", chapterID: "florianopolis",
        title: "Conheça o capítulo de Floripa", subtitle: "Pessoas, projetos e ideias da nossa comunidade",
        destination: .externalURL(registration("florianopolis/comunidade"))),
      CatalogFeature(
        id: "demo-feature-sp-swiftui", chapterID: "sao-paulo",
        title: "SwiftUI em produção", subtitle: "Experiências de quem cria apps todos os dias",
        imageURL: heroImageURL, destination: .event(id: "demo-sp-swiftui")),
      CatalogFeature(
        id: "demo-feature-brasil-news", title: "A comunidade está crescendo",
        subtitle: "Em breve, mais formas de participar de todo o Brasil",
        destination: .placeholder(title: "Novidades da comunidade em breve"))
    ]
    return EventCatalog(chapters: chapters, events: events, features: features)
  }
}
